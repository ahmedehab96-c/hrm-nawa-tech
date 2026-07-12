<?php

namespace App\Http\Middleware;

use App\Models\Company;
use Closure;
use Illuminate\Http\Request;
use Symfony\Component\HttpFoundation\Response;

class EnsureTrialActive
{
    public function handle(Request $request, Closure $next): Response
    {
        $user = $request->user();
        if (! $user || ! $user->company_id) {
            return $next($request);
        }

        // Allow reading company profile so the client can show trial expiry UI.
        if ($request->isMethod('GET') && $request->is('api/company')) {
            return $next($request);
        }

        $company = Company::query()->find($user->company_id);
        if (! $company) {
            return $next($request);
        }

        if ((string) $company->status === 'suspended') {
            return response()->json([
                'message' => 'This company account has been suspended.',
                'code' => 'company_suspended',
            ], 403);
        }

        // Paid / active plans skip trial expiry.
        if (in_array((string) $company->plan, ['active', 'enterprise', 'pro', 'starter', 'growth'], true)) {
            return $next($request);
        }

        if ($company->trial_ends_at && $company->trial_ends_at->isPast()) {
            return response()->json([
                'message' => 'Your free trial has expired. Upgrade to continue.',
                'code' => 'trial_expired',
                'trial_ends_at' => $company->trial_ends_at->toIso8601String(),
                'plan' => $company->plan,
            ], 403);
        }

        return $next($request);
    }
}
