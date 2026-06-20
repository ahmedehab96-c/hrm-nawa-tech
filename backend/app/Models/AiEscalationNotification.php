<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class AiEscalationNotification extends Model
{
    protected $fillable = [
        'company_id',
        'triggered_by_user_id',
        'alert_code',
        'severity',
        'level',
        'channel',
        'recipient',
        'message',
        'status',
        'attempts',
        'max_attempts',
        'last_error',
        'payload',
        'scheduled_for',
        'sent_at',
        'failed_at',
    ];

    protected function casts(): array
    {
        return [
            'payload' => 'array',
            'scheduled_for' => 'datetime',
            'sent_at' => 'datetime',
            'failed_at' => 'datetime',
        ];
    }

    public function company(): BelongsTo
    {
        return $this->belongsTo(Company::class);
    }

    public function triggeredByUser(): BelongsTo
    {
        return $this->belongsTo(User::class, 'triggered_by_user_id');
    }
}
