<?php

namespace App\Services;

use App\Jobs\ProcessAiEscalationNotification;
use App\Models\AiEscalationNotification;
use App\Models\AppNotification;
use App\Models\Company;
use Illuminate\Support\Carbon;
use Illuminate\Support\Facades\Http;
use Illuminate\Support\Facades\Mail;

class AiEscalationService
{
    /**
     * @param  array<int,string>  $channels
     * @param  array<int,string>  $recipients
     * @return array<int,AiEscalationNotification>
     */
    public function queueNotifications(
        Company $company,
        ?int $triggeredByUserId,
        string $alertCode,
        string $severity,
        string $level,
        string $policy,
        string $message,
        array $channels,
        array $recipients,
    ): array {
        $scheduledFor = $this->resolveScheduledFor($policy);
        $rows = [];
        $runbookUrl = $this->resolveRunbookUrl($company, $alertCode);
        $finalMessage = $runbookUrl !== null
            ? rtrim($message)."\nRunbook: {$runbookUrl}"
            : $message;
        $suppressed = $this->isInSilenceWindow($company);

        foreach ($channels as $channel) {
            if ($channel === 'in_app') {
                $rows[] = $this->createAndDispatch(
                    company: $company,
                    triggeredByUserId: $triggeredByUserId,
                    alertCode: $alertCode,
                    severity: $severity,
                    level: $level,
                    channel: $channel,
                    recipient: null,
                    message: $finalMessage,
                    policy: $policy,
                    scheduledFor: $scheduledFor,
                    suppressed: $suppressed,
                );
                continue;
            }

            foreach ($recipients as $recipient) {
                $rows[] = $this->createAndDispatch(
                    company: $company,
                    triggeredByUserId: $triggeredByUserId,
                    alertCode: $alertCode,
                    severity: $severity,
                    level: $level,
                    channel: $channel,
                    recipient: $recipient,
                    message: $finalMessage,
                    policy: $policy,
                    scheduledFor: $scheduledFor,
                    suppressed: $suppressed,
                );
            }
        }

        return $rows;
    }

    public function process(AiEscalationNotification $notification): void
    {
        if ($notification->status === 'sent') {
            return;
        }

        $company = $notification->company;
        if (! $company) {
            throw new \RuntimeException('Company not found for escalation notification');
        }

        $notification->status = 'processing';
        $notification->attempts = max((int) $notification->attempts, 0) + 1;
        $notification->save();

        $channel = (string) $notification->channel;
        if ($channel === 'in_app') {
            AppNotification::query()->create([
                'company_id' => $company->id,
                'employee_id' => null,
                'title' => 'AI Incident Escalation',
                'body' => $notification->message,
                'type' => 'ai_incident',
            ]);
        } elseif ($channel === 'email') {
            if (! $notification->recipient) {
                throw new \RuntimeException('Recipient is required for email channel');
            }
            Mail::raw($notification->message, function ($mail) use ($company, $notification): void {
                $from = (string) ($company->ai_alert_email_from ?: config('mail.from.address'));
                if ($from !== '') {
                    $mail->from($from, (string) config('mail.from.name', 'HRM AI'));
                }
                $mail->to($notification->recipient)
                    ->subject("[AI Escalation][{$notification->severity}] {$notification->alert_code}");
            });
        } elseif ($channel === 'slack') {
            $webhook = (string) ($company->ai_slack_webhook_url ?: config('services.ai.slack_webhook_url', ''));
            if ($webhook === '') {
                throw new \RuntimeException('Slack webhook is not configured');
            }
            $res = Http::timeout(10)->post($webhook, [
                'text' => sprintf(
                    "[AI Escalation][%s][%s] %s\nLevel: %s\n%s",
                    strtoupper((string) $notification->severity),
                    $notification->alert_code,
                    $company->name,
                    $notification->level,
                    $notification->message,
                ),
            ]);
            if (! $res->successful()) {
                throw new \RuntimeException('Slack delivery failed with status '.$res->status());
            }
        } else {
            throw new \RuntimeException("Unsupported escalation channel: {$channel}");
        }

        $notification->status = 'sent';
        $notification->last_error = null;
        $notification->sent_at = now();
        $notification->save();
    }

    public function markFailed(AiEscalationNotification $notification, string $error): void
    {
        $notification->status = 'failed';
        $notification->last_error = $error;
        $notification->failed_at = now();
        $notification->save();
    }

    /**
     * @return array<string,mixed>
     */
    public function queueDigestForCompany(
        Company $company,
        ?int $triggeredByUserId,
        int $windowMinutes,
        bool $dryRun = false,
    ): array {
        if (! ((bool) ($company->ai_digest_enabled ?? true))) {
            return [
                'window_minutes' => $windowMinutes,
                'enabled' => false,
                'queued_notifications' => 0,
                'summary' => [],
            ];
        }

        $from = now()->subMinutes(max(5, $windowMinutes));
        $rows = AiEscalationNotification::query()
            ->where('company_id', $company->id)
            ->whereBetween('created_at', [$from, now()])
            ->where('alert_code', '!=', 'digest_summary')
            ->get(['status', 'alert_code', 'severity']);

        $statusSummary = $rows->groupBy('status')->map(fn ($g) => $g->count())->all();
        $alertsSummary = $rows->groupBy('alert_code')->map(fn ($g) => $g->count())->all();

        $messageLines = [
            "AI escalation digest for last {$windowMinutes} minutes",
            'Status summary: '.json_encode($statusSummary, JSON_UNESCAPED_UNICODE | JSON_UNESCAPED_SLASHES),
            'Alerts summary: '.json_encode($alertsSummary, JSON_UNESCAPED_UNICODE | JSON_UNESCAPED_SLASHES),
        ];
        $message = implode("\n", $messageLines);

        $channels = is_array($company->ai_alert_channels) ? array_values($company->ai_alert_channels) : ['in_app'];
        $matrix = is_array($company->ai_escalation_matrix) ? $company->ai_escalation_matrix : [];
        $l1 = is_array($matrix['l1'] ?? null) ? $matrix['l1'] : [];
        $recipients = is_array($l1['recipients'] ?? null) ? array_values($l1['recipients']) : ['hr-oncall@company.local'];
        $policy = (string) ($l1['policy'] ?? 'notify_now');

        $queued = [];
        if (! $dryRun) {
            $queued = $this->queueNotifications(
                company: $company,
                triggeredByUserId: $triggeredByUserId,
                alertCode: 'digest_summary',
                severity: 'info',
                level: 'l1',
                policy: $policy,
                message: $message,
                channels: $channels,
                recipients: $recipients,
            );
        }

        return [
            'window_minutes' => $windowMinutes,
            'enabled' => true,
            'queued_notifications' => count($queued),
            'summary' => [
                'status' => $statusSummary,
                'alerts' => $alertsSummary,
            ],
        ];
    }

    private function resolveScheduledFor(string $policy): ?Carbon
    {
        if ($policy === 'page_immediately' || $policy === 'notify_now') {
            return now();
        }
        if (preg_match('/^notify_in_(\d+)m$/', $policy, $m) === 1) {
            $minutes = max(1, (int) ($m[1] ?? 1));
            return now()->addMinutes($minutes);
        }

        return now();
    }

    private function createAndDispatch(
        Company $company,
        ?int $triggeredByUserId,
        string $alertCode,
        string $severity,
        string $level,
        string $channel,
        ?string $recipient,
        string $message,
        string $policy,
        ?Carbon $scheduledFor,
        bool $suppressed = false,
    ): AiEscalationNotification {
        $notification = AiEscalationNotification::query()->create([
            'company_id' => (int) $company->id,
            'triggered_by_user_id' => $triggeredByUserId,
            'alert_code' => $alertCode,
            'severity' => $severity,
            'level' => $level,
            'channel' => $channel,
            'recipient' => $recipient,
            'message' => $message,
            'status' => $suppressed ? 'suppressed' : 'queued',
            'attempts' => 0,
            'max_attempts' => 3,
            'payload' => [
                'policy' => $policy,
                'suppressed' => $suppressed,
            ],
            'scheduled_for' => $scheduledFor,
        ]);

        if ($suppressed) {
            return $notification;
        }

        $job = new ProcessAiEscalationNotification((int) $notification->id);
        if ($scheduledFor !== null && $scheduledFor->isFuture()) {
            $job->delay($scheduledFor);
        }
        dispatch($job);

        return $notification;
    }

    private function resolveRunbookUrl(Company $company, string $alertCode): ?string
    {
        $links = is_array($company->ai_runbook_links) ? $company->ai_runbook_links : [];
        $url = $links[$alertCode] ?? $links['default'] ?? null;
        if (! is_string($url) || trim($url) === '') {
            return null;
        }

        return trim($url);
    }

    private function isInSilenceWindow(Company $company): bool
    {
        $windows = is_array($company->ai_silence_windows) ? $company->ai_silence_windows : [];
        if (empty($windows)) {
            return false;
        }
        $now = now();
        $weekday = (int) $now->isoWeekday();
        $minutesNow = ((int) $now->format('H')) * 60 + (int) $now->format('i');

        foreach ($windows as $window) {
            if (! is_array($window)) {
                continue;
            }
            $days = is_array($window['days'] ?? null) ? $window['days'] : [];
            if (! empty($days) && ! in_array($weekday, array_map('intval', $days), true)) {
                continue;
            }
            $start = $this->parseTimeToMinutes((string) ($window['start'] ?? '00:00'));
            $end = $this->parseTimeToMinutes((string) ($window['end'] ?? '00:00'));
            if ($start === null || $end === null) {
                continue;
            }
            if ($start <= $end) {
                if ($minutesNow >= $start && $minutesNow < $end) {
                    return true;
                }
            } else {
                if ($minutesNow >= $start || $minutesNow < $end) {
                    return true;
                }
            }
        }

        return false;
    }

    private function parseTimeToMinutes(string $hhmm): ?int
    {
        if (preg_match('/^([01]\d|2[0-3]):([0-5]\d)$/', $hhmm, $m) !== 1) {
            return null;
        }

        return ((int) $m[1]) * 60 + (int) $m[2];
    }
}
