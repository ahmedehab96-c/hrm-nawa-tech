<?php

namespace Database\Seeders;

use App\Models\Company;
use App\Models\Employee;
use App\Models\Role;
use App\Models\User;
use Illuminate\Support\Facades\Hash;

/**
 * Creates 2 clearly-labeled demo employees for a newly registered company.
 * Admins can delete them later from the employees screen.
 */
class DemoCompanySeeder
{
    public static function seedTrialEmployees(Company $company): array
    {
        $password = 'Employee12345!';
        $suffix = $company->id;
        $rows = [
            [
                'name' => 'Demo Employee 1',
                'email' => "demo.emp1.{$suffix}@trial.local",
                'department' => 'Demo',
                'position' => 'Trial staff',
                'phone' => '+966500000001',
            ],
            [
                'name' => 'Demo Employee 2',
                'email' => "demo.emp2.{$suffix}@trial.local",
                'department' => 'Demo',
                'position' => 'Trial staff',
                'phone' => '+966500000002',
            ],
        ];

        $created = [];
        foreach ($rows as $row) {
            $appUser = User::query()->updateOrCreate(
                ['email' => $row['email']],
                [
                    'company_id' => $company->id,
                    'name' => $row['name'],
                    'role' => 'employee',
                    'password' => Hash::make($password),
                ]
            );

            $role = Role::query()->where('name', 'employee')->first();
            if ($role) {
                $appUser->roles()->syncWithoutDetaching([$role->id]);
            }

            Employee::query()->updateOrCreate(
                [
                    'company_id' => $company->id,
                    'email' => $row['email'],
                ],
                [
                    'user_id' => $appUser->id,
                    'name' => $row['name'],
                    'phone' => $row['phone'],
                    'department' => $row['department'],
                    'position' => $row['position'],
                    'is_active' => true,
                    'hire_date' => now()->toDateString(),
                    'base_salary' => 4000,
                    'allowances' => 0,
                    'deductions' => 0,
                ]
            );

            $created[] = [
                'email' => $row['email'],
                'password' => $password,
                'name' => $row['name'],
            ];

            if (! $appUser->hasVerifiedEmail()) {
                $appUser->forceFill(['email_verified_at' => now()])->save();
            }
        }

        return $created;
    }
}
