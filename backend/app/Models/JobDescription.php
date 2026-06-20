<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class JobDescription extends Model
{
    protected $fillable = [
        'company_id',
        'job_posting_id',
        'created_by',
        'job_title',
        'department',
        'location',
        'employment_type',
        'language_code',
        'tone',
        'content',
        'provider',
        'model',
    ];

    public function company(): BelongsTo
    {
        return $this->belongsTo(Company::class);
    }

    public function creator(): BelongsTo
    {
        return $this->belongsTo(User::class, 'created_by');
    }
}
