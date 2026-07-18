<?php

namespace Tests\Feature;

use App\Models\Company;
use App\Services\BillingService;
use App\Services\BillingWebhookHandler;
use App\Services\StripeWebhookVerifier;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Illuminate\Http\Request;
use Tests\TestCase;

class BillingWebhooksTest extends TestCase
{
    use RefreshDatabase;

    public function test_stripe_webhook_verifier_accepts_valid_signature(): void
    {
        $secret = 'whsec_test_secret';
        config(['services.stripe.webhook_secret' => $secret]);

        $payload = json_encode([
            'type' => 'checkout.session.completed',
            'data' => ['object' => ['metadata' => ['company_id' => '1', 'plan' => 'starter']]],
        ], JSON_THROW_ON_ERROR);

        $timestamp = time();
        $signature = hash_hmac('sha256', $timestamp.'.'.$payload, $secret);
        $header = "t={$timestamp},v1={$signature}";

        $request = Request::create('/stripe/webhook', 'POST', [], [], [], [
            'HTTP_STRIPE_SIGNATURE' => $header,
        ], $payload);

        $event = app(StripeWebhookVerifier::class)->verify($request);

        $this->assertSame('checkout.session.completed', $event['type']);
    }

    public function test_stripe_webhook_verifier_rejects_invalid_signature_when_secret_set(): void
    {
        config(['services.stripe.webhook_secret' => 'whsec_test']);

        $payload = '{"type":"checkout.session.completed"}';
        $request = Request::create('/stripe/webhook', 'POST', [], [], [], [
            'HTTP_STRIPE_SIGNATURE' => 't='.time().',v1=bad',
        ], $payload);

        $this->expectException(\RuntimeException::class);
        app(StripeWebhookVerifier::class)->verify($request);
    }

    public function test_billing_webhook_handler_activates_plan_from_stripe_metadata(): void
    {
        $company = Company::query()->create([
            'name' => 'Co',
            'status' => 'active',
            'plan' => 'trial',
        ]);

        app(BillingWebhookHandler::class)->handleStripeEvent([
            'type' => 'checkout.session.completed',
            'data' => [
                'object' => [
                    'metadata' => [
                        'company_id' => (string) $company->id,
                        'plan' => 'growth',
                    ],
                ],
            ],
        ]);

        $company->refresh();
        $this->assertSame('growth', $company->plan);
        $this->assertNull($company->trial_ends_at);
    }

    public function test_billing_webhook_handler_activates_plan_from_moyasar_invoice(): void
    {
        $company = Company::query()->create([
            'name' => 'Co',
            'status' => 'active',
            'plan' => 'trial',
        ]);

        app(BillingWebhookHandler::class)->handleMoyasarInvoice([
            'status' => 'paid',
            'metadata' => [
                'company_id' => (string) $company->id,
                'plan' => 'starter',
            ],
        ]);

        $company->refresh();
        $this->assertSame('starter', $company->plan);
    }

    public function test_billing_service_prefers_moyasar_when_configured_as_default(): void
    {
        config([
            'services.billing.default_provider' => 'moyasar',
            'services.stripe.secret' => 'sk_test',
            'services.stripe.price_starter' => 'price_1',
            'services.stripe.price_growth' => 'price_2',
            'services.moyasar.secret' => 'sk_test_moyasar',
            'services.moyasar.amount_starter' => 9900,
            'services.moyasar.amount_growth' => 29900,
        ]);

        $billing = app(BillingService::class);

        $this->assertSame('moyasar', $billing->resolvePaymentProvider());
        $this->assertTrue($billing->isMoyasarConfigured());
    }

    public function test_moyasar_webhook_rejects_invalid_secret_when_configured(): void
    {
        config(['services.moyasar.webhook_secret' => 'expected-secret']);

        $response = $this->postJson('/moyasar/webhook', [
            'status' => 'paid',
            'metadata' => ['company_id' => '1', 'plan' => 'starter'],
            'secret_token' => 'wrong',
        ]);

        $response->assertStatus(401);
    }
}
