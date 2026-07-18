<?php

namespace App\Services;

use App\Models\Employee;
use App\Models\Role;
use App\Models\User;
use Illuminate\Support\Facades\Hash;

class EmployeeAppAccessService
{
    public function isEnabled(Employee $employee): bool
    {
        if ($employee->company_id === null || ! filled($employee->email)) {
            return false;
        }

        return User::query()
            ->where('company_id', $employee->company_id)
            ->where('email', $employee->email)
            ->where('role', 'employee')
            ->exists();
    }

    public function enable(Employee $employee, string $password): User
    {
        $appUser = User::query()->updateOrCreate(
            [
                'company_id' => $employee->company_id,
                'email' => $employee->email,
            ],
            [
                'name' => $employee->name,
                'password' => Hash::make($password),
                'role' => 'employee',
            ],
        );

        $this->syncEmployeeRole($appUser);
        $employee->user_id = $appUser->id;
        $employee->save();

        return $appUser;
    }

    public function disable(Employee $employee): void
    {
        User::query()
            ->where('company_id', $employee->company_id)
            ->where('email', $employee->email)
            ->where('role', 'employee')
            ->delete();

        $employee->user_id = null;
        $employee->save();
    }

    private function syncEmployeeRole(User $user): void
    {
        $role = Role::query()->where('name', 'employee')->first();
        if ($role === null) {
            return;
        }

        $user->roles()->syncWithoutDetaching([$role->id]);
    }
}
