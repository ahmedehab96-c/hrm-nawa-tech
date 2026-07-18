<?php

namespace Tests\Feature;

use App\Models\Company;
use App\Models\Role;
use App\Models\User;
use App\Services\TeamUserService;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Tests\TestCase;

class TeamUserServiceTest extends TestCase
{
    use RefreshDatabase;

    protected function setUp(): void
    {
        parent::setUp();
        Role::query()->create(['name' => 'hr_manager', 'display_name' => 'HR Manager']);
    }

    public function test_team_user_service_creates_admin_user_with_role(): void
    {
        $company = Company::query()->create([
            'name' => 'Co',
            'status' => 'active',
            'plan' => 'trial',
        ]);

        $user = app(TeamUserService::class)->createForCompany(
            $company->id,
            'HR Lead',
            'hr@co.test',
            'Password123!',
            'hr_manager',
        );

        $this->assertSame('hr_manager', $user->role);
        $this->assertTrue($user->hasRole('hr_manager'));
        $this->assertSame($company->id, $user->company_id);
    }

    public function test_team_user_service_rejects_employee_role(): void
    {
        $company = Company::query()->create([
            'name' => 'Co',
            'status' => 'active',
            'plan' => 'trial',
        ]);

        $this->expectException(\InvalidArgumentException::class);

        app(TeamUserService::class)->createForCompany(
            $company->id,
            'Emp',
            'emp@co.test',
            'Password123!',
            'employee',
        );
    }
}
