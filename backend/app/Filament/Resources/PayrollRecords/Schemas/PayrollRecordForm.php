<?php

namespace App\Filament\Resources\PayrollRecords\Schemas;

use App\Support\AdminTrans;
use Filament\Forms\Components\Select;
use Filament\Forms\Components\TextInput;
use Filament\Schemas\Schema;

class PayrollRecordForm
{
    public static function configure(Schema $schema): Schema
    {
        return $schema
            ->components([
                TextInput::make('company_id')
                    ->label(AdminTrans::field('company'))
                    ->required()
                    ->numeric(),
                Select::make('employee_id')
                    ->label(AdminTrans::field('employee'))
                    ->relationship('employee', 'name')
                    ->required(),
                TextInput::make('month')
                    ->label(AdminTrans::field('month'))
                    ->required(),
                TextInput::make('base_salary')
                    ->label(AdminTrans::field('base_salary'))
                    ->required()
                    ->numeric()
                    ->default(0),
                TextInput::make('allowances')
                    ->label(AdminTrans::field('allowances'))
                    ->required()
                    ->numeric()
                    ->default(0),
                TextInput::make('deductions')
                    ->label(AdminTrans::field('deductions'))
                    ->required()
                    ->numeric()
                    ->default(0),
                TextInput::make('net_salary')
                    ->label(AdminTrans::field('net_salary'))
                    ->required()
                    ->numeric()
                    ->default(0),
                Select::make('status')
                    ->label(AdminTrans::field('status'))
                    ->options(AdminTrans::options('payroll_status'))
                    ->default('pending')
                    ->required(),
            ]);
    }
}
