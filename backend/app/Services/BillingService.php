<?php

namespace App\Services;

use App\Models\Company;
use App\Models\User;
use App\Support\AdminTrans;
use Illuminate\Support\Facades\Http;
use RuntimeException;

class BillingService
{
    /** @var list<string> */
    public const PLANS = ['starter', 'growth', 'enterprise'];

    public function preferredProvider(): string
    {
        return (string) config('services.billing.default_provider', 'stripe');
    }

    public function resolvePaymentProvider(?string $requested = null): ?string
    {
        if ($requested === 'manual') {
            return 'manual';
        }

        if ($requested === 'stripe' && $this->isStripeConfigured()) {
            return 'stripe';
        }

        if ($requested === 'moyasar' && $this->isMoyasarConfigured()) {
            return 'moyasar';
        }

        $preferred = $requested ?? $this->preferredProvider();

        if ($preferred === 'stripe' && $this->isStripeConfigured()) {
            return 'stripe';
        }

        if ($preferred === 'moyasar' && $this->isMoyasarConfigured()) {
            return 'moyasar';
        }

        if ($this->isStripeConfigured()) {
            return 'stripe';
        }

        if ($this->isMoyasarConfigured()) {
            return 'moyasar';
        }

        return null;
    }

    public function isStripeConfigured(): bool
    {
        return filled(config('services.stripe.secret'))
            && filled(config('services.stripe.price_starter'))
            && filled(config('services.stripe.price_growth'));
    }

    public function isMoyasarConfigured(): bool
    {
        return filled(config('services.moyasar.secret'))
            && filled(config('services.moyasar.amount_starter'))
            && filled(config('services.moyasar.amount_growth'));
    }

    public function stripePriceIdForPlan(string $plan): ?string
    {
        return match ($plan) {
            'starter' => config('services.stripe.price_starter'),
            'growth' => config('services.stripe.price_growth'),
            'enterprise' => config('services.stripe.price_enterprise'),
            default => null,
        };
    }

    public function moyasarAmountForPlan(string $plan): ?int
    {
        $amount = match ($plan) {
            'starter' => config('services.moyasar.amount_starter'),
            'growth' => config('services.moyasar.amount_growth'),
            'enterprise' => config('services.moyasar.amount_enterprise'),
            default => null,
        };

        return is_numeric($amount) ? (int) $amount : null;
    }

    /**
     * @return array{checkout_url: string, session_id: string, provider: string}
     */
    public function createCheckoutSession(
        Company $company,
        User $user,
        string $plan,
        string $successUrl,
        string $cancelUrl,
        ?string $provider = null,
    ): array {
        $resolved = $this->resolvePaymentProvider($provider);
        if ($resolved === null) {
            throw new RuntimeException('No payment provider is configured.');
        }

        return match ($resolved) {
            'stripe' => $this->createStripeCheckoutSession($company, $user, $plan, $successUrl, $cancelUrl),
            'moyasar' => $this->createMoyasarInvoice($company, $plan, $successUrl, $cancelUrl),
            default => throw new RuntimeException("Unsupported provider: {$resolved}"),
        };
    }

    /**
     * @return array{checkout_url: string, session_id: string, provider: string}
     */
    public function createStripeCheckoutSession(
        Company $company,
        User $user,
        string $plan,
        string $successUrl,
        string $cancelUrl,
    ): array {
        if (! $this->isStripeConfigured()) {
            throw new RuntimeException('Stripe is not configured.');
        }

        $priceId = $this->stripePriceIdForPlan($plan);
        if (! filled($priceId)) {
            throw new RuntimeException("No Stripe price configured for plan: {$plan}");
        }

        $response = Http::withToken((string) config('services.stripe.secret'))
            ->asForm()
            ->post('https://api.stripe.com/v1/checkout/sessions', [
                'mode' => 'subscription',
                'success_url' => $successUrl,
                'cancel_url' => $cancelUrl,
                'client_reference_id' => (string) $company->id,
                'customer_email' => $user->email,
                'metadata[company_id]' => (string) $company->id,
                'metadata[plan]' => $plan,
                'line_items[0][price]' => $priceId,
                'line_items[0][quantity]' => 1,
            ]);

        if (! $response->successful()) {
            throw new RuntimeException('Stripe checkout session failed: '.$response->body());
        }

        $data = $response->json();

        return [
            'checkout_url' => (string) ($data['url'] ?? ''),
            'session_id' => (string) ($data['id'] ?? ''),
            'provider' => 'stripe',
        ];
    }

    /**
     * @return array{checkout_url: string, session_id: string, provider: string}
     */
    public function createMoyasarInvoice(
        Company $company,
        string $plan,
        string $successUrl,
        string $backUrl,
    ): array {
        if (! $this->isMoyasarConfigured()) {
            throw new RuntimeException('Moyasar is not configured.');
        }

        $amount = $this->moyasarAmountForPlan($plan);
        if ($amount === null || $amount < 100) {
            throw new RuntimeException("No Moyasar amount configured for plan: {$plan}");
        }

        $catalog = $this->catalog();
        $label = $catalog[$plan]['label'] ?? ucfirst($plan);
        $currency = (string) config('services.moyasar.currency', 'SAR');

        $response = Http::withBasicAuth((string) config('services.moyasar.secret'), '')
            ->asForm()
            ->post('https://api.moyasar.com/v1/invoices', [
                'amount' => $amount,
                'currency' => $currency,
                'description' => "Nawa Tech HRM — {$label} plan",
                'success_url' => $successUrl,
                'back_url' => $backUrl,
                'callback_url' => rtrim((string) config('app.url'), '/').'/moyasar/webhook',
                'metadata[company_id]' => (string) $company->id,
                'metadata[plan]' => $plan,
            ]);

        if (! $response->successful()) {
            throw new RuntimeException('Moyasar invoice failed: '.$response->body());
        }

        $data = $response->json();

        return [
            'checkout_url' => (string) ($data['url'] ?? ''),
            'session_id' => (string) ($data['id'] ?? ''),
            'provider' => 'moyasar',
        ];
    }

    public function activatePlan(Company $company, string $plan): Company
    {
        if (! in_array($plan, self::PLANS, true)) {
            throw new \InvalidArgumentException("Invalid plan: {$plan}");
        }

        $company->plan = $plan;
        $company->trial_ends_at = null;
        $company->status = 'active';
        $company->save();

        return $company->refresh();
    }

    /**
     * @return array<string, array{label: string, employee_limit: int|null, price_hint: string}>
     */
    public function catalog(): array
    {
        return [
            'starter' => [
                'label' => AdminTrans::options('plan')['starter'],
                'employee_limit' => 25,
                'price_hint' => AdminTrans::billing('up_to_employees', ['count' => '25']),
            ],
            'growth' => [
                'label' => AdminTrans::options('plan')['growth'],
                'employee_limit' => 100,
                'price_hint' => AdminTrans::billing('up_to_employees', ['count' => '100']),
            ],
            'enterprise' => [
                'label' => AdminTrans::options('plan')['enterprise'],
                'employee_limit' => null,
                'price_hint' => AdminTrans::billing('unlimited_employees'),
            ],
        ];
    }
}
