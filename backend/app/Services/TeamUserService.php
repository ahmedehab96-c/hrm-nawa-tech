<?php

namespace App\Services;

use App\Models\Role;
use App\Models\User;
use Illuminate\Support\Facades\Hash;
use InvalidArgumentException;

class TeamUserService
{
    /** @var list<string> */
    public const ADMIN_ROLES = [
        'company_admin',
        'hr_manager',
        'hr',
        'recruiter',
    ];

    /**
     * @return list<string>
     */
    public function assignableRoles(?User $actor = null): array
    {
        if ($actor?->hasRole('super_admin')) {
            return self::ADMIN_ROLES;
        }

        if ($actor?->hasRole('company_admin')) {
            return self::ADMIN_ROLES;
        }

        return [];
    }

    public function createForCompany(
        int $companyId,
        string $name,
        string $email,
        string $password,
        string $role,
    ): User {
        $this->assertAssignableRole($role);

        $user = User::query()->create([
            'company_id' => $companyId,
            'name' => $name,
            'email' => $email,
            'password' => Hash::make($password),
            'role' => $role,
        ]);

        $this->syncRole($user, $role);

        return $user->refresh();
    }

    public function syncRole(User $user, string $role): void
    {
        $this->assertAssignableRole($role);

        $user->role = $role;
        $user->save();

        $roleModel = Role::query()->where('name', $role)->first();
        if ($roleModel !== null) {
            $user->roles()->sync([$roleModel->id]);
        }
    }

    public function resetPassword(User $user, string $password): void
    {
        $user->password = Hash::make($password);
        $user->save();
    }

    private function assertAssignableRole(string $role): void
    {
        if (! in_array($role, self::ADMIN_ROLES, true)) {
            throw new InvalidArgumentException("Role not assignable: {$role}");
        }
    }
}
