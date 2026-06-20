<?php

namespace App\Http\Middleware;

use App\Models\AiUsageLog;
use App\Models\Company;
use App\Services\AiAuditService;
use Closure;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Cache;
use Symfony\Component\HttpFoundation\Response;

class EnsureAiQuota
{
    public function handle(Request $request, Closure $next, ?string $feature = null): Response
    {
        $user = $request->user();
        if (! $user) {
            return response()->json(['message' => 'Unauthenticated'], 401);
        }

        $company = Company::query()->find($user->company_id);
        if (! $company) {
            return response()->json(['message' => 'Company not found'], 404);
        }

        if ($feature !== null && ! $this->featureEnabled($company, $feature)) {
            $this->logBlocked($company->id, $user->id, (string) $request->path(), 'blocked_feature_flag', "Feature '{$feature}' disabled");
            return response()->json([
                'message' => "AI feature '{$feature}' is disabled for this company",
            ], 403);
        }

        $rpmLimit = max(1, (int) ($company->ai_requests_per_minute ?? 60));
        $rpmKey = sprintf(
            'ai:rpm:%d:%d:%s',
            (int) $company->id,
            (int) $user->id,
            now()->format('YmdHi')
        );
        if (! Cache::has($rpmKey)) {
            Cache::put($rpmKey, 0, now()->addMinute());
        }
        $currentRpm = (int) Cache::increment($rpmKey);
        if ($currentRpm > $rpmLimit) {
            $this->logBlocked($company->id, $user->id, (string) $request->path(), 'blocked_rpm_quota', "RPM limit {$rpmLimit} exceeded");
            return response()->json([
                'message' => 'AI rate limit exceeded for this minute',
                'limit_per_minute' => $rpmLimit,
            ], 429);
        }

        $monthlyLimit = max(1000, (int) ($company->ai_monthly_token_limit ?? 500000));
        $usedTokens = (int) AiUsageLog::query()
            ->where('company_id', $company->id)
            ->whereBetween('created_at', [now()->startOfMonth(), now()->endOfMonth()])
            ->sum('total_tokens');
        if ($usedTokens >= $monthlyLimit) {
            $this->logBlocked($company->id, $user->id, (string) $request->path(), 'blocked_monthly_quota', "Monthly token limit {$monthlyLimit} exceeded");
            return response()->json([
                'message' => 'AI monthly token quota exceeded',
                'monthly_token_limit' => $monthlyLimit,
                'monthly_tokens_used' => $usedTokens,
            ], 429);
        }

        return $next($request);
    }

    private function featureEnabled(Company $company, string $feature): bool
    {
        $flags = $company->ai_feature_flags;
        if (! is_array($flags) || empty($flags)) {
            return true;
        }

        return ($flags[$feature] ?? true) === true;
    }

    private function logBlocked(
        int $companyId,
        int $userId,
        string $endpoint,
        string $status,
        string $error,
    ): void {
        AiUsageLog::query()->create([
            'company_id' => $companyId,
            'user_id' => $userId,
            'conversation_id' => null,
            'endpoint' => $endpoint,
            'provider' => null,
            'model' => null,
            'latency_ms' => 0,
            'prompt_tokens' => 0,
            'completion_tokens' => 0,
            'total_tokens' => 0,
            'status' => $status,
            'error_message' => $error,
        ]);
        app(AiAuditService::class)->log(
            companyId: $companyId,
            userId: $userId,
            eventType: $status,
            severity: 'warning',
            endpoint: $endpoint,
            context: ['error' => $error],
        );
    }
}
