<?php

namespace App\Services;

use App\Models\Company;
use App\Models\Employee;
use App\Models\User;

class PlatformOverviewService
{
    /**
     * @return array<string, int>
     */
    public function metrics(): array
    {
        return [
            'companies' => Company::query()->count(),
            'users' => User::query()->count(),
            'employees' => Employee::query()->count(),
            'trials_active' => Company::query()
                ->where('plan', 'trial')
                ->where(function ($q) {
                    $q->whereNull('trial_ends_at')
                        ->orWhere('trial_ends_at', '>', now());
                })
                ->count(),
            'trials_expired' => Company::query()
                ->where('plan', 'trial')
                ->whereNotNull('trial_ends_at')
                ->where('trial_ends_at', '<=', now())
                ->count(),
            'suspended' => Company::query()->where('status', 'suspended')->count(),
            'paid_plans' => Company::query()
                ->whereIn('plan', BillingService::PLANS)
                ->count(),
        ];
    }
}
