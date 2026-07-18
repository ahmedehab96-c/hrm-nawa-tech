<?php

namespace App\Filament\Widgets;

use App\Models\AiUsageLog;
use App\Models\Company;
use App\Support\AdminTrans;
use Filament\Widgets\StatsOverviewWidget;
use Filament\Widgets\StatsOverviewWidget\Stat;

class AiUsageStats extends StatsOverviewWidget
{
    protected static ?int $sort = 1;

    protected int | string | array $columnSpan = 'full';

    protected function getStats(): array
    {
        $companyId = $this->companyId();
        $company = $companyId ? Company::query()->find($companyId) : null;

        $monthStart = now()->startOfMonth();
        $monthEnd = now()->endOfMonth();
        $todayStart = now()->startOfDay();
        $todayEnd = now()->endOfDay();

        $base = AiUsageLog::query()->when($companyId, fn ($q) => $q->where('company_id', $companyId));

        $monthlyTokens = (int) (clone $base)
            ->whereBetween('created_at', [$monthStart, $monthEnd])
            ->sum('total_tokens');
        $limit = (int) ($company?->ai_monthly_token_limit ?? 500000);
        $percent = $limit > 0 ? round(($monthlyTokens / $limit) * 100, 1) : 0;

        $requestsToday = (int) (clone $base)
            ->whereBetween('created_at', [$todayStart, $todayEnd])
            ->count();
        $errorsToday = (int) (clone $base)
            ->whereBetween('created_at', [$todayStart, $todayEnd])
            ->where('status', 'error')
            ->count();
        $avgLatency = (int) round((float) (clone $base)
            ->whereBetween('created_at', [$todayStart, $todayEnd])
            ->avg('latency_ms'));

        return [
            Stat::make(AdminTrans::widget('tokens_this_month'), number_format($monthlyTokens))
                ->description(AdminTrans::widget('limit_percent', [
                    'percent' => (string) $percent,
                    'limit' => number_format($limit),
                ]))
                ->icon('heroicon-o-cpu-chip'),
            Stat::make(AdminTrans::widget('requests_today'), (string) $requestsToday)
                ->description($company?->ai_enabled ? AdminTrans::widget('ai_enabled') : AdminTrans::widget('ai_disabled'))
                ->icon('heroicon-o-paper-airplane'),
            Stat::make(AdminTrans::widget('errors_today'), (string) $errorsToday)
                ->description(AdminTrans::widget('failed_ai_calls'))
                ->icon('heroicon-o-exclamation-circle'),
            Stat::make(AdminTrans::widget('avg_latency_today'), $avgLatency > 0 ? "{$avgLatency} ms" : '—')
                ->description(AdminTrans::widget('mean_response_time'))
                ->icon('heroicon-o-bolt'),
        ];
    }

    protected function companyId(): ?int
    {
        $user = auth()->user();
        if ($user === null || $user->hasRole('super_admin')) {
            return null;
        }

        return $user->company_id !== null ? (int) $user->company_id : null;
    }
}
