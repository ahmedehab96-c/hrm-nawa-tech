<?php

namespace App\Filament\Widgets;

use App\Services\PlatformOverviewService;
use App\Support\AdminTrans;
use Filament\Widgets\StatsOverviewWidget;
use Filament\Widgets\StatsOverviewWidget\Stat;

class PlatformStats extends StatsOverviewWidget
{
    protected static ?int $sort = 1;

    public static function canView(): bool
    {
        return auth()->user()?->hasRole('super_admin') ?? false;
    }

    protected function getStats(): array
    {
        $m = app(PlatformOverviewService::class)->metrics();

        return [
            Stat::make(AdminTrans::widget('companies'), (string) $m['companies'])
                ->icon('heroicon-o-building-office-2'),
            Stat::make(AdminTrans::widget('users'), (string) $m['users'])
                ->icon('heroicon-o-user-group'),
            Stat::make(AdminTrans::widget('employees'), (string) $m['employees'])
                ->icon('heroicon-o-users'),
            Stat::make(AdminTrans::widget('active_trials'), (string) $m['trials_active'])
                ->description(AdminTrans::widget('expired_count', ['count' => (string) $m['trials_expired']]))
                ->icon('heroicon-o-clock'),
            Stat::make(AdminTrans::widget('paid_plans'), (string) $m['paid_plans'])
                ->description(AdminTrans::widget('suspended_count', ['count' => (string) $m['suspended']]))
                ->icon('heroicon-o-credit-card'),
        ];
    }
}
