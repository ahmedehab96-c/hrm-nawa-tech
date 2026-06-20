<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class LeaveRecommendation extends Model
{
    protected $fillable = [
        'company_id',
        'leave_request_id',
        'generated_by',
        'recommended_action',
        'confidence_score',
        'reason',
        'engine',
    ];

    public function leaveRequest(): BelongsTo
    {
        return $this->belongsTo(LeaveRequest::class);
    }
}
