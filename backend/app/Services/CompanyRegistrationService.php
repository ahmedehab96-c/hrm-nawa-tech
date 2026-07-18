<?php

namespace App\Services;

use App\Models\Company;
use App\Models\Role;
use App\Models\User;
use Database\Seeders\DemoCompanySeeder;
use Illuminate\Support\Facades\Hash;

class CompanyRegistrationService
{
    /**
     * @return array{user: User, company: Company, demo_employees: array<int, array<string, string>>}
     */
    public function register(
        string $adminName,
        string $email,
        string $password,
        ?string $companyName = null,
    ): array {
        $company = Company::query()->create([
            'name' => $companyName ?: $adminName,
            'status' => 'active',
            'plan' => 'trial',
            'trial_ends_at' => now()->addDays(14),
            'ai_plan' => 'starter',
            'ai_enabled' => true,
        ]);

        $user = User::query()->create([
            'company_id' => $company->id,
            'name' => $adminName,
            'email' => $email,
            'password' => Hash::make($password),
            'role' => 'company_admin',
        ]);

        $role = Role::query()->where('name', 'company_admin')->first();
        if ($role) {
            $user->roles()->syncWithoutDetaching([$role->id]);
        }

        $demoEmployees = DemoCompanySeeder::seedTrialEmployees($company);

        return [
            'user' => $user,
            'company' => $company,
            'demo_employees' => $demoEmployees,
        ];
    }
}
