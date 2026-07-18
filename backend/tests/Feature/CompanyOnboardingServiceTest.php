<?php

namespace Tests\Feature;

use App\Models\Company;
use App\Models\Employee;
use App\Models\User;
use App\Services\CompanyOnboardingService;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Tests\TestCase;

class CompanyOnboardingServiceTest extends TestCase
{
    use RefreshDatabase;

    public function test_onboarding_progress_increases_as_steps_complete(): void
    {
        $company = Company::query()->create([
            'name' => 'Co',
            'status' => 'active',
            'plan' => 'trial',
            'wifi_ssid' => 'OfficeWiFi',
        ]);
        $user = User::query()->create([
            'company_id' => $company->id,
            'name' => 'Admin',
            'email' => 'admin@co.test',
            'password' => 'secret',
            'role' => 'company_admin',
            'email_verified_at' => now(),
        ]);
        Employee::query()->create([
            'company_id' => $company->id,
            'name' => 'Emp',
            'email' => 'emp@co.test',
            'is_active' => true,
            'base_salary' => 1000,
            'allowances' => 0,
            'deductions' => 0,
        ]);

        $service = app(CompanyOnboardingService::class);
        $steps = $service->steps($company, $user);
        $progress = $service->progressPercent($steps);

        $this->assertGreaterThan(0, $progress);
        $this->assertFalse($service->isComplete($company, $user));
        $this->assertTrue($service->shouldShowGettingStarted($company, $user));
    }
}
