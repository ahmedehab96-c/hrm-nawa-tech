<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

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
}
