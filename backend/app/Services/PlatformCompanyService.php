<?php

namespace App\Services;

use App\Models\Company;
use Illuminate\Support\Carbon;
use InvalidArgumentException;

class PlatformCompanyService
{
    public function suspend(Company $company): Company
    {
        $company->status = 'suspended';
        $company->save();

        return $company->refresh();
    }

    public function activate(Company $company): Company
    {
        $company->status = 'active';
        $company->save();

        return $company->refresh();
    }

    public function extendTrial(Company $company, int $days = 14): Company
    {
        if ($days < 1 || $days > 365) {
            throw new InvalidArgumentException('Trial extension must be between 1 and 365 days.');
        }

        $base = $company->trial_ends_at && $company->trial_ends_at->isFuture()
            ? $company->trial_ends_at
            : now();

        $company->trial_ends_at = $base->copy()->addDays($days);
        $company->plan = 'trial';
        $company->status = 'active';
        $company->save();

        return $company->refresh();
    }

    public function setPlan(Company $company, string $plan, ?Carbon $trialEndsAt = null): Company
    {
        if ($plan === 'trial') {
            $company->plan = 'trial';
            $company->trial_ends_at = $trialEndsAt ?? now()->addDays(14);
            $company->status = 'active';
            $company->save();

            return $company->refresh();
        }

        if (in_array($plan, BillingService::PLANS, true)) {
            return app(BillingService::class)->activatePlan($company, $plan);
        }

        $company->plan = $plan;
        if ($trialEndsAt !== null) {
            $company->trial_ends_at = $trialEndsAt;
        }
        $company->save();

        return $company->refresh();
    }
}
