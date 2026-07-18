<?php

namespace App\Services;

use App\Filament\Pages\AiCommandCenter;
use App\Filament\Pages\CompanySettings;
use App\Filament\Resources\Employees\EmployeeResource;
use App\Filament\Resources\PayrollRecords\PayrollRecordResource;
use App\Filament\Resources\Users\UserResource;
use App\Models\AiUsageLog;
use App\Models\Company;
use App\Support\AdminTrans;
use App\Models\PayrollRecord;
use App\Models\User;

class CompanyOnboardingService
{
    /**
     * @return list<array{key: string, title: string, description: string, completed: bool, href: ?string}>
     */
    public function steps(?Company $company, ?User $user): array
    {
        if ($company === null || $user === null) {
            return [];
        }

        $mobileUsers = User::query()
            ->where('company_id', $company->id)
            ->where('role', 'employee')
            ->count();

        return [
            [
                'key' => 'verify_email',
                'title' => AdminTrans::onboarding('verify_email', 'title'),
                'description' => AdminTrans::onboarding('verify_email', 'description'),
                'completed' => $user->hasVerifiedEmail(),
                'href' => null,
            ],
            [
                'key' => 'company_settings',
                'title' => AdminTrans::onboarding('company_settings', 'title'),
                'description' => AdminTrans::onboarding('company_settings', 'description'),
                'completed' => filled($company->wifi_ssid) || filled($company->phone) || filled($company->address),
                'href' => CompanySettings::getUrl(),
            ],
            [
                'key' => 'review_employees',
                'title' => AdminTrans::onboarding('review_employees', 'title'),
                'description' => AdminTrans::onboarding('review_employees', 'description'),
                'completed' => $company->employeeCount() > 0,
                'href' => EmployeeResource::getUrl(),
            ],
            [
                'key' => 'mobile_access',
                'title' => AdminTrans::onboarding('mobile_access', 'title'),
                'description' => AdminTrans::onboarding('mobile_access', 'description'),
                'completed' => $mobileUsers > 0,
                'href' => EmployeeResource::getUrl(),
            ],
            [
                'key' => 'team_users',
                'title' => AdminTrans::onboarding('team_users', 'title'),
                'description' => AdminTrans::onboarding('team_users', 'description'),
                'completed' => User::query()
                    ->where('company_id', $company->id)
                    ->whereIn('role', TeamUserService::ADMIN_ROLES)
                    ->where('id', '!=', $user->id)
                    ->exists(),
                'href' => UserResource::getUrl(),
            ],
            [
                'key' => 'payroll',
                'title' => AdminTrans::onboarding('payroll', 'title'),
                'description' => AdminTrans::onboarding('payroll', 'description'),
                'completed' => PayrollRecord::query()
                    ->where('company_id', $company->id)
                    ->exists(),
                'href' => PayrollRecordResource::getUrl(),
            ],
            [
                'key' => 'ai_explore',
                'title' => AdminTrans::onboarding('ai_explore', 'title'),
                'description' => AdminTrans::onboarding('ai_explore', 'description'),
                'completed' => AiUsageLog::query()
                    ->where('company_id', $company->id)
                    ->exists(),
                'href' => AiCommandCenter::getUrl(),
            ],
        ];
    }

    /**
     * @param  list<array{completed: bool}>  $steps
     */
    public function progressPercent(array $steps): int
    {
        if ($steps === []) {
            return 100;
        }

        $done = collect($steps)->where('completed', true)->count();

        return (int) round(($done / count($steps)) * 100);
    }

    public function isComplete(?Company $company, ?User $user): bool
    {
        $steps = $this->steps($company, $user);

        return $this->progressPercent($steps) === 100;
    }

    public function shouldShowGettingStarted(?Company $company, ?User $user): bool
    {
        if ($company === null || $user === null || $user->hasRole('super_admin')) {
            return false;
        }

        return ! $this->isComplete($company, $user);
    }
}
