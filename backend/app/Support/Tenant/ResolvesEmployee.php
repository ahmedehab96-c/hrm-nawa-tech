<?php

namespace App\Support\Tenant;

use App\Models\Employee;
use App\Models\User;
use Illuminate\Http\Request;

/**
 * Shared helpers for resolving an Employee record from the authenticated user.
 * Keeps the "which employee is acting" logic in one place so controllers stay
 * thin and consistent.
 */
trait ResolvesEmployee
{
    /**
     * The employee record linked to a given user (mobile app users).
     */
    protected function currentEmployee(User $user): ?Employee
    {
        return Employee::query()
            ->where('company_id', $user->company_id)
            ->where('user_id', $user->id)
            ->first();
    }

    /**
     * Resolve the target employee for a request:
     * - employee role: their own linked record
     * - admin/HR roles: explicit employee_id if provided, otherwise the record
     *   matching the acting user's email (self-service fallback).
     */
    protected function resolveEmployeeForUser(Request $request): ?Employee
    {
        $user = $request->user();

        if ($user->role === 'employee') {
            return $this->currentEmployee($user);
        }

        $employeeId = $request->input('employee_id');
        if ($employeeId) {
            return Employee::query()->find($employeeId);
        }

        return Employee::query()
            ->where('company_id', $user->company_id)
            ->where('email', $user->email)
            ->first();
    }
}
