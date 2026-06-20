<?php

namespace Tests\Feature;

use App\Models\Employee;
use App\Models\LeaveRequest;
use App\Models\User;
use Tests\TestCase;

class LeaveTest extends TestCase
{
    private function createEmployee(): Employee
    {
        $user = User::factory()->create([
            'company_id' => $this->company->id,
            'role'       => 'employee',
        ]);
        return Employee::create([
            'company_id' => $this->company->id,
            'user_id'    => $user->id,
            'name'       => $user->name,
            'email'      => $user->email,
        ]);
    }

    public function test_admin_can_list_all_leave_requests(): void
    {
        $h = $this->adminHeaders();
        $emp = $this->createEmployee();
        LeaveRequest::create([
            'company_id'  => $this->company->id,
            'employee_id' => $emp->id,
            'type'        => 'annual',
            'from_date'   => '2025-03-01',
            'to_date'     => '2025-03-03',
            'days'        => 3,
            'status'      => 'pending',
        ]);

        $res = $this->getJson('/api/leave-requests', $h);
        $res->assertOk()->assertJsonStructure(['data', 'meta']);
        $this->assertCount(1, $res->json('data'));
    }

    public function test_leave_request_pagination_works(): void
    {
        $h = $this->adminHeaders();
        $emp = $this->createEmployee();
        for ($i = 0; $i < 5; $i++) {
            LeaveRequest::create([
                'company_id'  => $this->company->id,
                'employee_id' => $emp->id,
                'type'        => 'sick',
                'from_date'   => "2025-0{$i}-01",
                'to_date'     => "2025-0{$i}-01",
                'days'        => 1,
                'status'      => 'pending',
            ]);
        }

        $res = $this->getJson('/api/leave-requests?per_page=2', $h);
        $res->assertOk();
        $this->assertCount(2, $res->json('data'));
        $this->assertGreaterThan(1, $res->json('meta.last_page'));
    }

    public function test_status_filter_returns_correct_records(): void
    {
        $h = $this->adminHeaders();
        $emp = $this->createEmployee();

        LeaveRequest::create([
            'company_id' => $this->company->id, 'employee_id' => $emp->id,
            'type' => 'annual', 'from_date' => '2025-03-01', 'to_date' => '2025-03-01',
            'days' => 1, 'status' => 'approved',
        ]);
        LeaveRequest::create([
            'company_id' => $this->company->id, 'employee_id' => $emp->id,
            'type' => 'sick', 'from_date' => '2025-04-01', 'to_date' => '2025-04-01',
            'days' => 1, 'status' => 'pending',
        ]);

        $res = $this->getJson('/api/leave-requests?status=approved', $h);
        $res->assertOk();
        $this->assertCount(1, $res->json('data'));
        $this->assertEquals('approved', $res->json('data.0.status'));
    }

    public function test_admin_can_approve_leave(): void
    {
        $h = $this->adminHeaders();
        $emp = $this->createEmployee();
        $leave = LeaveRequest::create([
            'company_id'  => $this->company->id,
            'employee_id' => $emp->id,
            'type'        => 'annual',
            'from_date'   => '2025-03-01',
            'to_date'     => '2025-03-03',
            'days'        => 3,
            'status'      => 'pending',
        ]);

        $res = $this->postJson("/api/leave-requests/{$leave->id}/approve", [], $h);
        $res->assertOk();
        $this->assertDatabaseHas('leave_requests', ['id' => $leave->id, 'status' => 'approved']);
    }

    public function test_admin_can_reject_leave(): void
    {
        $h = $this->adminHeaders();
        $emp = $this->createEmployee();
        $leave = LeaveRequest::create([
            'company_id'  => $this->company->id,
            'employee_id' => $emp->id,
            'type'        => 'sick',
            'from_date'   => '2025-05-01',
            'to_date'     => '2025-05-01',
            'days'        => 1,
            'status'      => 'pending',
        ]);

        $res = $this->postJson("/api/leave-requests/{$leave->id}/reject", [], $h);
        $res->assertOk();
        $this->assertDatabaseHas('leave_requests', ['id' => $leave->id, 'status' => 'rejected']);
    }

    public function test_leave_balances_returns_employee_list(): void
    {
        $h = $this->adminHeaders();
        $this->createEmployee();

        $res = $this->getJson('/api/leave-balances', $h);
        $res->assertOk()->assertJsonStructure([['employee_name', 'annual', 'sick', 'emergency']]);
    }

    public function test_leave_recommendation_endpoint(): void
    {
        $h = $this->adminHeaders();
        $emp = $this->createEmployee();
        $leave = LeaveRequest::create([
            'company_id'  => $this->company->id,
            'employee_id' => $emp->id,
            'type'        => 'annual',
            'from_date'   => '2025-06-01',
            'to_date'     => '2025-06-02',
            'days'        => 2,
            'status'      => 'pending',
        ]);

        $res = $this->postJson("/api/leave-requests/{$leave->id}/recommendation", [], $h);
        $res->assertOk()->assertJsonStructure([
            'data' => ['recommended_action', 'confidence_score', 'reason'],
        ]);
        $this->assertDatabaseHas('leave_recommendations', [
            'leave_request_id' => $leave->id,
        ]);
    }
}
