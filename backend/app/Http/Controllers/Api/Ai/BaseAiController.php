<?php

namespace App\Http\Controllers\Api\Ai;

use App\Http\Controllers\Controller;
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
use App\Services\AiAuditService;
use App\Services\AiEscalationService;
use App\Services\AiGatewayService;
use App\Services\AiPromptRegistryService;
use App\Services\PromptSafetyService;
use Illuminate\Support\Facades\DB;
use Illuminate\Http\Request;
use Illuminate\Support\Carbon;
use Throwable;

/**
 * Shared dependencies + helpers for the split AI API controllers.
 * Route behavior is preserved; enablement remains gated by ai.enabled /
 * ai.rollout / ai.quota middleware (AI is not flipped on here).
 */
abstract class BaseAiController extends Controller
{
    public function __construct(
        protected readonly AiGatewayService $aiGatewayService,
        protected readonly AiPromptRegistryService $aiPromptRegistryService,
        protected readonly AiAuditService $aiAuditService,
        protected readonly AiEscalationService $aiEscalationService,
        protected readonly PromptSafetyService $promptSafetyService,
    ) {}

    protected function resolveConversation(
        int $companyId,
        int $userId,
        ?int $conversationId,
        string $languageCode,
    ): AiConversation {
        if ($conversationId !== null) {
            $found = AiConversation::query()
                ->where('company_id', $companyId)
                ->where('id', $conversationId)
                ->first();
            if ($found) {
                return $found;
            }
        }

        return AiConversation::query()->create([
            'company_id' => $companyId,
            'user_id' => $userId,
            'language_code' => $languageCode,
            'provider' => null,
            'model' => null,
            'last_message_at' => Carbon::now(),
        ]);
    }

    protected function buildJobDescriptionPrompt(
        string $languageCode,
        string $title,
        string $department,
        string $location,
        string $employmentType,
        string $requirements,
        string $responsibilities,
        string $tone,
    ): string {
        $ar = str_starts_with($languageCode, 'ar');
        if ($ar) {
            return "أنشئ وصفاً وظيفياً احترافياً باللغة العربية.\n"
                ."المسمى: {$title}\n"
                ."القسم: ".($department !== '' ? $department : 'غير محدد')."\n"
                ."الموقع: ".($location !== '' ? $location : 'غير محدد')."\n"
                ."نوع التوظيف: ".($employmentType !== '' ? $employmentType : 'دوام كامل')."\n"
                ."النبرة: {$tone}\n"
                ."المتطلبات: ".($requirements !== '' ? $requirements : 'غير محددة')."\n"
                ."المهام: ".($responsibilities !== '' ? $responsibilities : 'غير محددة')."\n"
                ."النتيجة المطلوبة: أقسام واضحة تشمل نبذة، المسؤوليات، المتطلبات، المزايا، وتعليمات التقديم.";
        }

        return "Generate a professional job description in English.\n"
            ."Title: {$title}\n"
            ."Department: ".($department !== '' ? $department : 'Not specified')."\n"
            ."Location: ".($location !== '' ? $location : 'Not specified')."\n"
            ."Employment type: ".($employmentType !== '' ? $employmentType : 'Full-time')."\n"
            ."Tone: {$tone}\n"
            ."Requirements: ".($requirements !== '' ? $requirements : 'Not specified')."\n"
            ."Responsibilities: ".($responsibilities !== '' ? $responsibilities : 'Not specified')."\n"
            ."Return a structured draft with sections: Overview, Responsibilities, Requirements, Benefits, and Apply instructions.";
    }

    protected function buildCommunicationPrompt(
        string $languageCode,
        string $type,
        string $purpose,
        string $recipientName,
        string $employeeName,
        string $department,
        string $tone,
        string $keyPoints,
    ): string {
        $ar = str_starts_with($languageCode, 'ar');
        if ($ar) {
            return "أنشئ ".($type === 'letter' ? 'خطاباً' : 'بريداً إلكترونياً')." باللغة العربية بنبرة {$tone}.\n"
                ."الغرض: {$purpose}\n"
                ."اسم المستلم: ".($recipientName !== '' ? $recipientName : 'غير محدد')."\n"
                ."اسم الموظف: ".($employeeName !== '' ? $employeeName : 'غير محدد')."\n"
                ."القسم: ".($department !== '' ? $department : 'غير محدد')."\n"
                ."نقاط أساسية: ".($keyPoints !== '' ? $keyPoints : 'لا توجد')."\n"
                ."النتيجة: اكتب Subject واضح ثم Body منظم وجاهز للإرسال.";
        }

        return "Generate an HR ".($type === 'letter' ? 'letter' : 'email')." in English with {$tone} tone.\n"
            ."Purpose: {$purpose}\n"
            ."Recipient: ".($recipientName !== '' ? $recipientName : 'Not specified')."\n"
            ."Employee name: ".($employeeName !== '' ? $employeeName : 'Not specified')."\n"
            ."Department: ".($department !== '' ? $department : 'Not specified')."\n"
            ."Key points: ".($keyPoints !== '' ? $keyPoints : 'None')."\n"
            ."Output format: include a concise Subject and a ready-to-send Body.";
    }

    protected function logUsage(
        int $companyId,
        int $userId,
        ?int $conversationId,
        string $endpoint,
        string $provider,
        ?string $model,
        int $latencyMs,
        ?int $promptTokens,
        ?int $completionTokens,
        ?int $totalTokens,
        string $status,
        ?string $errorMessage,
    ): void {
        AiUsageLog::query()->create([
            'company_id' => $companyId,
            'user_id' => $userId,
            'conversation_id' => $conversationId,
            'endpoint' => $endpoint,
            'provider' => $provider,
            'model' => $model,
            'latency_ms' => $latencyMs,
            'prompt_tokens' => $promptTokens,
            'completion_tokens' => $completionTokens,
            'total_tokens' => $totalTokens,
            'status' => $status,
            'error_message' => $errorMessage,
        ]);
    }

    protected function estimateCostUsd(
        string $provider,
        string $model,
        int $promptTokens,
        int $completionTokens,
    ): float {
        $pricing = config('services.ai.pricing', []);
        $fallback = [
            'input_per_million' => 0.15,
            'output_per_million' => 0.6,
        ];

        $providerPricing = is_array($pricing[$provider] ?? null) ? $pricing[$provider] : [];
        $modelPricing = is_array($providerPricing[$model] ?? null) ? $providerPricing[$model] : [];
        $rates = array_merge($fallback, $modelPricing);

        $inputPerMillion = (float) ($rates['input_per_million'] ?? $fallback['input_per_million']);
        $outputPerMillion = (float) ($rates['output_per_million'] ?? $fallback['output_per_million']);

        $inputCost = ($promptTokens / 1_000_000) * $inputPerMillion;
        $outputCost = ($completionTokens / 1_000_000) * $outputPerMillion;

        return max(0, $inputCost + $outputCost);
    }

    protected function defaultSystemPromptForFeature(string $featureKey, string $languageCode): string
    {
        $ar = str_starts_with($languageCode, 'ar');

        return match ($featureKey) {
            'job_description' => $ar
                ? 'أنت خبير موارد بشرية. أنشئ وصفاً وظيفياً احترافياً واضحاً ومختصراً.'
                : 'You are an HR expert. Generate clear and professional job descriptions.',
            'communication' => $ar
                ? 'أنت كاتب اتصالات موارد بشرية. أنشئ رسائل رسمية دقيقة وجاهزة للإرسال.'
                : 'You are an HR communications writer. Generate concise and ready-to-send messages.',
            default => $ar
                ? 'أنت مساعد موارد بشرية لمنصة HRM. أعطِ إجابات عملية وقصيرة.'
                : 'You are an HR assistant for an HRM platform. Provide practical concise answers.',
        };
    }

    /**
     * @return array{
     *   alerts:array<int,array<string,mixed>>,
     *   policy:array<string,mixed>
     * }
     */
    protected function computeAlertSnapshot(Company $company, int $days): array
    {
        $from = now()->startOfDay()->subDays($days - 1);
        $to = now()->endOfDay();

        $logs = AiUsageLog::query()
            ->where('company_id', $company->id)
            ->whereBetween('created_at', [$from, $to])
            ->get(['status', 'latency_ms', 'created_at']);
        $today = now()->toDateString();
        $todayRequests = 0;
        $todayErrors = 0;
        $allLatencies = [];
        foreach ($logs as $log) {
            $day = $log->created_at?->toDateString();
            if ($day === $today) {
                $todayRequests++;
                if ((string) $log->status === 'error') {
                    $todayErrors++;
                }
            }
            if ($log->latency_ms !== null && $log->latency_ms > 0) {
                $allLatencies[] = (int) $log->latency_ms;
            }
        }
        sort($allLatencies);
        $p95Overall = $this->percentile($allLatencies, 0.95);
        $todayErrorRate = $todayRequests > 0 ? round(($todayErrors / $todayRequests) * 100, 2) : 0;

        $queueFailures = (int) AiTask::query()
            ->where('company_id', $company->id)
            ->whereBetween('created_at', [$from, $to])
            ->where('status', 'failed')
            ->count();

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
            ];
        }
        if ($p95Overall > $policy['p95_latency_ms_threshold']) {
            $alerts[] = [
                'code' => 'high_p95_latency',
                'level' => 'warning',
                'value' => $p95Overall,
                'threshold' => $policy['p95_latency_ms_threshold'],
            ];
        }
        if ($queueFailures > $policy['queue_failure_threshold']) {
            $alerts[] = [
                'code' => 'queue_failures',
                'level' => 'critical',
                'value' => $queueFailures,
                'threshold' => $policy['queue_failure_threshold'],
            ];
        }

        return [
            'alerts' => $alerts,
            'policy' => $policy,
        ];
    }

    /**
     * @return array<string,mixed>
     */
    protected function companyAiState(Company $company): array
    {
        $flags = is_array($company->ai_feature_flags) ? $company->ai_feature_flags : [];

        return [
            'ai_provider' => (string) ($company->ai_provider ?? 'openai'),
            'ai_safety_level' => (string) ($company->ai_safety_level ?? 'standard'),
            'ai_rollout_percentage' => (int) ($company->ai_rollout_percentage ?? 100),
            'ai_feature_flags' => $flags,
        ];
    }

    /**
     * @param  array<string,mixed>  $state
     */
    protected function applyRemediationAction(array &$state, string $actionId): void
    {
        $flags = is_array($state['ai_feature_flags'] ?? null) ? $state['ai_feature_flags'] : [];

        if ($actionId === 'tighten_safety') {
            $state['ai_safety_level'] = 'strict';
        } elseif ($actionId === 'reduce_rollout_50') {
            $state['ai_rollout_percentage'] = min((int) ($state['ai_rollout_percentage'] ?? 100), 50);
        } elseif ($actionId === 'disable_recruitment_ai') {
            $flags['recruitment_parse'] = false;
            $flags['recruitment_match'] = false;
        } elseif ($actionId === 'switch_provider_openai') {
            $state['ai_provider'] = 'openai';
        } elseif ($actionId === 'switch_provider_gemini') {
            $state['ai_provider'] = 'gemini';
        }

        $state['ai_feature_flags'] = $flags;
    }

    /**
     * @return array{
     *   request_count:int,
     *   error_count:int,
     *   error_rate_percent:float,
     *   p95_latency_ms:int
     * }
     */
    protected function computeWindowStats(int $companyId, Carbon $from, Carbon $to): array
    {
        $logs = AiUsageLog::query()
            ->where('company_id', $companyId)
            ->whereBetween('created_at', [$from, $to])
            ->get(['status', 'latency_ms']);

        $requestCount = $logs->count();
        $errorCount = $logs->where('status', 'error')->count();
        $errorRate = $requestCount > 0 ? round(($errorCount / $requestCount) * 100, 2) : 0.0;

        $latencies = $logs
            ->pluck('latency_ms')
            ->filter(fn ($v) => $v !== null && (int) $v > 0)
            ->map(fn ($v) => (int) $v)
            ->values()
            ->all();
        sort($latencies);

        return [
            'request_count' => (int) $requestCount,
            'error_count' => (int) $errorCount,
            'error_rate_percent' => (float) $errorRate,
            'p95_latency_ms' => $this->percentile($latencies, 0.95),
        ];
    }

    /**
     * @return array<string,array<string,mixed>>
     */
    protected function resolveEscalationMatrix(Company $company): array
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
            if (! is_string($level) || ! is_array($item)) {
                continue;
            }
            if (array_key_exists($level, $defaults)) {
                $defaults[$level] = array_merge($defaults[$level], $item);
                if (! is_array($defaults[$level]['recipients'] ?? null)) {
                    $defaults[$level]['recipients'] = [];
                }
            }
        }

        return $defaults;
    }

    /**
     * @return array<string,string>
     */
    protected function resolveRunbookLinks(Company $company): array
    {
        $links = is_array($company->ai_runbook_links) ? $company->ai_runbook_links : [];
        $defaults = [
            'high_error_rate' => 'https://runbooks.example.com/ai/high-error-rate',
            'high_p95_latency' => 'https://runbooks.example.com/ai/high-latency',
            'queue_failures' => 'https://runbooks.example.com/ai/queue-failures',
            'slo_burn_rate_1h' => 'https://runbooks.example.com/ai/slo-burn-rate',
            'slo_burn_rate_24h' => 'https://runbooks.example.com/ai/slo-burn-rate',
            'default' => 'https://runbooks.example.com/ai/general',
        ];

        foreach ($links as $key => $value) {
            if (is_string($key) && is_string($value) && trim($value) !== '') {
                $defaults[$key] = trim($value);
            }
        }

        return $defaults;
    }

    /**
     * @return array<int,array<string,mixed>>
     */
    protected function resolveSilenceWindows(Company $company): array
    {
        $windows = is_array($company->ai_silence_windows) ? $company->ai_silence_windows : [];
        $items = [];
        foreach ($windows as $window) {
            if (! is_array($window)) {
                continue;
            }
            $items[] = [
                'name' => (string) ($window['name'] ?? 'window'),
                'days' => array_values(array_map('intval', is_array($window['days'] ?? null) ? $window['days'] : [])),
                'start' => (string) ($window['start'] ?? '00:00'),
                'end' => (string) ($window['end'] ?? '00:00'),
            ];
        }

        return $items;
    }

    protected function selectEscalationLevel(string $alertCode, string $severity): string
    {
        if ($severity === 'critical') {
            return 'l3';
        }
        if ($alertCode === 'queue_failures' || $alertCode === 'slo_burn_rate_1h') {
            return 'l2';
        }

        return 'l1';
    }

    /**
     * @param  array<string,mixed>  $context
     * @return array<int,array<string,mixed>>
     */
    protected function buildDiffFromContext(array $context): array
    {
        if (! is_array($context['before'] ?? null) || ! is_array($context['after'] ?? null)) {
            return [];
        }
        $before = (array) $context['before'];
        $after = (array) $context['after'];
        $keys = array_values(array_unique(array_merge(array_keys($before), array_keys($after))));
        $diff = [];
        foreach ($keys as $key) {
            $old = $before[$key] ?? null;
            $new = $after[$key] ?? null;
            if ($old !== $new) {
                $diff[] = [
                    'field' => (string) $key,
                    'before' => $old,
                    'after' => $new,
                ];
            }
        }

        return $diff;
    }

    protected function percentile(array $sortedSamples, float $p): int
    {
        if (empty($sortedSamples)) {
            return 0;
        }
        $count = count($sortedSamples);
        $index = (int) ceil($p * $count) - 1;
        $index = max(0, min($count - 1, $index));
        return (int) $sortedSamples[$index];
    }
}
