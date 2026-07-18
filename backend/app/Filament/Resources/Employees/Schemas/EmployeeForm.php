<?php

namespace App\Filament\Resources\Employees\Schemas;

use App\Support\AdminTrans;
use Filament\Forms\Components\DatePicker;
use Filament\Forms\Components\TextInput;
use Filament\Forms\Components\Toggle;
use Filament\Schemas\Schema;

class EmployeeForm
{
    public static function configure(Schema $schema): Schema
    {
        return $schema
            ->components([
                TextInput::make('name')
                    ->label(AdminTrans::field('name'))
                    ->required()
                    ->maxLength(255),
                TextInput::make('email')
                    ->label(AdminTrans::field('email'))
                    ->email()
                    ->required()
                    ->maxLength(255),
                TextInput::make('phone')
                    ->label(AdminTrans::field('phone'))
                    ->tel()
                    ->maxLength(50),
                TextInput::make('department')
                    ->label(AdminTrans::field('department'))
                    ->maxLength(120),
                TextInput::make('position')
                    ->label(AdminTrans::field('position'))
                    ->maxLength(120),
                DatePicker::make('hire_date')
                    ->label(AdminTrans::field('hire_date')),
                DatePicker::make('birth_date')
                    ->label(AdminTrans::field('birth_date')),
                Toggle::make('is_active')
                    ->label(AdminTrans::field('is_active'))
                    ->default(true)
                    ->required(),
                TextInput::make('base_salary')
                    ->label(AdminTrans::field('base_salary'))
                    ->numeric()
                    ->default(0)
                    ->required(),
                TextInput::make('allowances')
                    ->label(AdminTrans::field('allowances'))
                    ->numeric()
                    ->default(0)
                    ->required(),
                TextInput::make('deductions')
                    ->label(AdminTrans::field('deductions'))
                    ->numeric()
                    ->default(0)
                    ->required(),
                TextInput::make('insurance_type')
                    ->label(AdminTrans::field('insurance_type'))
                    ->maxLength(120),
                TextInput::make('insurance_policy_number')
                    ->label(AdminTrans::field('insurance_policy_number'))
                    ->maxLength(120),
                DatePicker::make('coverage_start')
                    ->label(AdminTrans::field('coverage_start')),
                DatePicker::make('coverage_end')
                    ->label(AdminTrans::field('coverage_end')),
            ]);
    }
}
