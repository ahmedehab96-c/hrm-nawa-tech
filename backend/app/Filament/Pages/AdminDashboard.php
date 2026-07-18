<?php

namespace App\Filament\Pages;

use App\Filament\Widgets\OnboardingBannerWidget;
use App\Filament\Widgets\PendingLeaveWidget;
use App\Filament\Widgets\StatsOverview;
use App\Filament\Widgets\VerifyEmailBannerWidget;
use App\Filament\Resources\JobPostings\JobPostingResource;
use BackedEnum;
use Filament\Pages\Dashboard as BaseDashboard;
use Filament\Support\Icons\Heroicon;

class AdminDashboard extends BaseDashboard
{
    protected static string|BackedEnum|null $navigationIcon = Heroicon::OutlinedSquares2x2;

    protected static ?int $navigationSort = 1;

    public static function getNavigationLabel(): string
    {
        return __('admin.nav.dashboard');
    }

    public static function shouldRegisterNavigation(): bool
    {
        return ! (auth()->user()?->hasRole('recruiter') ?? false);
    }

    public function mount(): void
    {
        if (auth()->user()?->hasRole('super_admin')) {
            $this->redirect(PlatformConsole::getUrl());

            return;
        }

        if (auth()->user()?->hasRole('recruiter')) {
            $this->redirect(JobPostingResource::getUrl());
        }
    }

    /**
     * @return array<class-string>
     */
    public function getWidgets(): array
    {
        return [
            VerifyEmailBannerWidget::class,
            OnboardingBannerWidget::class,
            StatsOverview::class,
            PendingLeaveWidget::class,
        ];
    }
}
