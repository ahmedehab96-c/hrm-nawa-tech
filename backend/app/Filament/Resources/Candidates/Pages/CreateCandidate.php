<?php

namespace App\Filament\Resources\Candidates\Pages;

use App\Filament\Concerns\SetsCompanyOnCreate;
use App\Filament\Resources\Candidates\CandidateResource;
use Filament\Resources\Pages\CreateRecord;

class CreateCandidate extends CreateRecord
{
    use SetsCompanyOnCreate;

    protected static string $resource = CandidateResource::class;
}
