<?php

namespace App\Filament\Resources\Companies\Schemas;

use App\Support\AdminTrans;
use Filament\Forms\Components\DateTimePicker;
use Filament\Forms\Components\Select;
use Filament\Forms\Components\TextInput;
use Filament\Forms\Components\Textarea;
use Filament\Forms\Components\Toggle;
use Filament\Schemas\Components\Section;
use Filament\Schemas\Schema;

class CompanyForm
{
    public static function configure(Schema $schema): Schema
    {
        return $schema
            ->components([
                Section::make(AdminTrans::section('company'))
                    ->columns(2)
                    ->schema([
                        TextInput::make('name')->label(AdminTrans::field('name'))->required(),
                        TextInput::make('email')->label(AdminTrans::field('email'))->email(),
                        TextInput::make('phone')->label(AdminTrans::field('phone'))->tel(),
                        TextInput::make('address')->label(AdminTrans::field('address'))->columnSpanFull(),
                        TextInput::make('wifi_ssid')->label(AdminTrans::field('wifi_ssid')),
                        Select::make('status')
                            ->label(AdminTrans::field('status'))
                            ->options(AdminTrans::options('company_status'))
                            ->default('active')
                            ->required(),
                        Select::make('plan')
                            ->label(AdminTrans::field('plan'))
                            ->options(array_merge(
                                ['trial' => AdminTrans::optionLabel('company_status', 'trial')],
                                AdminTrans::options('plan'),
                            ))
                            ->default('trial')
                            ->required(),
                        DateTimePicker::make('trial_ends_at')->label(AdminTrans::field('trial_ends_at')),
                    ]),
                Section::make(AdminTrans::section('ai_settings'))
                    ->collapsed()
                    ->columns(2)
                    ->schema([
                        TextInput::make('ai_plan')->label(AdminTrans::field('ai_plan'))->default('enterprise'),
                        Toggle::make('ai_enabled')->label(AdminTrans::field('ai_enabled'))->default(true),
                        TextInput::make('ai_provider')->label(AdminTrans::field('ai_provider'))->default('openai'),
                        TextInput::make('ai_model')->label(AdminTrans::field('ai_model')),
                        TextInput::make('ai_requests_per_minute')
                            ->label(AdminTrans::field('ai_requests_per_minute'))
                            ->numeric()
                            ->default(60),
                        TextInput::make('ai_monthly_token_limit')
                            ->label(AdminTrans::field('ai_monthly_token_limit'))
                            ->numeric()
                            ->default(500000),
                        Textarea::make('ai_feature_flags')->columnSpanFull(),
                    ]),
            ]);
    }
}
