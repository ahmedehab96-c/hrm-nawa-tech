<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class AttendanceAlert extends Model
{
    protected $fillable = [
        'company_id',
        'employee_id',
        'generated_by',
        'alert_type',
        'severity',
        'status',
        'message',
        'generated_at',
        'resolved_at',
    ];

    protected function casts(): array
    {
        return [
            'generated_at' => 'datetime',
            'resolved_at' => 'datetime',
        ];
    }

    public function employee(): BelongsTo
    {
        return $this->belongsTo(Employee::class);
    }
}
