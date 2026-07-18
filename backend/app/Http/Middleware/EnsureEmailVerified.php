<?php

namespace App\Http\Middleware;

use Closure;
use Illuminate\Http\Request;
use Symfony\Component\HttpFoundation\Response;

class EnsureEmailVerified
{
    public function handle(Request $request, Closure $next): Response
    {
        $user = $request->user();
        if (! $user) {
            return $next($request);
        }

        if ($user->hasVerifiedEmail()) {
            return $next($request);
        }

        // Allow verification + logout while unverified.
        if ($request->isMethod('POST') && (
            $request->is('api/email/verification-notification')
            || $request->is('api/logout')
        )) {
            return $next($request);
        }

        if ($request->isMethod('GET') && $request->is('api/auth/me')) {
            return $next($request);
        }

        return response()->json([
            'message' => 'Please verify your email to continue.',
            'code' => 'email_unverified',
        ], 403);
    }
}
