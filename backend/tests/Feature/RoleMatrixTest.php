<?php

namespace Tests\Feature;

use App\Models\Company;
use App\Models\Employee;
use App\Models\JobPosting;
use App\Models\User;
use Tests\TestCase;

/**
 * Covers the RBAC role matrix for the admin/shared APIs and multi-tenant
 * company isolation. Pivot roles/permissions are the source of truth; in the
 * test database (no RBAC seeder) the legacy per-role permission fallback on the
 * User model provides the same effective matrix.
 */
class RoleMatrixTest extends TestCase
{
    /**
     * @return array<string, string>
     */
    private function headersFor(string $role, ?Company $company = null): array
    {
        $company ??= $this->company;
        $user = User::factory()->create([
            'company_id' => $company->id,
            'role' => $role,
        ]);

        return ['Authorization' => 'Bearer '.$user->createToken('t')->plainTextToken];
    }

    public function test_hr_manager_can_access_employees_admin_api(): void
    {
        $this->setupCompany();
        Employee::create(['company_id' => $this->company->id, 'name' => 'A', 'email' => 'a@test.com']);

        $this->getJson('/api/employees', $this->headersFor('hr_manager'))
            ->assertOk()
            ->assertJsonStructure(['data', 'meta']);
    }

    public function test_hr_specialist_can_access_employees_admin_api(): void
    {
        $this->setupCompany();

        $this->getJson('/api/employees', $this->headersFor('hr'))
            ->assertOk()
            ->assertJsonStructure(['data', 'meta']);
    }

    public function test_recruiter_cannot_access_employees_but_can_access_jobs(): void
    {
        $this->setupCompany();
        $h = $this->headersFor('recruiter');

        $this->getJson('/api/employees', $h)->assertStatus(403);
        $this->getJson('/api/jobs', $h)->assertOk();
    }

    public function test_recruiter_cannot_approve_leave(): void
    {
        $this->setupCompany();

        // Non-existent id: 403 (missing permission) must fire before 404 lookup.
        $this->postJson('/api/leave-requests/1/approve', [], $this->headersFor('recruiter'))
            ->assertStatus(403);
    }

    public function test_hr_manager_can_reach_leave_decisions(): void
    {
        $this->setupCompany();

        // Passes the permission gate (leave.approve); 404 because the id does
        // not exist, proving the role/permission gate allowed the request.
        $this->postJson('/api/leave-requests/999/approve', [], $this->headersFor('hr_manager'))
            ->assertStatus(404);
    }

    public function test_employee_cannot_access_admin_apis(): void
    {
        $this->setupCompany();
        $h = $this->headersFor('employee');

        $this->getJson('/api/employees', $h)->assertStatus(403);
        $this->getJson('/api/jobs', $h)->assertStatus(403);
    }

    public function test_hr_can_list_leave_requests_shared_endpoint(): void
    {
        $this->setupCompany();

        $this->getJson('/api/leave-requests', $this->headersFor('hr'))
            ->assertOk()
            ->assertJsonStructure(['data', 'meta']);
    }

    public function test_recruiter_jobs_are_scoped_to_their_company(): void
    {
        $this->setupCompany();
        $other = $this->otherCompany();
        JobPosting::create(['company_id' => $other->id, 'title' => 'Other Co Job', 'status' => 'open']);
        JobPosting::create(['company_id' => $this->company->id, 'title' => 'My Job', 'status' => 'open']);

        $res = $this->getJson('/api/jobs', $this->headersFor('recruiter'));
        $res->assertOk();
        $this->assertCount(1, $res->json());
    }

    public function test_employee_only_sees_own_record_and_not_other_company(): void
    {
        $this->setupCompany();
        $employeeUser = User::factory()->create([
            'company_id' => $this->company->id,
            'role' => 'employee',
        ]);
        Employee::create([
            'company_id' => $this->company->id,
            'user_id' => $employeeUser->id,
            'name' => $employeeUser->name,
            'email' => $employeeUser->email,
        ]);

        $other = $this->otherCompany();
        Employee::create(['company_id' => $other->id, 'name' => 'Foreign', 'email' => 'foreign@test.com']);

        $h = ['Authorization' => 'Bearer '.$employeeUser->createToken('t')->plainTextToken];

        $this->getJson('/api/employees/me', $h)
            ->assertOk()
            ->assertJsonPath('data.email', $employeeUser->email);
    }
}
