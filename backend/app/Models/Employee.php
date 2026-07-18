<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\HasMany;

class Employee extends Model
{
    protected $fillable = [
        'company_id',
        'user_id',
        'name',
        'email',
        'phone',
        'birth_date',
        'department',
        'position',
        'hire_date',
        'is_active',
        'insurance_type',
        'insurance_policy_number',
        'coverage_start',
        'coverage_end',
        'base_salary',
        'allowances',
        'deductions',
    ];

    protected function casts(): array
    {
        return [
            'birth_date' => 'date',
            'hire_date' => 'date',
            'coverage_start' => 'date',
            'coverage_end' => 'date',
            'base_salary' => 'float',
            'allowances' => 'float',
            'deductions' => 'float',
            'is_active' => 'boolean',
        ];
    }

    public function attendanceRecords(): HasMany
    {
        return $this->hasMany(AttendanceRecord::class);
    }

    public function leaveRequests(): HasMany
    {
        return $this->hasMany(LeaveRequest::class);
    }

    public function payrollRecords(): HasMany
    {
        return $this->hasMany(PayrollRecord::class);
    }
}
