<?php

use App\Http\Middleware\EnsureUserRole;
use App\Http\Middleware\EnsureUserPermission;
use App\Http\Middleware\EnsureAiEnabled;
use App\Http\Middleware\EnsureAiQuota;
use App\Http\Middleware\EnsureAiRollout;
use App\Http\Middleware\EnsureTrialActive;
use App\Http\Middleware\EnsureEmailVerified;
use App\Http\Middleware\SecurityHeaders;
use App\Http\Middleware\SetAdminLocale;
use Illuminate\Foundation\Application;
use Illuminate\Foundation\Configuration\Exceptions;
use Illuminate\Foundation\Configuration\Middleware;

return Application::configure(basePath: dirname(__DIR__))
    ->withRouting(
        web: __DIR__.'/../routes/web.php',
        api: __DIR__.'/../routes/api.php',
        commands: __DIR__.'/../routes/console.php',
        health: '/up',
    )
    ->withMiddleware(function (Middleware $middleware): void {
        // Security headers على كل الاستجابات
        $middleware->append(SecurityHeaders::class);

        $middleware->validateCsrfTokens(except: [
            'stripe/webhook',
            'moyasar/webhook',
        ]);

        $middleware->trustProxies(at: env('TRUSTED_PROXIES', '*'));

        $middleware->web(append: [
            SetAdminLocale::class,
        ]);

        $middleware->alias([
            'role' => EnsureUserRole::class,
            'permission' => EnsureUserPermission::class,
            'ai.enabled' => EnsureAiEnabled::class,
            'ai.quota' => EnsureAiQuota::class,
            'ai.rollout' => EnsureAiRollout::class,
            'trial' => EnsureTrialActive::class,
            'verified.api' => EnsureEmailVerified::class,
        ]);
    })
    ->withExceptions(function (Exceptions $exceptions): void {
        //
    })->create();
