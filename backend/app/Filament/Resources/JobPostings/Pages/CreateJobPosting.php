<?php

namespace App\Filament\Resources\JobPostings\Pages;

use App\Filament\Concerns\SetsCompanyOnCreate;
use App\Filament\Resources\JobPostings\JobPostingResource;
use Filament\Resources\Pages\CreateRecord;

class CreateJobPosting extends CreateRecord
{
    use SetsCompanyOnCreate;

    protected static string $resource = JobPostingResource::class;
}
