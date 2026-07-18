<?php

namespace App\Services;

use App\Models\Company;
use Illuminate\Support\Facades\Log;

class BillingWebhookHandler
{
    public function handleStripeEvent(array $event): void
    {
        if (($event['type'] ?? '') !== 'checkout.session.completed') {
            return;
        }

        $session = $event['data']['object'] ?? [];
        $this->activateFromMetadata(
            $session['metadata']['company_id'] ?? null,
            $session['metadata']['plan'] ?? null,
        );
    }

    public function handleMoyasarInvoice(array $invoice): void
    {
        if (($invoice['status'] ?? '') !== 'paid') {
            return;
        }

        $metadata = $invoice['metadata'] ?? [];
        $this->activateFromMetadata(
            $metadata['company_id'] ?? null,
            $metadata['plan'] ?? null,
        );
    }

    private function activateFromMetadata(mixed $companyId, mixed $plan): void
    {
        if (! $companyId || ! is_string($plan) || ! in_array($plan, BillingService::PLANS, true)) {
            return;
        }

        $company = Company::query()->find($companyId);
        if ($company === null) {
            Log::warning('Billing webhook: company not found', ['company_id' => $companyId]);

            return;
        }

        app(BillingService::class)->activatePlan($company, $plan);
        Log::info('Billing webhook: plan activated', [
            'company_id' => $company->id,
            'plan' => $plan,
        ]);
    }
}
