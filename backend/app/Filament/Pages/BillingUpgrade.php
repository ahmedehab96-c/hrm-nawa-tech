<?php

namespace App\Filament\Pages;

use App\Models\Company;
use App\Services\BillingService;
use App\Support\AdminTrans;
use BackedEnum;
use Filament\Actions\Action;
use Filament\Notifications\Notification;
use Filament\Pages\Page;
use Filament\Support\Icons\Heroicon;
use UnitEnum;

class BillingUpgrade extends Page
{
    protected static string|BackedEnum|null $navigationIcon = Heroicon::OutlinedCreditCard;

    protected static string|UnitEnum|null $navigationGroup = 'Company';

    protected static ?string $navigationLabel = null;

    protected static ?int $navigationSort = 91;

    public static function getNavigationLabel(): string
    {
        return __('admin.nav.billing');
    }

    public function getTitle(): string
    {
        return AdminTrans::page('plan_billing');
    }

    public static function shouldRegisterNavigation(): bool
    {
        return false;
    }

    protected string $view = 'filament.pages.billing-upgrade';

    public static function canAccess(): bool
    {
        $user = auth()->user();

        return $user !== null
            && ! $user->hasRole('super_admin')
            && $user->company_id !== null;
    }

    public function mount(): void
    {
        if (request()->query('checkout') === 'success') {
            Notification::make()
                ->title(AdminTrans::notification('payment_received'))
                ->success()
                ->send();
        }
    }

    public function getCompany(): ?Company
    {
        $id = auth()->user()?->company_id;

        return $id ? Company::query()->find($id) : null;
    }

    public function getPaymentProvider(): ?string
    {
        return app(BillingService::class)->resolvePaymentProvider();
    }

    public function isOnlineCheckoutEnabled(): bool
    {
        return $this->getPaymentProvider() !== null;
    }

    /**
     * @return array<string, array{label: string, employee_limit: int|null, price_hint: string}>
     */
    public function getCatalog(): array
    {
        return app(BillingService::class)->catalog();
    }

    /**
     * @return array<Action>
     */
    protected function getHeaderActions(): array
    {
        $company = $this->getCompany();
        if ($company === null) {
            return [];
        }

        $billing = app(BillingService::class);
        $provider = $billing->resolvePaymentProvider();
        $actions = [];

        foreach ($billing->catalog() as $plan => $meta) {
            if ($provider !== null) {
                $providerLabel = $provider === 'moyasar' ? 'Moyasar' : 'Stripe';
                $actions[] = Action::make("checkout_{$plan}")
                    ->label(__('admin.billing.pay_via', [
                        'provider' => $providerLabel,
                        'plan' => $meta['label'],
                    ]))
                    ->icon('heroicon-o-credit-card')
                    ->color($company->plan === $plan ? 'gray' : 'primary')
                    ->disabled($company->plan === $plan)
                    ->action(function () use ($plan, $billing, $company, $provider): void {
                        $user = auth()->user();
                        abort_unless($user !== null, 401);

                        $base = rtrim((string) config('app.url'), '/');
                        $session = $billing->createCheckoutSession(
                            $company,
                            $user,
                            $plan,
                            "{$base}/admin/billing-upgrade?checkout=success",
                            "{$base}/admin/billing-upgrade?checkout=cancelled",
                            $provider,
                        );

                        $this->redirect($session['checkout_url'], navigate: false);
                    });
            }

            $actions[] = Action::make("manual_{$plan}")
                ->label($provider !== null
                    ? __('admin.billing.demo_activate', ['plan' => $meta['label']])
                    : __('admin.billing.activate', ['plan' => $meta['label']]))
                ->color($company->plan === $plan ? 'gray' : ($provider !== null ? 'gray' : 'primary'))
                ->disabled($company->plan === $plan)
                ->requiresConfirmation()
                ->modalHeading(__('admin.billing.activate_confirm', ['plan' => $meta['label']]))
                ->modalDescription(__('admin.billing.demo_modal_body'))
                ->action(function () use ($plan, $meta, $billing): void {
                    $company = $this->getCompany();
                    abort_unless($company !== null, 404);
                    $billing->activatePlan($company, $plan);
                    Notification::make()
                        ->title(AdminTrans::notification('plan_updated'))
                        ->success()
                        ->send();
                    $this->redirect(static::getUrl());
                });
        }

        return $actions;
    }
}
