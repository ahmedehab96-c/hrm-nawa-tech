<?php

namespace App\Console\Commands;

use App\Models\AiAuditEvent;
use App\Models\AiEscalationNotification;
use App\Models\AiTask;
use App\Models\Company;
use App\Services\AiAuditService;
use App\Services\AiEscalationService;
use Illuminate\Console\Command;

class AiQueueHealthMonitorCommand extends Command
{
    protected $signature = 'ai:queue-health-monitor
        {--company_id= : Monitor a specific company id}
        {--window=15 : Lookback window in minutes}
        {--cooldown=30 : Minimum minutes between repeated alerts}
        {--dry-run : Evaluate and log without queuing notifications}';

    protected $description = 'Auto-escalate when AI queue failures cross company threshold';

    public function handle(
        AiEscalationService $escalationService,
        AiAuditService $auditService,
    ): int {
        $windowMinutes = max(5, (int) $this->option('window'));
        $cooldownMinutes = max(5, (int) $this->option('cooldown'));
        $dryRun = (bool) $this->option('dry-run');
        $companyId = $this->option('company_id');

        $companiesQuery = Company::query()->where('ai_enabled', true);
        if ($companyId !== null && (string) $companyId !== '') {
            $companiesQuery->where('id', (int) $companyId);
        }
        $companies = $companiesQuery->get();
        if ($companies->isEmpty()) {
            $this->info('No AI-enabled companies found for queue health monitor.');
            return self::SUCCESS;
        }

        $windowStart = now()->subMinutes($windowMinutes);
        $cooldownStart = now()->subMinutes($cooldownMinutes);
        $triggered = 0;

        foreach ($companies as $company) {
            $threshold = max(1, (int) ($company->ai_alert_queue_failure_threshold ?? 3));
            $failedAiTasks = (int) AiTask::query()
                ->where('company_id', $company->id)
                ->where('status', 'failed')
                ->where('created_at', '>=', $windowStart)
                ->count();
            $failedEscalationNotifications = (int) AiEscalationNotification::query()
                ->where('company_id', $company->id)
                ->where('status', 'failed')
                ->where('created_at', '>=', $windowStart)
                ->count();
            $failedTotal = $failedAiTasks + $failedEscalationNotifications;

            if ($failedTotal < $threshold) {
                $this->line(sprintf(
                    'Company %d healthy (failures=%d, threshold=%d)',
                    (int) $company->id,
                    $failedTotal,
                    $threshold,
                ));
                continue;
            }

            $inCooldown = AiAuditEvent::query()
                ->where('company_id', $company->id)
                ->where('event_type', 'ai_queue_failures_alerted')
                ->where('created_at', '>=', $cooldownStart)
                ->exists();
            if ($inCooldown) {
                $this->warn(sprintf(
                    'Company %d skipped due to cooldown (failures=%d)',
                    (int) $company->id,
                    $failedTotal,
                ));
                continue;
            }

            $severity = $failedTotal >= ($threshold * 2) ? 'critical' : 'warning';
            $level = $severity === 'critical' ? 'l3' : 'l2';
            $matrix = $this->resolveEscalationMatrix($company);
            $policy = (string) ($matrix[$level]['policy'] ?? 'notify_now');
            $recipients = is_array($matrix[$level]['recipients'] ?? null)
                ? array_values($matrix[$level]['recipients'])
                : [];
            $channels = is_array($company->ai_alert_channels)
                ? array_values($company->ai_alert_channels)
                : ['in_app'];

            $message = sprintf(
                'Queue failures exceeded threshold in last %d minutes. total=%d (ai_tasks=%d, escalation_notifications=%d), threshold=%d.',
                $windowMinutes,
                $failedTotal,
                $failedAiTasks,
                $failedEscalationNotifications,
                $threshold,
            );

            $queued = [];
            if (! $dryRun) {
                $queued = $escalationService->queueNotifications(
                    company: $company,
                    triggeredByUserId: null,
                    alertCode: 'queue_failures_runtime',
                    severity: $severity,
                    level: $level,
                    policy: $policy,
                    message: $message,
                    channels: $channels,
                    recipients: $recipients,
                );
            }

            $auditService->log(
                companyId: (int) $company->id,
                userId: null,
                eventType: 'ai_queue_failures_alerted',
                severity: $severity,
                endpoint: 'artisan:ai:queue-health-monitor',
                context: [
                    'alert_code' => 'queue_failures_runtime',
                    'window_minutes' => $windowMinutes,
                    'cooldown_minutes' => $cooldownMinutes,
                    'failed_total' => $failedTotal,
                    'failed_ai_tasks' => $failedAiTasks,
                    'failed_escalation_notifications' => $failedEscalationNotifications,
                    'threshold' => $threshold,
                    'channels' => $channels,
                    'level' => $level,
                    'policy' => $policy,
                    'dry_run' => $dryRun,
                    'queued_notifications' => count($queued),
                ],
            );

            $this->error(sprintf(
                'Company %d alerted (failures=%d, severity=%s, queued=%d, dry_run=%s)',
                (int) $company->id,
                $failedTotal,
                $severity,
                count($queued),
                $dryRun ? 'true' : 'false',
            ));
            $triggered++;
        }

        $this->info("Queue health monitor finished. Alerts triggered: {$triggered}.");

        return self::SUCCESS;
    }

    /**
     * @return array<string,array<string,mixed>>
     */
    private function resolveEscalationMatrix(Company $company): array
    {
        $custom = is_array($company->ai_escalation_matrix) ? $company->ai_escalation_matrix : [];

        $defaults = [
            'l1' => [
                'policy' => 'notify_in_5m',
                'recipients' => ['hr-oncall@company.local'],
            ],
            'l2' => [
                'policy' => 'notify_now',
                'recipients' => ['engineering-oncall@company.local', 'hr-manager@company.local'],
            ],
            'l3' => [
                'policy' => 'page_immediately',
                'recipients' => ['cto@company.local', 'security@company.local'],
            ],
        ];

        foreach ($custom as $level => $item) {
            if (! is_string($level) || ! is_array($item) || ! array_key_exists($level, $defaults)) {
                continue;
            }
            $defaults[$level] = array_merge($defaults[$level], $item);
            if (! is_array($defaults[$level]['recipients'] ?? null)) {
                $defaults[$level]['recipients'] = [];
            }
        }

        return $defaults;
    }
}
