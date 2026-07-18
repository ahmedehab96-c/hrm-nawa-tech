<?php

namespace App\Filament\Resources\JobPostings\Schemas;

use App\Support\AdminTrans;
use Filament\Forms\Components\Select;
use Filament\Forms\Components\TextInput;
use Filament\Forms\Components\Textarea;
use Filament\Schemas\Schema;

class JobPostingForm
{
    public static function configure(Schema $schema): Schema
    {
        return $schema
            ->components([
                TextInput::make('title')
                    ->label(AdminTrans::field('title'))
                    ->required()
                    ->maxLength(255),
                TextInput::make('department')
                    ->label(AdminTrans::field('department'))
                    ->maxLength(120),
                TextInput::make('location')
                    ->label(AdminTrans::field('location'))
                    ->maxLength(120),
                Select::make('status')
                    ->label(AdminTrans::field('status'))
                    ->options(AdminTrans::options('job_status'))
                    ->default('open')
                    ->required(),
                Textarea::make('description')
                    ->label(AdminTrans::field('description'))
                    ->columnSpanFull()
                    ->rows(6),
            ]);
    }
}
