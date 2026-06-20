<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class AiAuditEvent extends Model
{
    protected $fillable = [
        'company_id',
        'user_id',
        'event_type',
        'severity',
        'endpoint',
        'context',
        'event_at',
    ];

    protected function casts(): array
    {
        return [
            'context' => 'array',
            'event_at' => 'datetime',
        ];
    }

    public function company(): BelongsTo
    {
        return $this->belongsTo(Company::class);
    }

    public function user(): BelongsTo
    {
        return $this->belongsTo(User::class);
    }
}
