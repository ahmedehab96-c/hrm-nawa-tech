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

class UsageController extends BaseAiController
{
    public function usage(Request $request)
    {
        $user = $request->user();
        $company = Company::query()->find($user->company_id);
        if (! $company) {
            return response()->json(['message' => 'Company not found'], 404);
        }

        $monthStart = now()->startOfMonth();
        $monthEnd = now()->endOfMonth();
        $todayStart = now()->startOfDay();
        $todayEnd = now()->endOfDay();

        $monthlyTokensUsed = (int) AiUsageLog::query()
            ->where('company_id', $company->id)
            ->whereBetween('created_at', [$monthStart, $monthEnd])
            ->sum('total_tokens');
        $monthlyLimit = (int) ($company->ai_monthly_token_limit ?? 500000);

        $requestsToday = (int) AiUsageLog::query()
            ->where('company_id', $company->id)
            ->whereBetween('created_at', [$todayStart, $todayEnd])
            ->count();
        $errorsToday = (int) AiUsageLog::query()
            ->where('company_id', $company->id)
            ->whereBetween('created_at', [$todayStart, $todayEnd])
            ->where('status', 'error')
            ->count();

        $byEndpoint = AiUsageLog::query()
            ->where('company_id', $company->id)
            ->whereBetween('created_at', [$monthStart, $monthEnd])
            ->select('endpoint', DB::raw('COUNT(*) as requests'), DB::raw('COALESCE(SUM(total_tokens),0) as tokens'))
            ->groupBy('endpoint')
            ->orderByDesc('requests')
            ->get()
            ->map(fn ($row) => [
                'endpoint' => (string) $row->endpoint,
                'requests' => (int) $row->requests,
                'tokens' => (int) $row->tokens,
            ])
            ->values()
            ->all();

        $monthLogs = AiUsageLog::query()
            ->where('company_id', $company->id)
            ->whereBetween('created_at', [$monthStart, $monthEnd])
            ->get(['provider', 'model', 'prompt_tokens', 'completion_tokens']);
        $todayLogs = AiUsageLog::query()
            ->where('company_id', $company->id)
            ->whereBetween('created_at', [$todayStart, $todayEnd])
            ->get(['provider', 'model', 'prompt_tokens', 'completion_tokens']);

        $monthlyCostUsd = 0.0;
        $dailyCostUsd = 0.0;
        $costByProvider = [];
        $costByModel = [];

        foreach ($monthLogs as $log) {
            $cost = $this->estimateCostUsd(
                provider: (string) ($log->provider ?? ''),
                model: (string) ($log->model ?? ''),
                promptTokens: (int) ($log->prompt_tokens ?? 0),
                completionTokens: (int) ($log->completion_tokens ?? 0),
            );
            $monthlyCostUsd += $cost;

            $provider = (string) ($log->provider ?? 'unknown');
            $model = (string) ($log->model ?? 'unknown');
            $costByProvider[$provider] = round(($costByProvider[$provider] ?? 0) + $cost, 6);
            $costByModel[$model] = round(($costByModel[$model] ?? 0) + $cost, 6);
        }

        foreach ($todayLogs as $log) {
            $dailyCostUsd += $this->estimateCostUsd(
                provider: (string) ($log->provider ?? ''),
                model: (string) ($log->model ?? ''),
                promptTokens: (int) ($log->prompt_tokens ?? 0),
                completionTokens: (int) ($log->completion_tokens ?? 0),
            );
        }

        return response()->json([
            'data' => [
                'monthly_tokens_used' => $monthlyTokensUsed,
                'monthly_token_limit' => $monthlyLimit,
                'monthly_usage_percent' => $monthlyLimit > 0
                    ? round(($monthlyTokensUsed / $monthlyLimit) * 100, 2)
                    : 0,
                'requests_today' => $requestsToday,
                'errors_today' => $errorsToday,
                'estimated_cost_month_usd' => round($monthlyCostUsd, 4),
                'estimated_cost_today_usd' => round($dailyCostUsd, 4),
                'requests_per_minute_limit' => (int) ($company->ai_requests_per_minute ?? 60),
                'feature_flags' => is_array($company->ai_feature_flags) ? $company->ai_feature_flags : [],
                'by_endpoint' => $byEndpoint,
                'cost_by_provider' => $costByProvider,
                'cost_by_model' => $costByModel,
            ],
        ]);
    }

    public function observability(Request $request)
    {
        $user = $request->user();
        $company = Company::query()->find($user->company_id);
        if (! $company) {
            return response()->json(['message' => 'Company not found'], 404);
        }

        $days = max(1, min(90, (int) $request->query('days', 14)));
        $from = now()->startOfDay()->subDays($days - 1);
        $to = now()->endOfDay();

        $logs = AiUsageLog::query()
            ->where('company_id', $company->id)
            ->whereBetween('created_at', [$from, $to])
            ->get(['endpoint', 'status', 'latency_ms', 'created_at']);

        $daily = [];
        $endpointLatencies = [];
        $blockedCounts = [];
        foreach ($logs as $log) {
            $day = $log->created_at?->toDateString() ?? now()->toDateString();
            if (! isset($daily[$day])) {
                $daily[$day] = [
                    'date' => $day,
                    'requests' => 0,
                    'errors' => 0,
                    'blocked' => 0,
                    'latency_samples' => [],
                ];
            }

            $daily[$day]['requests']++;
            $status = (string) ($log->status ?? 'success');
            if ($status === 'error') {
                $daily[$day]['errors']++;
            }
            if (str_starts_with($status, 'blocked_')) {
                $daily[$day]['blocked']++;
                $blockedCounts[$status] = (int) ($blockedCounts[$status] ?? 0) + 1;
            }

            if ($log->latency_ms !== null && $log->latency_ms > 0) {
                $latency = (int) $log->latency_ms;
                $daily[$day]['latency_samples'][] = $latency;
                $endpoint = (string) ($log->endpoint ?? 'unknown');
                $endpointLatencies[$endpoint] ??= [];
                $endpointLatencies[$endpoint][] = $latency;
            }
        }

        ksort($daily);
        $dailyList = [];
        foreach ($daily as $item) {
            $samples = $item['latency_samples'];
            $avg = count($samples) > 0 ? (int) round(array_sum($samples) / count($samples)) : 0;
            unset($item['latency_samples']);
            $item['avg_latency_ms'] = $avg;
            $dailyList[] = $item;
        }

        $latencyByEndpoint = collect($endpointLatencies)
            ->map(function (array $samples, string $endpoint) {
                sort($samples);
                return [
                    'endpoint' => $endpoint,
                    'p95_latency_ms' => $this->percentile($samples, 0.95),
                    'avg_latency_ms' => (int) round(array_sum($samples) / max(1, count($samples))),
                ];
            })
            ->values()
            ->all();

        $queueRows = AiTask::query()
            ->where('company_id', $company->id)
            ->whereBetween('created_at', [$from, $to])
            ->get(['status', 'created_at', 'started_at', 'finished_at']);
        $queueStats = [
            'queued' => 0,
            'processing' => 0,
            'completed' => 0,
            'failed' => 0,
            'avg_duration_ms' => 0,
        ];
        $durations = [];
        foreach ($queueRows as $row) {
            $status = (string) ($row->status ?? 'queued');
            if (array_key_exists($status, $queueStats)) {
                $queueStats[$status]++;
            }
            if ($row->started_at && $row->finished_at) {
                $durations[] = (int) $row->finished_at->diffInMilliseconds($row->started_at);
            }
        }
        if (! empty($durations)) {
            $queueStats['avg_duration_ms'] = (int) round(array_sum($durations) / count($durations));
        }

        $today = now()->toDateString();
        $todayPoint = collect($dailyList)->firstWhere('date', $today);
        $todayRequests = (int) ($todayPoint['requests'] ?? 0);
        $todayErrors = (int) ($todayPoint['errors'] ?? 0);
        $todayErrorRate = $todayRequests > 0 ? round(($todayErrors / $todayRequests) * 100, 2) : 0;

        $allLatencies = [];
        foreach ($endpointLatencies as $samples) {
            foreach ($samples as $sample) {
                $allLatencies[] = (int) $sample;
            }
        }
        sort($allLatencies);
        $p95Overall = $this->percentile($allLatencies, 0.95);

        $policy = [
            'error_rate_threshold' => (float) ($company->ai_alert_error_rate_threshold ?? 5.0),
            'p95_latency_ms_threshold' => (int) ($company->ai_alert_p95_latency_ms_threshold ?? 2500),
            'queue_failure_threshold' => (int) ($company->ai_alert_queue_failure_threshold ?? 3),
        ];
        $alerts = [];
        if ($todayErrorRate > $policy['error_rate_threshold']) {
            $alerts[] = [
                'code' => 'high_error_rate',
                'level' => 'warning',
                'value' => $todayErrorRate,
                'threshold' => $policy['error_rate_threshold'],
                'message' => 'Today error rate exceeded configured threshold',
            ];
        }
        if ($p95Overall > $policy['p95_latency_ms_threshold']) {
            $alerts[] = [
                'code' => 'high_p95_latency',
                'level' => 'warning',
                'value' => $p95Overall,
                'threshold' => $policy['p95_latency_ms_threshold'],
                'message' => 'Overall p95 latency exceeded configured threshold',
            ];
        }
        if ((int) $queueStats['failed'] > $policy['queue_failure_threshold']) {
            $alerts[] = [
                'code' => 'queue_failures',
                'level' => 'critical',
                'value' => (int) $queueStats['failed'],
                'threshold' => $policy['queue_failure_threshold'],
                'message' => 'Queue failures exceeded configured threshold',
            ];
        }

        return response()->json([
            'data' => [
                'range_days' => $days,
                'daily' => $dailyList,
                'latency_by_endpoint' => $latencyByEndpoint,
                'queue' => $queueStats,
                'blocked' => $blockedCounts,
                'alerts' => $alerts,
                'policies' => $policy,
            ],
        ]);
    }

    public function canary(Request $request)
    {
        $company = Company::query()->find($request->user()->company_id);
        if (! $company) {
            return response()->json(['message' => 'Company not found'], 404);
        }

        $days = max(1, min(90, (int) $request->query('days', 14)));
        $from = now()->startOfDay()->subDays($days - 1);
        $to = now()->endOfDay();

        $logs = AiUsageLog::query()
            ->where('company_id', $company->id)
            ->whereBetween('created_at', [$from, $to])
            ->whereNotNull('provider')
            ->get(['provider', 'model', 'status', 'latency_ms', 'prompt_tokens', 'completion_tokens']);

        $groups = [];
        foreach ($logs as $log) {
            $provider = (string) ($log->provider ?? 'unknown');
            $model = (string) ($log->model ?? 'unknown');
            $key = "{$provider}:{$model}";
            if (! isset($groups[$key])) {
                $groups[$key] = [
                    'provider' => $provider,
                    'model' => $model,
                    'requests' => 0,
                    'success' => 0,
                    'error' => 0,
                    'blocked' => 0,
                    'latency_sum' => 0,
                    'latency_count' => 0,
                    'cost_sum' => 0.0,
                ];
            }

            $groups[$key]['requests']++;
            $status = (string) ($log->status ?? 'success');
            if ($status === 'success') {
                $groups[$key]['success']++;
            } elseif ($status === 'error') {
                $groups[$key]['error']++;
            } elseif (str_starts_with($status, 'blocked_')) {
                $groups[$key]['blocked']++;
            }

            if ($log->latency_ms !== null && $log->latency_ms > 0) {
                $groups[$key]['latency_sum'] += (int) $log->latency_ms;
                $groups[$key]['latency_count']++;
            }
            $groups[$key]['cost_sum'] += $this->estimateCostUsd(
                provider: $provider,
                model: $model,
                promptTokens: (int) ($log->prompt_tokens ?? 0),
                completionTokens: (int) ($log->completion_tokens ?? 0),
            );
        }

        $variants = collect($groups)
            ->map(function (array $row) {
                $requests = max(1, (int) $row['requests']);
                $successRate = round(((int) $row['success'] / $requests) * 100, 2);
                $avgLatency = (int) ($row['latency_count'] > 0
                    ? round((int) $row['latency_sum'] / (int) $row['latency_count'])
                    : 0);
                $avgCost = round((float) $row['cost_sum'] / $requests, 6);

                return [
                    'provider' => (string) $row['provider'],
                    'model' => (string) $row['model'],
                    'requests' => (int) $row['requests'],
                    'success' => (int) $row['success'],
                    'error' => (int) $row['error'],
                    'blocked' => (int) $row['blocked'],
                    'success_rate_percent' => $successRate,
                    'avg_latency_ms' => $avgLatency,
                    'avg_cost_usd' => $avgCost,
                ];
            })
            ->sortByDesc('success_rate_percent')
            ->sortBy('avg_latency_ms')
            ->values()
            ->all();

        return response()->json([
            'data' => [
                'range_days' => $days,
                'variants' => $variants,
                'recommended' => $variants[0] ?? null,
            ],
        ]);
    }

    public function sloReport(Request $request)
    {
        $user = $request->user();
        $company = Company::query()->find($user->company_id);
        if (! $company) {
            return response()->json(['message' => 'Company not found'], 404);
        }

        $targetSuccessRate = (float) ($company->ai_slo_target_success_rate ?? 99.5);
        $burnRateThreshold = (float) ($company->ai_burn_rate_alert_threshold ?? 2.0);
        $errorBudgetPercent = max(0.01, 100 - $targetSuccessRate);

        $now = now();
        $lastHour = $this->computeWindowStats(
            companyId: (int) $company->id,
            from: $now->copy()->subHour(),
            to: $now,
        );
        $lastDay = $this->computeWindowStats(
            companyId: (int) $company->id,
            from: $now->copy()->subDay(),
            to: $now,
        );

        $burn1h = round(($lastHour['error_rate_percent'] / $errorBudgetPercent), 2);
        $burn24h = round(($lastDay['error_rate_percent'] / $errorBudgetPercent), 2);
        $alerts = [];
        if ($burn1h > $burnRateThreshold) {
            $alerts[] = [
                'code' => 'slo_burn_rate_1h',
                'level' => 'critical',
                'value' => $burn1h,
                'threshold' => $burnRateThreshold,
                'message' => '1h SLO burn-rate exceeded threshold',
            ];
        }
        if ($burn24h > $burnRateThreshold) {
            $alerts[] = [
                'code' => 'slo_burn_rate_24h',
                'level' => 'warning',
                'value' => $burn24h,
                'threshold' => $burnRateThreshold,
                'message' => '24h SLO burn-rate exceeded threshold',
            ];
        }

        $autoDispatch = $request->boolean('dispatch', false);
        $autoDispatchResult = null;
        if ($autoDispatch && ! empty($alerts)) {
            $first = $alerts[0];
            $alertCode = (string) ($first['code'] ?? 'slo_burn_rate_24h');
            $severity = (string) ($first['level'] ?? 'warning');
            $channels = is_array($company->ai_alert_channels) ? array_values($company->ai_alert_channels) : ['in_app'];
            $level = $this->selectEscalationLevel($alertCode, $severity);
            $matrix = $this->resolveEscalationMatrix($company);
            $recipients = (array) ($matrix[$level]['recipients'] ?? []);
            $policy = (string) ($matrix[$level]['policy'] ?? 'notify_now');
            $queued = $this->aiEscalationService->queueNotifications(
                company: $company,
                triggeredByUserId: (int) $user->id,
                alertCode: $alertCode,
                severity: $severity,
                level: $level,
                policy: $policy,
                message: "SLO alert auto-escalation for {$alertCode}",
                channels: $channels,
                recipients: $recipients,
            );
            $autoDispatchResult = [
                'alert_code' => $alertCode,
                'severity' => $severity,
                'queued_notifications' => count($queued),
            ];
        }

        return response()->json([
            'data' => [
                'slo_target_success_rate' => $targetSuccessRate,
                'error_budget_percent' => round($errorBudgetPercent, 2),
                'burn_rate_threshold' => $burnRateThreshold,
                'windows' => [
                    'last_1h' => array_merge($lastHour, ['burn_rate' => $burn1h]),
                    'last_24h' => array_merge($lastDay, ['burn_rate' => $burn24h]),
                ],
                'alerts' => $alerts,
                'escalation_recommendation' => [
                    'level' => ! empty($alerts) ? $this->selectEscalationLevel(
                        alertCode: (string) ($alerts[0]['code'] ?? 'slo_burn_rate_24h'),
                        severity: (string) ($alerts[0]['level'] ?? 'warning'),
                    ) : 'none',
                    'channels' => is_array($company->ai_alert_channels) ? array_values($company->ai_alert_channels) : ['in_app'],
                ],
                'auto_dispatch' => $autoDispatchResult,
            ],
        ]);
    }

    public function costAnomalies(Request $request)
    {
        $validated = $request->validate([
            'days' => 'nullable|integer|min:14|max:90',
        ]);
        $company = Company::query()->find($request->user()->company_id);
        if (! $company) {
            return response()->json(['message' => 'Company not found'], 404);
        }

        $days = (int) ($validated['days'] ?? 35);
        $multiplier = (float) ($company->ai_cost_anomaly_multiplier ?? 2.0);
        $from = now()->startOfDay()->subDays($days - 1);
        $to = now()->endOfDay();

        $logs = AiUsageLog::query()
            ->where('company_id', $company->id)
            ->whereBetween('created_at', [$from, $to])
            ->get(['provider', 'model', 'prompt_tokens', 'completion_tokens', 'created_at']);

        $dailyCost = [];
        foreach ($logs as $log) {
            $day = $log->created_at?->toDateString() ?? now()->toDateString();
            $cost = $this->estimateCostUsd(
                provider: (string) ($log->provider ?? ''),
                model: (string) ($log->model ?? ''),
                promptTokens: (int) ($log->prompt_tokens ?? 0),
                completionTokens: (int) ($log->completion_tokens ?? 0),
            );
            $dailyCost[$day] = round((float) ($dailyCost[$day] ?? 0.0) + $cost, 6);
        }

        $today = now()->toDateString();
        $todayCost = (float) ($dailyCost[$today] ?? 0.0);
        $trailingValues = [];
        for ($i = 1; $i <= 7; $i++) {
            $d = now()->copy()->subDays($i)->toDateString();
            $trailingValues[] = (float) ($dailyCost[$d] ?? 0.0);
        }
        $trailingAvg = count($trailingValues) > 0 ? (array_sum($trailingValues) / count($trailingValues)) : 0.0;
        $dailyThreshold = $trailingAvg * $multiplier;
        $dailyAnomaly = $trailingAvg > 0 && $todayCost > $dailyThreshold;

        $currentWeekStart = now()->startOfWeek();
        $currentWeekValues = [];
        for ($d = $currentWeekStart->copy(); $d->lte(now()); $d->addDay()) {
            $currentWeekValues[] = (float) ($dailyCost[$d->toDateString()] ?? 0.0);
        }
        $currentWeekAvg = count($currentWeekValues) > 0 ? (array_sum($currentWeekValues) / count($currentWeekValues)) : 0.0;

        $prevWeeksValues = [];
        for ($i = 7; $i <= 34; $i++) {
            $d = now()->copy()->subDays($i)->toDateString();
            $prevWeeksValues[] = (float) ($dailyCost[$d] ?? 0.0);
        }
        $prevWeeksAvg = count($prevWeeksValues) > 0 ? (array_sum($prevWeeksValues) / count($prevWeeksValues)) : 0.0;
        $weeklyThreshold = $prevWeeksAvg * $multiplier;
        $weeklyAnomaly = $prevWeeksAvg > 0 && $currentWeekAvg > $weeklyThreshold;

        $recommendations = [];
        if ($dailyAnomaly || $weeklyAnomaly) {
            $recommendations[] = 'Run canary and switch to lower-cost model if quality is stable';
            $recommendations[] = 'Reduce rollout percentage temporarily for high-cost AI features';
            $recommendations[] = 'Tighten prompt templates to reduce output token size';
        }

        ksort($dailyCost);
        $series = collect($dailyCost)
            ->map(fn (float $cost, string $date) => ['date' => $date, 'cost_usd' => round($cost, 4)])
            ->values()
            ->all();

        return response()->json([
            'data' => [
                'range_days' => $days,
                'multiplier' => $multiplier,
                'daily' => [
                    'today_cost_usd' => round($todayCost, 4),
                    'trailing_7d_avg_usd' => round($trailingAvg, 4),
                    'threshold_usd' => round($dailyThreshold, 4),
                    'is_anomaly' => $dailyAnomaly,
                ],
                'weekly' => [
                    'current_week_avg_daily_cost_usd' => round($currentWeekAvg, 4),
                    'prev_4w_avg_daily_cost_usd' => round($prevWeeksAvg, 4),
                    'threshold_usd' => round($weeklyThreshold, 4),
                    'is_anomaly' => $weeklyAnomaly,
                ],
                'recommendations' => $recommendations,
                'series' => $series,
            ],
        ]);
    }

}
