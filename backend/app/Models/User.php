<?php

namespace App\Models;

// use Illuminate\Contracts\Auth\MustVerifyEmail;
use App\Notifications\ResetPasswordNotification;
use Database\Factories\UserFactory;
use Illuminate\Database\Eloquent\Attributes\Fillable;
use Illuminate\Database\Eloquent\Attributes\Hidden;
use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Relations\BelongsToMany;
use Illuminate\Foundation\Auth\User as Authenticatable;
use Illuminate\Notifications\Notifiable;
use Illuminate\Support\Facades\DB;
use Laravel\Sanctum\HasApiTokens;

#[Fillable(['company_id', 'name', 'email', 'password', 'role'])]
#[Hidden(['password', 'remember_token'])]
class User extends Authenticatable
{
    /** @use HasFactory<UserFactory> */
    use HasApiTokens, HasFactory, Notifiable;

    /**
     * Get the attributes that should be cast.
     *
     * @return array<string, string>
     */
    protected function casts(): array
    {
        return [
            'email_verified_at' => 'datetime',
            'password' => 'hashed',
        ];
    }

    public function sendPasswordResetNotification(#[\SensitiveParameter] $token): void
    {
        $this->notify(new ResetPasswordNotification($token));
    }

    public function roles(): BelongsToMany
    {
        return $this->belongsToMany(Role::class, 'role_user')->withTimestamps();
    }

    public function hasRole(string $role): bool
    {
        if ($this->role === $role) {
            return true;
        }

        return $this->roles()
            ->where('name', $role)
            ->exists();
    }

    /**
     * @param  array<int, string>  $roles
     */
    public function hasAnyRole(array $roles): bool
    {
        if (in_array($this->role, $roles, true)) {
            return true;
        }

        return $this->roles()
            ->whereIn('name', $roles)
            ->exists();
    }

    public function hasPermission(string $permission): bool
    {
        return $this->hasAnyPermission([$permission]);
    }

    /**
     * @param  array<int, string>  $permissions
     */
    public function hasAnyPermission(array $permissions): bool
    {
        // شركة الأدمن يملك صلاحيات كاملة افتراضياً لتسهيل التشغيل.
        if ($this->hasRole('company_admin')) {
            return true;
        }

        if (empty($permissions)) {
            return true;
        }

        $fromPivot = DB::table('role_user')
            ->join('permission_role', 'role_user.role_id', '=', 'permission_role.role_id')
            ->join('permissions', 'permission_role.permission_id', '=', 'permissions.id')
            ->where('role_user.user_id', $this->id)
            ->whereIn('permissions.name', $permissions)
            ->exists();

        if ($fromPivot) {
            return true;
        }

        // توافق رجعي لحين مزامنة كل المستخدمين إلى pivot RBAC.
        $legacy = match ($this->role) {
            'employee' => ['ai.chat'],
            'recruiter' => [
                'ai.chat',
                'ai.job_description.generate',
                'recruitment.manage',
                'recruitment.ai.parse',
                'recruitment.ai.match',
            ],
            'hr_manager', 'hr' => [
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
            default => [],
        };

        return ! empty(array_intersect($permissions, $legacy));
    }
}
