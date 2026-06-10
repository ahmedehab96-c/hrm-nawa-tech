<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\HasMany;

class JobPosting extends Model
{
    protected $fillable = [
        'company_id',
        'title',
        'department',
        'location',
        'description',
        'status',
    ];

    public function candidates(): HasMany
    {
        return $this->hasMany(Candidate::class, 'job_posting_id');
    }
}
