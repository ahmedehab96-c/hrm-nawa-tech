<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Company;
use App\Models\User;
use App\Services\BillingService;
use App\Services\PlatformOverviewService;
use Illuminate\Http\Request;
use Illuminate\Support\Carbon;

class PlatformController extends Controller
{
    public function overview(Request $request)
    {
        return response()->json(app(PlatformOverviewService::class)->metrics());
    }

    public function companies(Request $request)
    {
        $q = Company::query()->orderByDesc('id');

        if ($request->filled('status')) {
            $q->where('status', $request->string('status'));
        }
        if ($request->filled('plan')) {
            $q->where('plan', $request->string('plan'));
        }
        if ($request->filled('search')) {
            $s = '%'.$request->string('search').'%';
            $q->where(function ($inner) use ($s) {
                $inner->where('name', 'like', $s)
                    ->orWhere('email', 'like', $s);
            });
        }

        $rows = $q->limit(200)->get()->map(fn (Company $c) => $this->formatCompany($c));

        return response()->json(['data' => $rows]);
    }

    public function showCompany(string $id)
    {
        $company = Company::query()->findOrFail($id);

        return response()->json(['data' => $this->formatCompany($company, true)]);
    }

    public function updateCompany(Request $request, string $id)
    {
        $company = Company::query()->findOrFail($id);

        $validated = $request->validate([
            'status' => 'sometimes|in:active,suspended',
            'plan' => 'sometimes|in:trial,starter,growth,pro,enterprise,active',
            'trial_ends_at' => 'sometimes|nullable|date',
            'extend_trial_days' => 'sometimes|integer|min:1|max:365',
            'name' => 'sometimes|string|max:255',
        ]);

        if (isset($validated['extend_trial_days'])) {
            $base = $company->trial_ends_at && $company->trial_ends_at->isFuture()
                ? $company->trial_ends_at
                : now();
            $company->trial_ends_at = $base->copy()->addDays((int) $validated['extend_trial_days']);
            $company->plan = 'trial';
            unset($validated['extend_trial_days']);
        }

        if (array_key_exists('trial_ends_at', $validated)) {
            $company->trial_ends_at = $validated['trial_ends_at']
                ? Carbon::parse($validated['trial_ends_at'])
                : null;
            unset($validated['trial_ends_at']);
        }

        $company->fill($validated);
        $company->save();

        return response()->json([
            'message' => 'Company updated',
            'data' => $this->formatCompany($company, true),
        ]);
    }

    /**
     * Company admin: request plan upgrade for their own tenant.
     * Defaults to Stripe scaffold (501) unless provider=manual (dev/demo only).
     */
    public function companyCheckout(Request $request)
    {
        $user = $request->user();
        if (! $user?->company_id) {
            return response()->json(['message' => 'No company on account'], 422);
        }

        return $this->createCheckout($request, (string) $user->company_id);
    }

    /**
     * Billing scaffold — returns a placeholder checkout URL until Stripe/Moyasar is wired.
     */
    public function createCheckout(Request $request, string $id)
    {
        $company = Company::query()->findOrFail($id);
        $validated = $request->validate([
            'plan' => 'required|in:starter,growth,enterprise',
            'provider' => 'sometimes|in:stripe,moyasar,manual',
            'success_url' => 'sometimes|url',
            'cancel_url' => 'sometimes|url',
        ]);

        $provider = $validated['provider'] ?? app(BillingService::class)->preferredProvider();
        $billing = app(BillingService::class);

        if ($provider === 'manual') {
            $billing->activatePlan($company, $validated['plan']);

            return response()->json([
                'message' => 'Plan activated manually (billing provider not configured).',
                'checkout_url' => null,
                'provider' => 'manual',
                'data' => $this->formatCompany($company->fresh()),
            ]);
        }

        $resolved = $billing->resolvePaymentProvider($provider);
        if ($resolved !== null && in_array($resolved, ['stripe', 'moyasar'], true)) {
            $user = $request->user();
            abort_unless($user !== null, 401);

            $base = rtrim((string) config('app.url'), '/');
            $successUrl = $validated['success_url'] ?? "{$base}/admin/billing-upgrade?checkout=success";
            $cancelUrl = $validated['cancel_url'] ?? "{$base}/admin/billing-upgrade?checkout=cancelled";

            $session = $billing->createCheckoutSession(
                $company,
                $user,
                $validated['plan'],
                $successUrl,
                $cancelUrl,
                $resolved,
            );

            return response()->json([
                'message' => 'Checkout session created',
                'checkout_url' => $session['checkout_url'],
                'session_id' => $session['session_id'],
                'provider' => $session['provider'],
                'plan' => $validated['plan'],
                'company_id' => $company->id,
            ]);
        }

        return response()->json([
            'message' => 'Payment provider scaffold ready. Configure API keys to enable checkout.',
            'checkout_url' => null,
            'provider' => $provider,
            'plan' => $validated['plan'],
            'company_id' => $company->id,
            'code' => 'billing_not_configured',
        ], 501);
    }

    private function formatCompany(Company $company, bool $detailed = false): array
    {
        $data = [
            'id' => $company->id,
            'name' => $company->name,
            'email' => $company->email,
            'status' => $company->status,
            'plan' => $company->plan,
            'trial_ends_at' => $company->trial_ends_at?->toIso8601String(),
            'employee_count' => $company->employeeCount(),
            'employee_limit' => $company->employeeLimit(),
            'created_at' => $company->created_at?->toIso8601String(),
        ];

        if ($detailed) {
            $data['users_count'] = User::query()->where('company_id', $company->id)->count();
            $data['phone'] = $company->phone;
            $data['address'] = $company->address;
        }

        return $data;
    }
}
