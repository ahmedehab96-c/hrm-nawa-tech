<?php

namespace App\Filament\Resources\Candidates\Schemas;

use App\Models\JobPosting;
use App\Support\AdminTrans;
use Filament\Forms\Components\Select;
use Filament\Forms\Components\TextInput;
use Filament\Forms\Components\Textarea;
use Filament\Schemas\Schema;

class CandidateForm
{
    public static function configure(Schema $schema): Schema
    {
        return $schema
            ->components([
                Select::make('job_posting_id')
                    ->label(AdminTrans::field('job'))
                    ->options(function (): array {
                        $companyId = auth()->user()?->company_id;
                        $query = JobPosting::query()->orderBy('title');
                        if ($companyId && ! auth()->user()?->hasRole('super_admin')) {
                            $query->where('company_id', $companyId);
                        }

                        return $query->pluck('title', 'id')->all();
                    })
                    ->searchable()
                    ->required(),
                TextInput::make('name')->label(AdminTrans::field('name'))->required()->maxLength(255),
                TextInput::make('email')->label(AdminTrans::field('email'))->email()->maxLength(255),
                TextInput::make('phone')->label(AdminTrans::field('phone'))->tel()->maxLength(50),
                Select::make('stage')
                    ->label(AdminTrans::field('stage'))
                    ->options(AdminTrans::options('candidate_stage'))
                    ->default('new')
                    ->required(),
                TextInput::make('years_experience')
                    ->label(AdminTrans::field('experience_years'))
                    ->numeric()
                    ->minValue(0),
                TextInput::make('ai_fit_score')
                    ->label(AdminTrans::field('ai_fit_score'))
                    ->numeric()
                    ->minValue(0)
                    ->maxValue(100),
                Textarea::make('notes')->label(AdminTrans::field('notes'))->columnSpanFull(),
                Textarea::make('cv_summary')->label(AdminTrans::field('cv_summary'))->columnSpanFull(),
                Textarea::make('resume_text')->label(AdminTrans::field('resume_text'))->columnSpanFull()->rows(6),
                Textarea::make('ai_match_reason')->label(AdminTrans::field('ai_match_reason'))->columnSpanFull(),
            ]);
    }
}
