<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class Candidate extends Model
{
    protected $fillable = [
        'company_id',
        'job_posting_id',
        'name',
        'email',
        'phone',
        'stage',
        'notes',
        'resume_text',
        'cv_summary',
        'skills_json',
        'years_experience',
        'ai_fit_score',
        'ai_match_reason',
        'ai_parsed_at',
    ];

    protected function casts(): array
    {
        return [
            'skills_json' => 'array',
            'years_experience' => 'float',
            'ai_fit_score' => 'integer',
            'ai_parsed_at' => 'datetime',
        ];
    }

    public function jobPosting(): BelongsTo
    {
        return $this->belongsTo(JobPosting::class, 'job_posting_id');
    }
}
