<?php

namespace App\Http\Middleware;

use App\Models\AiUsageLog;
use App\Models\Company;
use App\Services\AiAuditService;
use Closure;
use Illuminate\Http\Request;
use Symfony\Component\HttpFoundation\Response;

class EnsureAiRollout
{
    public function handle(Request $request, Closure $next): Response
    {
        $user = $request->user();
        if (! $user) {
            return response()->json(['message' => 'Unauthenticated'], 401);
        }

        $company = Company::query()->find($user->company_id);
        if (! $company) {
            return response()->json(['message' => 'Company not found'], 404);
        }

        $rollout = max(0, min(100, (int) ($company->ai_rollout_percentage ?? 100)));
        if ($rollout >= 100) {
            return $next($request);
        }

        $bucket = abs(crc32(sprintf('%d:%d:%s', (int) $company->id, (int) $user->id, (string) $request->path()))) % 100;
        if ($bucket < $rollout) {
            return $next($request);
        }

        AiUsageLog::query()->create([
            'company_id' => $company->id,
            'user_id' => $user->id,
            'conversation_id' => null,
            'endpoint' => (string) $request->path(),
            'provider' => null,
            'model' => null,
            'latency_ms' => 0,
            'prompt_tokens' => 0,
            'completion_tokens' => 0,
            'total_tokens' => 0,
            'status' => 'blocked_rollout',
            'error_message' => "Rollout gate denied request ({$rollout}%)",
        ]);
        app(AiAuditService::class)->log(
            companyId: (int) $company->id,
            userId: (int) $user->id,
            eventType: 'ai_request_blocked_rollout',
            severity: 'warning',
            endpoint: (string) $request->path(),
            context: ['rollout_percentage' => $rollout],
        );

        return response()->json([
            'message' => 'This AI feature is in gradual rollout and is not enabled for this account yet',
            'rollout_percentage' => $rollout,
        ], 403);
    }
}
