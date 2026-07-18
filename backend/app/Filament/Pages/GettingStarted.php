<?php

namespace App\Filament\Pages;

use App\Models\Company;
use App\Services\CompanyOnboardingService;
use App\Support\AdminTrans;
use BackedEnum;
use Filament\Actions\Action;
use Filament\Notifications\Notification;
use Filament\Pages\Page;
use Filament\Support\Icons\Heroicon;
use UnitEnum;

class GettingStarted extends Page
{
    protected static string|BackedEnum|null $navigationIcon = Heroicon::OutlinedRocketLaunch;

    protected static string|UnitEnum|null $navigationGroup = 'Company';

    protected static ?string $navigationLabel = null;

    protected static ?int $navigationSort = 1;

    public static function getNavigationLabel(): string
    {
        return __('admin.nav.getting_started');
    }

    public function getTitle(): string
    {
        return AdminTrans::page('getting_started');
    }

    protected string $view = 'filament.pages.getting-started';

    public static function canAccess(): bool
    {
        $user = auth()->user();

        return $user !== null
            && ! $user->hasRole('super_admin')
            && $user->company_id !== null;
    }

    public static function shouldRegisterNavigation(): bool
    {
        $user = auth()->user();
        if ($user === null || $user->company_id === null) {
            return false;
        }

        $company = Company::query()->find($user->company_id);

        return app(CompanyOnboardingService::class)->shouldShowGettingStarted($company, $user);
    }

    /**
     * @return list<array{key: string, title: string, description: string, completed: bool, href: ?string}>
     */
    public function getOnboardingSteps(): array
    {
        return app(CompanyOnboardingService::class)->steps($this->company(), auth()->user());
    }

    public function getProgressPercent(): int
    {
        return app(CompanyOnboardingService::class)->progressPercent($this->getOnboardingSteps());
    }

    protected function company(): ?Company
    {
        $id = auth()->user()?->company_id;

        return $id ? Company::query()->find($id) : null;
    }

    /**
     * @return array<Action>
     */
    protected function getHeaderActions(): array
    {
        $user = auth()->user();
        if ($user === null || $user->hasVerifiedEmail()) {
            return [];
        }

        return [
            Action::make('resendVerification')
                ->label(AdminTrans::action('resend_verification'))
                ->icon('heroicon-o-envelope')
                ->action(function () use ($user): void {
                    $user->sendEmailVerificationNotification();
                    Notification::make()
                        ->title(AdminTrans::notification('verification_sent'))
                        ->success()
                        ->send();
                }),
        ];
    }
}
