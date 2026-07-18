<?php

namespace Database\Seeders;

use App\Models\Permission;
use App\Models\Role;
use App\Models\User;
use Illuminate\Database\Seeder;

class RbacSeeder extends Seeder
{
    public function run(): void
    {
        $roles = [
            'super_admin' => 'Platform Super Admin',
            'company_admin' => 'Company Admin',
            'hr_manager' => 'HR Manager',
            'hr' => 'HR Specialist',
            'recruiter' => 'Recruiter',
            'employee' => 'Employee',
        ];

        $permissionsByRole = [
            'super_admin' => [
                'platform.manage',
                'ai.chat',
                'ai.usage.view',
            ],
            'company_admin' => [
                'ai.chat',
                'ai.job_description.generate',
                'ai.communication.generate',
                'ai.usage.view',
                'ai.prompt.manage',
                'ai.incident.manage',
                'employees.manage',
                'attendance.manage',
                'attendance.ai.insights',
                'attendance.ai.alerts',
                'leave.approve',
                'leave.ai.recommend',
                'performance.manage',
                'performance.ai.analyze',
                'payroll.manage',
                'recruitment.manage',
                'recruitment.ai.parse',
                'recruitment.ai.match',
                'reports.ai.summarize',
                'settings.manage',
            ],
            'hr_manager' => [
                'ai.chat',
                'ai.job_description.generate',
                'ai.communication.generate',
                'ai.usage.view',
                'ai.prompt.manage',
                'ai.incident.manage',
                'employees.manage',
                'attendance.manage',
                'attendance.ai.insights',
                'attendance.ai.alerts',
                'leave.approve',
                'leave.ai.recommend',
                'performance.manage',
                'performance.ai.analyze',
                'recruitment.manage',
                'recruitment.ai.parse',
                'recruitment.ai.match',
                'reports.ai.summarize',
            ],
            'hr' => [
                'ai.chat',
                'ai.job_description.generate',
                'employees.manage',
                'attendance.manage',
                'leave.approve',
                'leave.ai.recommend',
                'performance.manage',
                'reports.ai.summarize',
            ],
            'recruiter' => [
                'ai.chat',
                'ai.job_description.generate',
                'recruitment.manage',
                'recruitment.ai.parse',
                'recruitment.ai.match',
            ],
            'employee' => [
                'ai.chat',
            ],
        ];

        foreach ($roles as $name => $displayName) {
            Role::query()->updateOrCreate(
                ['name' => $name],
                ['display_name' => $displayName],
            );
        }

        $allPermissionNames = collect($permissionsByRole)->flatten()->unique()->values();
        foreach ($allPermissionNames as $permissionName) {
            Permission::query()->updateOrCreate(
                ['name' => $permissionName],
                ['display_name' => ucwords(str_replace(['.', '_'], ' ', $permissionName))],
            );
        }

        foreach ($permissionsByRole as $roleName => $permissionNames) {
            $role = Role::query()->where('name', $roleName)->first();
            if (! $role) {
                continue;
            }

            $permissionIds = Permission::query()
                ->whereIn('name', $permissionNames)
                ->pluck('id')
                ->all();

            $role->permissions()->sync($permissionIds);
        }

        User::query()->chunkById(200, function ($users): void {
            foreach ($users as $user) {
                $roleName = $user->role ?: 'employee';
                $role = Role::query()->where('name', $roleName)->first();
                if (! $role) {
                    $role = Role::query()->where('name', 'employee')->first();
                }
                if (! $role) {
                    continue;
                }
                $user->roles()->syncWithoutDetaching([$role->id]);
            }
        });
    }
}
