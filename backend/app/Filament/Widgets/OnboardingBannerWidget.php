<?php

namespace App\Filament\Widgets;

use App\Filament\Pages\GettingStarted;
use App\Models\Company;
use App\Services\CompanyOnboardingService;
use Filament\Widgets\Widget;

class OnboardingBannerWidget extends Widget
{
    protected static ?int $sort = 0;

    protected int|string|array $columnSpan = 'full';

    protected string $view = 'filament.widgets.onboarding-banner';

    public static function canView(): bool
    {
        $user = auth()->user();
        if ($user === null || $user->hasRole('super_admin') || $user->company_id === null) {
            return false;
        }

        $company = Company::query()->find($user->company_id);

        return app(CompanyOnboardingService::class)->shouldShowGettingStarted($company, $user);
    }

    public function getProgressPercent(): int
    {
        $user = auth()->user();
        $company = $user?->company_id
            ? Company::query()->find($user->company_id)
            : null;

        $steps = app(CompanyOnboardingService::class)->steps($company, $user);

        return app(CompanyOnboardingService::class)->progressPercent($steps);
    }

    public function getGettingStartedUrl(): string
    {
        return GettingStarted::getUrl();
    }
}
