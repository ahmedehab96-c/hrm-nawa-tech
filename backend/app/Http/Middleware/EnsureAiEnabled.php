<?php

namespace App\Http\Middleware;

use App\Models\Company;
use Closure;
use Illuminate\Http\Request;
use Symfony\Component\HttpFoundation\Response;

class EnsureAiEnabled
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

        if (! $company->ai_enabled) {
            return response()->json(['message' => 'AI features are disabled for this company'], 403);
        }

        if (! in_array((string) $company->ai_plan, ['enterprise'], true)) {
            return response()->json(['message' => 'AI features require enterprise plan'], 403);
        }

        return $next($request);
    }
}
