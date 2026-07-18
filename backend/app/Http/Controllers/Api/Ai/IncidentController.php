<?php

namespace App\Http\Controllers\Api\Ai;

use App\Jobs\ProcessAiEscalationDigest;
use App\Models\AiConversation;
use App\Models\AiAuditEvent;
use App\Models\AiEscalationNotification;
use App\Models\AiMessage;
use App\Models\AiPromptVersion;
use App\Models\AiTask;
use App\Models\AiUsageLog;
use App\Models\Company;
use App\Models\JobDescription;
use Illuminate\Support\Facades\DB;
use Illuminate\Http\Request;
use Illuminate\Support\Carbon;
use Throwable;

class IncidentController extends BaseAiController
{
    public function incidentPlaybooks(Request $request)
    {
        $company = Company::query()->find($request->user()->company_id);
        if (! $company) {
            return response()->json(['message' => 'Company not found'], 404);
        }
        $days = max(1, min(90, (int) $request->query('days', 14)));
        $snapshot = $this->computeAlertSnapshot($company, $days);

        $runbooks = $this->resolveRunbookLinks($company);
        $playbooks = [
            [
                'id' => 'high_error_rate',
                'title' => 'High Error-Rate Response',
                'actions' => ['tighten_safety', 'reduce_rollout_50', 'switch_provider_openai'],
                'runbook_url' => $runbooks['high_error_rate'] ?? $runbooks['default'] ?? null,
            ],
            [
                'id' => 'high_p95_latency',
                'title' => 'High Latency Response',
                'actions' => ['switch_provider_gemini', 'reduce_rollout_50'],
                'runbook_url' => $runbooks['high_p95_latency'] ?? $runbooks['default'] ?? null,
            ],
            [
                'id' => 'queue_failures',
                'title' => 'Queue Failure Response',
                'actions' => ['disable_recruitment_ai', 'reduce_rollout_50'],
                'runbook_url' => $runbooks['queue_failures'] ?? $runbooks['default'] ?? null,
            ],
        ];

        return response()->json([
            'data' => [
                'alerts' => $snapshot['alerts'],
                'policies' => $snapshot['policy'],
                'playbooks' => $playbooks,
                'runbook_links' => $runbooks,
            ],
        ]);
    }

    public function applyRemediation(Request $request)
    {
        $validated = $request->validate([
            'action_id' => 'required|in:tighten_safety,reduce_rollout_50,disable_recruitment_ai,switch_provider_openai,switch_provider_gemini',
            'dry_run' => 'nullable|boolean',
        ]);
        $user = $request->user();
        $company = Company::query()->find($user->company_id);
        if (! $company) {
            return response()->json(['message' => 'Company not found'], 404);
        }

        $actionId = (string) $validated['action_id'];
        $dryRun = (bool) ($validated['dry_run'] ?? false);
        $before = $this->companyAiState($company);
        $after = $before;

        $this->applyRemediationAction($after, $actionId);
        if (! $dryRun) {
            $company->fill($after);
            $company->save();
        }

        $this->aiAuditService->log(
            companyId: (int) $company->id,
            userId: (int) $user->id,
            eventType: 'ai_remediation_applied',
            severity: 'warning',
            endpoint: 'ai/remediation/apply',
            context: [
                'action_id' => $actionId,
                'dry_run' => $dryRun,
                'before' => $before,
                'after' => $after,
            ],
        );

        return response()->json([
            'data' => [
                'action_id' => $actionId,
                'dry_run' => $dryRun,
                'before' => $before,
                'after' => $after,
            ],
        ]);
    }

    public function autoRemediate(Request $request)
    {
        $validated = $request->validate([
            'days' => 'nullable|integer|min:1|max:90',
            'dry_run' => 'nullable|boolean',
        ]);
        $user = $request->user();
        $company = Company::query()->find($user->company_id);
        if (! $company) {
            return response()->json(['message' => 'Company not found'], 404);
        }
        $days = (int) ($validated['days'] ?? 14);
        $dryRun = (bool) ($validated['dry_run'] ?? true);
        $snapshot = $this->computeAlertSnapshot($company, $days);
        $alerts = $snapshot['alerts'];

        $actions = [];
        foreach ($alerts as $alert) {
            $code = (string) ($alert['code'] ?? '');
            if ($code === 'high_error_rate') {
                $actions[] = 'tighten_safety';
                $actions[] = 'reduce_rollout_50';
            } elseif ($code === 'high_p95_latency') {
                $actions[] = $company->ai_provider === 'openai'
                    ? 'switch_provider_gemini'
                    : 'switch_provider_openai';
            } elseif ($code === 'queue_failures') {
                $actions[] = 'disable_recruitment_ai';
            }
        }
        $actions = array_values(array_unique($actions));

        $before = $this->companyAiState($company);
        $after = $before;
        foreach ($actions as $actionId) {
            $this->applyRemediationAction($after, $actionId);
        }
        if (! $dryRun && ! empty($actions)) {
            $company->fill($after);
            $company->save();
        }

        $this->aiAuditService->log(
            companyId: (int) $company->id,
            userId: (int) $user->id,
            eventType: 'ai_auto_remediation_run',
            severity: empty($actions) ? 'info' : 'warning',
            endpoint: 'ai/remediation/auto',
            context: [
                'days' => $days,
                'dry_run' => $dryRun,
                'actions' => $actions,
                'alerts' => $alerts,
            ],
        );

        return response()->json([
            'data' => [
                'dry_run' => $dryRun,
                'days' => $days,
                'actions' => $actions,
                'alerts' => $alerts,
                'before' => $before,
                'after' => $after,
            ],
        ]);
    }

    public function dispatchEscalation(Request $request)
    {
        $validated = $request->validate([
            'alert_code' => 'required|string|max:100',
            'severity' => 'nullable|in:info,warning,critical',
            'channels' => 'nullable|array',
            'channels.*' => 'string|in:email,slack,in_app',
            'message' => 'nullable|string|max:500',
            'dry_run' => 'nullable|boolean',
        ]);
        $user = $request->user();
        $company = Company::query()->find($user->company_id);
        if (! $company) {
            return response()->json(['message' => 'Company not found'], 404);
        }

        $alertCode = (string) $validated['alert_code'];
        $severity = (string) ($validated['severity'] ?? 'warning');
        $dryRun = (bool) ($validated['dry_run'] ?? true);
        $channels = is_array($validated['channels'] ?? null)
            ? array_values($validated['channels'])
            : (is_array($company->ai_alert_channels) ? array_values($company->ai_alert_channels) : ['in_app']);

        $level = $this->selectEscalationLevel($alertCode, $severity);
        $matrix = $this->resolveEscalationMatrix($company);
        $recipients = (array) ($matrix[$level]['recipients'] ?? []);
        $policy = (string) ($matrix[$level]['policy'] ?? 'notify_now');

        $payload = [
            'company_id' => (int) $company->id,
            'alert_code' => $alertCode,
            'severity' => $severity,
            'level' => $level,
            'channels' => $channels,
            'recipients' => $recipients,
            'policy' => $policy,
            'message' => (string) ($validated['message'] ?? "Escalation triggered for {$alertCode}"),
            'runbook_url' => $this->resolveRunbookLinks($company)[$alertCode]
                ?? $this->resolveRunbookLinks($company)['default']
                ?? null,
            'triggered_at' => now()->toIso8601String(),
            'dry_run' => $dryRun,
        ];

        $queued = [];
        if (! $dryRun) {
            $queued = $this->aiEscalationService->queueNotifications(
                company: $company,
                triggeredByUserId: (int) $user->id,
                alertCode: $alertCode,
                severity: $severity,
                level: $level,
                policy: $policy,
                message: (string) $payload['message'],
                channels: $channels,
                recipients: $recipients,
            );
        }

        $this->aiAuditService->log(
            companyId: (int) $company->id,
            userId: (int) $user->id,
            eventType: 'ai_escalation_dispatched',
            severity: $severity,
            endpoint: 'ai/escalation/dispatch',
            context: $payload,
        );

        return response()->json([
            'data' => array_merge($payload, [
                'queued_notifications' => count($queued),
                'notification_ids' => collect($queued)->map(fn (AiEscalationNotification $n) => (int) $n->id)->values()->all(),
            ]),
        ]);
    }

    public function escalationNotifications(Request $request)
    {
        $validated = $request->validate([
            'limit' => 'nullable|integer|min:10|max:200',
        ]);
        $limit = (int) ($validated['limit'] ?? 50);
        $companyId = (int) $request->user()->company_id;

        $rows = AiEscalationNotification::query()
            ->where('company_id', $companyId)
            ->orderByDesc('id')
            ->limit($limit)
            ->get();
        $statusCounts = AiEscalationNotification::query()
            ->where('company_id', $companyId)
            ->select('status', DB::raw('COUNT(*) as total'))
            ->groupBy('status')
            ->get()
            ->mapWithKeys(fn ($r) => [(string) $r->status => (int) $r->total])
            ->all();

        return response()->json([
            'data' => [
                'status_counts' => $statusCounts,
                'items' => $rows->map(fn (AiEscalationNotification $row) => [
                    'id' => (int) $row->id,
                    'alert_code' => (string) $row->alert_code,
                    'severity' => (string) $row->severity,
                    'level' => (string) $row->level,
                    'channel' => (string) $row->channel,
                    'recipient' => $row->recipient,
                    'status' => (string) $row->status,
                    'attempts' => (int) $row->attempts,
                    'max_attempts' => (int) $row->max_attempts,
                    'last_error' => $row->last_error,
                    'scheduled_for' => $row->scheduled_for?->toIso8601String(),
                    'sent_at' => $row->sent_at?->toIso8601String(),
                    'failed_at' => $row->failed_at?->toIso8601String(),
                    'created_at' => $row->created_at?->toIso8601String(),
                ])->values()->all(),
            ],
        ]);
    }

    public function escalationRunbooks(Request $request)
    {
        $company = Company::query()->find($request->user()->company_id);
        if (! $company) {
            return response()->json(['message' => 'Company not found'], 404);
        }

        return response()->json([
            'data' => [
                'runbook_links' => $this->resolveRunbookLinks($company),
                'silence_windows' => $this->resolveSilenceWindows($company),
                'digest' => [
                    'enabled' => (bool) ($company->ai_digest_enabled ?? true),
                    'window_minutes' => (int) ($company->ai_digest_window_minutes ?? 60),
                ],
            ],
        ]);
    }

    public function runEscalationDigest(Request $request)
    {
        $validated = $request->validate([
            'window_minutes' => 'nullable|integer|min:5|max:1440',
            'queue' => 'nullable|boolean',
            'dry_run' => 'nullable|boolean',
        ]);
        $user = $request->user();
        $company = Company::query()->find($user->company_id);
        if (! $company) {
            return response()->json(['message' => 'Company not found'], 404);
        }

        $windowMinutes = (int) ($validated['window_minutes'] ?? $company->ai_digest_window_minutes ?? 60);
        $queue = (bool) ($validated['queue'] ?? true);
        $dryRun = (bool) ($validated['dry_run'] ?? false);

        if ($queue && ! $dryRun) {
            dispatch(new ProcessAiEscalationDigest(
                companyId: (int) $company->id,
                triggeredByUserId: (int) $user->id,
                windowMinutes: $windowMinutes,
            ));

            return response()->json([
                'data' => [
                    'queued' => true,
                    'window_minutes' => $windowMinutes,
                ],
            ]);
        }

        $result = $this->aiEscalationService->queueDigestForCompany(
            company: $company,
            triggeredByUserId: (int) $user->id,
            windowMinutes: $windowMinutes,
            dryRun: $dryRun,
        );

        return response()->json(['data' => array_merge(['queued' => false], $result)]);
    }

    public function queueHealthEvents(Request $request)
    {
        $validated = $request->validate([
            'limit' => 'nullable|integer|min:5|max:200',
            'window_minutes' => 'nullable|integer|min:5|max:10080',
        ]);
        $companyId = (int) $request->user()->company_id;
        $limit = (int) ($validated['limit'] ?? 30);
        $windowMinutes = (int) ($validated['window_minutes'] ?? 1440);
        $from = now()->subMinutes($windowMinutes);

        $rows = AiAuditEvent::query()
            ->where('company_id', $companyId)
            ->where('event_type', 'ai_queue_failures_alerted')
            ->where('created_at', '>=', $from)
            ->orderByDesc('id')
            ->limit($limit)
            ->get();
        $company = Company::query()->find($companyId);
        $runbooks = $company ? $this->resolveRunbookLinks($company) : ['default' => 'https://runbooks.example.com/ai/general'];

        $latest = $rows->map(function (AiAuditEvent $row) use ($runbooks) {
            $ctx = is_array($row->context) ? $row->context : [];
            $alertCode = (string) ($ctx['alert_code'] ?? 'queue_failures_runtime');
            $runbookUrl = $runbooks[$alertCode] ?? $runbooks['queue_failures'] ?? $runbooks['default'] ?? null;

            return [
                'id' => (int) $row->id,
                'event_at' => $row->event_at?->toIso8601String() ?? $row->created_at?->toIso8601String(),
                'alert_code' => $alertCode,
                'severity' => (string) $row->severity,
                'failed_total' => (int) ($ctx['failed_total'] ?? 0),
                'failed_ai_tasks' => (int) ($ctx['failed_ai_tasks'] ?? 0),
                'failed_escalation_notifications' => (int) ($ctx['failed_escalation_notifications'] ?? 0),
                'threshold' => (int) ($ctx['threshold'] ?? 0),
                'cooldown_minutes' => (int) ($ctx['cooldown_minutes'] ?? 0),
                'queued_notifications' => (int) ($ctx['queued_notifications'] ?? 0),
                'dry_run' => (bool) ($ctx['dry_run'] ?? false),
                'runbook_url' => is_string($runbookUrl) ? $runbookUrl : null,
            ];
        })->values()->all();

        $totals = [
            'alerts' => count($latest),
            'critical' => count(array_filter($latest, fn (array $x) => ($x['severity'] ?? 'info') === 'critical')),
            'warning' => count(array_filter($latest, fn (array $x) => ($x['severity'] ?? 'info') === 'warning')),
        ];

        return response()->json([
            'data' => [
                'window_minutes' => $windowMinutes,
                'totals' => $totals,
                'latest' => $latest,
            ],
        ]);
    }

    public function auditTrail(Request $request)
    {
        $validated = $request->validate([
            'limit' => 'nullable|integer|min:10|max:200',
            'event_type' => 'nullable|string|max:100',
        ]);
        $limit = (int) ($validated['limit'] ?? 80);
        $companyId = (int) $request->user()->company_id;

        $query = AiAuditEvent::query()
            ->where('company_id', $companyId)
            ->with(['user:id,name,email'])
            ->orderByDesc('id');
        if (! empty($validated['event_type'])) {
            $query->where('event_type', (string) $validated['event_type']);
        }
        $events = $query->limit($limit)->get();

        $timeline = $events->map(function (AiAuditEvent $event) {
            $context = is_array($event->context) ? $event->context : [];

            return [
                'id' => (int) $event->id,
                'event_type' => (string) $event->event_type,
                'severity' => (string) $event->severity,
                'endpoint' => $event->endpoint,
                'event_at' => $event->event_at?->toIso8601String(),
                'user' => $event->user ? [
                    'id' => (int) $event->user->id,
                    'name' => (string) $event->user->name,
                    'email' => (string) $event->user->email,
                ] : null,
                'context' => $context,
                'diff' => $this->buildDiffFromContext($context),
            ];
        })->values()->all();

        return response()->json([
            'data' => [
                'total' => count($timeline),
                'timeline' => $timeline,
            ],
        ]);
    }

}
