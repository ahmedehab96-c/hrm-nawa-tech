<?php

namespace Tests\Feature;

use App\Models\User;
use App\Services\CompanyRegistrationService;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Tests\TestCase;

class CompanyRegistrationServiceTest extends TestCase
{
    use RefreshDatabase;

    public function test_register_creates_trial_company_admin_and_demo_employees(): void
    {
        $result = app(CompanyRegistrationService::class)->register(
            adminName: 'Trial Admin',
            email: 'trial.admin@example.com',
            password: 'Password123!',
            companyName: 'Trial Co',
        );

        $this->assertDatabaseHas('companies', [
            'name' => 'Trial Co',
            'plan' => 'trial',
        ]);
        $this->assertDatabaseHas('users', [
            'email' => 'trial.admin@example.com',
            'role' => 'company_admin',
            'company_id' => $result['company']->id,
        ]);
        $this->assertCount(2, $result['demo_employees']);
        $this->assertInstanceOf(User::class, $result['user']);
        $this->assertTrue($result['company']->trial_ends_at->isFuture());
    }
}
