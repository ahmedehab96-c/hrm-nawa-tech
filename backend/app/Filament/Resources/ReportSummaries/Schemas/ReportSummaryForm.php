<?php

namespace App\Filament\Resources\ReportSummaries\Schemas;

use App\Support\AdminTrans;
use Filament\Forms\Components\DatePicker;
use Filament\Forms\Components\TextInput;
use Filament\Forms\Components\Textarea;
use Filament\Schemas\Schema;

class ReportSummaryForm
{
    public static function configure(Schema $schema): Schema
    {
        return $schema
            ->components([
                TextInput::make('company_id')
                    ->label(AdminTrans::field('company'))
                    ->required()
                    ->numeric(),
                TextInput::make('generated_by')
                    ->label(AdminTrans::field('user'))
                    ->numeric(),
                TextInput::make('report_type')
                    ->label(AdminTrans::field('report_type'))
                    ->required()
                    ->default('hr_overview'),
                DatePicker::make('period_start')
                    ->label(AdminTrans::field('period_start'))
                    ->required(),
                DatePicker::make('period_end')
                    ->label(AdminTrans::field('period_end'))
                    ->required(),
                Textarea::make('metrics_json')
                    ->label(AdminTrans::section('metrics'))
                    ->columnSpanFull(),
                Textarea::make('narrative')
                    ->label(AdminTrans::field('narrative'))
                    ->required()
                    ->columnSpanFull(),
                TextInput::make('provider')
                    ->label(AdminTrans::field('provider')),
                TextInput::make('model')
                    ->label(AdminTrans::field('ai_model')),
            ]);
    }
}
