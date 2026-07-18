<?php

namespace Tests\Feature;

use App\Models\Company;
use App\Models\Employee;
use App\Models\LeaveRequest;
use App\Models\User;
use App\Notifications\LeaveApprovedNotification;
use App\Services\EmployeeAppAccessService;
use App\Services\LeaveDecisionService;
use App\Services\PayrollGenerationService;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Illuminate\Support\Facades\Hash;
use Illuminate\Support\Facades\Notification;
use Tests\TestCase;

class FilamentWorkflowServicesTest extends TestCase
{
    use RefreshDatabase;

    public function test_employee_app_access_service_enables_and_disables_login(): void
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

        $service = app(EmployeeAppAccessService::class);
        $this->assertFalse($service->isEnabled($employee));

        $service->enable($employee, 'Password123!');
        $employee->refresh();
        $this->assertTrue($service->isEnabled($employee));
        $this->assertNotNull($employee->user_id);

        $service->disable($employee->refresh());
        $this->assertFalse($service->isEnabled($employee->refresh()));
    }

    public function test_payroll_generation_service_creates_records(): void
    {
        $company = Company::query()->create([
            'name' => 'Co',
            'status' => 'active',
            'plan' => 'trial',
        ]);
        Employee::query()->create([
            'company_id' => $company->id,
            'name' => 'Emp',
            'email' => 'emp@co.test',
            'is_active' => true,
            'base_salary' => 2000,
            'allowances' => 200,
            'deductions' => 100,
        ]);

        $month = now()->format('Y-m');
        $count = app(PayrollGenerationService::class)->generate($company->id, $month);

        $this->assertSame(1, $count);
        $this->assertDatabaseHas('payroll_records', [
            'company_id' => $company->id,
            'month' => $month,
            'net_salary' => 2100,
            'status' => 'processed',
        ]);
    }

    public function test_leave_decision_sends_email_when_employee_user_exists(): void
    {
        Notification::fake();

        $company = Company::query()->create([
            'name' => 'Co',
            'status' => 'active',
            'plan' => 'trial',
        ]);
        $user = User::query()->create([
            'company_id' => $company->id,
            'name' => 'Emp',
            'email' => 'emp@co.test',
            'password' => Hash::make('Password123!'),
            'role' => 'employee',
        ]);
        $employee = Employee::query()->create([
            'company_id' => $company->id,
            'user_id' => $user->id,
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

        Notification::assertSentTo($user, LeaveApprovedNotification::class);
    }
}
