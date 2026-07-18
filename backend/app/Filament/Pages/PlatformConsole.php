<?php

namespace App\Filament\Pages;

use App\Filament\Resources\Companies\CompanyResource;
use App\Filament\Widgets\PlatformStats;
use App\Filament\Widgets\RecentCompaniesWidget;
use App\Support\AdminTrans;
use BackedEnum;
use Filament\Pages\Page;
use Filament\Support\Icons\Heroicon;
use UnitEnum;

class PlatformConsole extends Page
{
    protected static string|BackedEnum|null $navigationIcon = Heroicon::OutlinedGlobeAlt;

    protected static string|UnitEnum|null $navigationGroup = 'Platform';

    protected static ?string $navigationLabel = null;

    protected static ?int $navigationSort = 0;

    public static function getNavigationLabel(): string
    {
        return __('admin.nav.overview');
    }

    public function getTitle(): string
    {
        return AdminTrans::page('platform_console');
    }

    protected string $view = 'filament.pages.platform-console';

    public static function canAccess(): bool
    {
        return auth()->user()?->hasRole('super_admin') ?? false;
    }

    /**
     * @return array<class-string>
     */
    protected function getHeaderWidgets(): array
    {
        return [
            PlatformStats::class,
        ];
    }

    /**
     * @return array<class-string>
     */
    protected function getFooterWidgets(): array
    {
        return [
            RecentCompaniesWidget::class,
        ];
    }

    protected function getHeaderActions(): array
    {
        return [
            \Filament\Actions\Action::make('manage_companies')
                ->label(AdminTrans::action('all_companies'))
                ->icon('heroicon-o-building-office-2')
                ->url(CompanyResource::getUrl()),
        ];
    }
}
