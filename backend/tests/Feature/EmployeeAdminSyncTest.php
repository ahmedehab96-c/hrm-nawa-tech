<?php

namespace Tests\Feature;

use App\Models\AttendanceRecord;
use App\Models\Employee;
use App\Models\LeaveRequest;
use App\Models\PayrollRecord;
use App\Models\User;
use Tests\TestCase;

class EmployeeAdminSyncTest extends TestCase
{
    private User $employeeUser;

    private Employee $employee;

    private array $employeeHeaders;

    private array $adminHeaders;

    protected function setUp(): void
    {
        parent::setUp();

        $this->adminHeaders = $this->adminHeaders();
        $this->employeeUser = User::factory()->create([
            'company_id' => $this->company->id,
            'role' => 'employee',
        ]);
        $this->employee = Employee::create([
            'company_id' => $this->company->id,
            'user_id' => $this->employeeUser->id,
            'name' => $this->employeeUser->name,
            'email' => $this->employeeUser->email,
            'base_salary' => 5000,
            'allowances' => 500,
            'deductions' => 100,
        ]);
        $token = $this->employeeUser->createToken('mobile')->plainTextToken;
        $this->employeeHeaders = ['Authorization' => "Bearer {$token}"];
    }

    public function test_mobile_check_in_is_visible_to_admin(): void
    {
        $this->postJson('/api/attendance/check-in', [], $this->employeeHeaders)
            ->assertOk();

        $this->getJson('/api/attendance?date='.now()->toDateString(), $this->adminHeaders)
            ->assertOk()
            ->assertJsonFragment([
                'employee_id' => $this->employee->id,
                'employee_name' => $this->employee->name,
            ]);
    }

    public function test_mobile_leave_request_can_be_approved_and_seen_by_employee(): void
    {
        $created = $this->postJson('/api/leave-requests', [
            'type' => 'annual',
            'from' => now()->addWeek()->toDateString(),
            'to' => now()->addWeek()->addDay()->toDateString(),
            'days' => 2,
            'notes' => 'Mobile integration test',
        ], $this->employeeHeaders)
            ->assertCreated();

        $leaveId = $created->json('id');

        $this->getJson('/api/leave-requests?status=pending', $this->adminHeaders)
            ->assertOk()
            ->assertJsonFragment([
                'id' => $leaveId,
                'employee_name' => $this->employee->name,
                'status' => 'pending',
            ]);

        $this->app['auth']->forgetGuards();
        $this->postJson("/api/leave-requests/{$leaveId}/approve", [], $this->adminHeaders)
            ->assertOk();

        $this->app['auth']->forgetGuards();
        $this->getJson('/api/leave-requests', $this->employeeHeaders)
            ->assertOk()
            ->assertJsonFragment([
                'id' => $leaveId,
                'status' => 'approved',
            ]);
    }

    public function test_admin_generated_payroll_is_visible_only_to_employee(): void
    {
        $month = now()->format('Y-m');

        $this->postJson('/api/payroll/generate', ['month' => $month], $this->adminHeaders)
            ->assertOk();

        $this->getJson("/api/payroll?month={$month}", $this->employeeHeaders)
            ->assertOk()
            ->assertJsonCount(1, 'data')
            ->assertJsonFragment([
                'employee_id' => $this->employee->id,
                'employee_name' => $this->employee->name,
            ]);

        $this->assertDatabaseHas(PayrollRecord::class, [
            'company_id' => $this->company->id,
            'employee_id' => $this->employee->id,
            'month' => $month,
        ]);
    }

    public function test_employee_cannot_see_another_employees_records(): void
    {
        $otherUser = User::factory()->create([
            'company_id' => $this->company->id,
            'role' => 'employee',
        ]);
        $otherEmployee = Employee::create([
            'company_id' => $this->company->id,
            'user_id' => $otherUser->id,
            'name' => $otherUser->name,
            'email' => $otherUser->email,
        ]);
        AttendanceRecord::create([
            'company_id' => $this->company->id,
            'employee_id' => $otherEmployee->id,
            'work_date' => now()->toDateString(),
            'status' => 'present',
        ]);
        LeaveRequest::create([
            'company_id' => $this->company->id,
            'employee_id' => $otherEmployee->id,
            'type' => 'sick',
            'from_date' => now()->addDay()->toDateString(),
            'to_date' => now()->addDay()->toDateString(),
            'days' => 1,
            'status' => 'pending',
        ]);

        $this->getJson('/api/attendance?date='.now()->toDateString(), $this->employeeHeaders)
            ->assertOk()
            ->assertJsonMissing(['employee_id' => $otherEmployee->id]);

        $this->getJson('/api/leave-requests', $this->employeeHeaders)
            ->assertOk()
            ->assertJsonMissing(['employee_name' => $otherEmployee->name]);
    }
}
