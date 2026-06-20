<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class AttendanceInsight extends Model
{
    protected $fillable = [
        'company_id',
        'generated_by',
        'period_start',
        'period_end',
        'total_records',
        'present_count',
        'late_count',
        'absent_count',
        'risk_employees_json',
        'summary',
    ];

    protected function casts(): array
    {
        return [
            'period_start' => 'date',
            'period_end' => 'date',
            'risk_employees_json' => 'array',
        ];
    }
}
