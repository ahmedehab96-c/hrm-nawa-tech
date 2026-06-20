<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class ReportSummary extends Model
{
    protected $fillable = [
        'company_id',
        'generated_by',
        'report_type',
        'period_start',
        'period_end',
        'metrics_json',
        'narrative',
        'provider',
        'model',
    ];

    protected function casts(): array
    {
        return [
            'period_start' => 'date',
            'period_end' => 'date',
            'metrics_json' => 'array',
        ];
    }
}
