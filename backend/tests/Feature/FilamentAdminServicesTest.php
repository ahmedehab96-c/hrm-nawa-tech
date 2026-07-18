<?php

namespace Tests\Feature;

use App\Models\Company;
use App\Models\Employee;
use App\Models\LeaveRequest;
use App\Services\BillingService;
use App\Services\LeaveDecisionService;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Tests\TestCase;

class FilamentAdminServicesTest extends TestCase
{
    use RefreshDatabase;

    public function test_leave_decision_service_approves_and_notifies(): void
    {
        $company = Company::query()->create([
            'name' => 'Co',
            'status' => 'active',
            'plan' => 'trial',
        ]);
        $employee = Employee::query()->create([
            'company_id' => $company->id,
            'name' => 'Emp',
            'email' => 'emp@co.test',
            'is_active' => true,
            'base_salary' => 1000,
            'allowances' => 0,
            'deductions' => 0,
        ]);
        $leave = LeaveRequest::query()->create([
            'company_id' => $company->id,
            'employee_id' => $employee->id,
            'type' => 'annual',
            'from_date' => now()->toDateString(),
            'to_date' => now()->addDay()->toDateString(),
            'days' => 1,
            'status' => 'pending',
        ]);

        app(LeaveDecisionService::class)->approve($leave);

        $this->assertSame('approved', $leave->fresh()->status);
        $this->assertDatabaseHas('app_notifications', [
            'employee_id' => $employee->id,
            'title' => 'Leave approved',
            'type' => 'leave',
        ]);
    }

    public function test_billing_service_activates_plan(): void
    {
        $company = Company::query()->create([
            'name' => 'Co',
            'status' => 'active',
            'plan' => 'trial',
            'trial_ends_at' => now()->addDays(7),
        ]);

        app(BillingService::class)->activatePlan($company, 'growth');

        $company->refresh();
        $this->assertSame('growth', $company->plan);
        $this->assertNull($company->trial_ends_at);
        $this->assertSame('active', $company->status);
        $this->assertSame(100, $company->employeeLimit());
    }

    public function test_hr_metrics_service_aggregates_counts(): void
    {
        $company = Company::query()->create([
            'name' => 'Co',
            'status' => 'active',
            'plan' => 'trial',
        ]);

        $metrics = app(\App\Services\HrMetricsService::class)->aggregate(
            $company->id,
            now()->startOfMonth()->toDateString(),
            now()->endOfMonth()->toDateString(),
        );

        $this->assertArrayHasKey('employees_total', $metrics);
        $this->assertArrayHasKey('leave_pending', $metrics);
        $this->assertSame(0, $metrics['employees_total']);
    }

    public function test_platform_company_service_extends_trial(): void
    {
        $company = Company::query()->create([
            'name' => 'Co',
            'status' => 'active',
            'plan' => 'starter',
        ]);

        app(\App\Services\PlatformCompanyService::class)->extendTrial($company, 14);

        $company->refresh();
        $this->assertSame('trial', $company->plan);
        $this->assertNotNull($company->trial_ends_at);
        $this->assertTrue($company->trial_ends_at->isFuture());
    }

    public function test_billing_service_stripe_not_configured_by_default(): void
    {
        config([
            'services.stripe.secret' => null,
            'services.stripe.price_starter' => null,
            'services.stripe.price_growth' => null,
        ]);

        $this->assertFalse(app(BillingService::class)->isStripeConfigured());
    }

    public function test_platform_overview_service_returns_metrics(): void
    {
        Company::query()->create([
            'name' => 'Co',
            'status' => 'active',
            'plan' => 'trial',
        ]);

        $metrics = app(\App\Services\PlatformOverviewService::class)->metrics();

        $this->assertSame(1, $metrics['companies']);
        $this->assertArrayHasKey('paid_plans', $metrics);
    }
}
