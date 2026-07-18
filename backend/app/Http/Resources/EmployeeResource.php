<?php

namespace App\Http\Resources;

use App\Models\Employee;
use App\Services\EmployeeAppAccessService;
use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

/**
 * @mixin Employee
 */
class EmployeeResource extends JsonResource
{
    /**
     * @return array<string, mixed>
     */
    public function toArray(Request $request): array
    {
        /** @var Employee $employee */
        $employee = $this->resource;

        return [
            'id' => $employee->id,
            'name' => $employee->name,
            'email' => $employee->email,
            'department' => $employee->department,
            'position' => $employee->position,
            'is_active' => (bool) $employee->is_active,
            'phone' => $employee->phone,
            'birth_date' => $employee->birth_date?->toDateString(),
            'hire_date' => $employee->hire_date?->toDateString(),
            'insurance_type' => $employee->insurance_type,
            'insurance_policy_number' => $employee->insurance_policy_number,
            'coverage_start' => $employee->coverage_start?->toDateString(),
            'coverage_end' => $employee->coverage_end?->toDateString(),
            'base_salary' => $employee->base_salary,
            'allowances' => $employee->allowances,
            'deductions' => $employee->deductions,
            'app_login_enabled' => app(EmployeeAppAccessService::class)->isEnabled($employee),
        ];
    }
}
