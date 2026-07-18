<?php

namespace App\Filament\Resources\LeaveRequests\Schemas;

use App\Models\Employee;
use App\Support\AdminTrans;
use Filament\Forms\Components\DatePicker;
use Filament\Forms\Components\Select;
use Filament\Forms\Components\TextInput;
use Filament\Forms\Components\Textarea;
use Filament\Schemas\Schema;

class LeaveRequestForm
{
    public static function configure(Schema $schema): Schema
    {
        return $schema
            ->components([
                Select::make('employee_id')
                    ->label(AdminTrans::field('employee'))
                    ->options(function (): array {
                        $companyId = auth()->user()?->company_id;
                        $query = Employee::query()->orderBy('name');
                        if ($companyId && ! auth()->user()?->hasRole('super_admin')) {
                            $query->where('company_id', $companyId);
                        }

                        return $query->pluck('name', 'id')->all();
                    })
                    ->searchable()
                    ->required(),
                Select::make('type')
                    ->label(AdminTrans::field('type'))
                    ->options(AdminTrans::options('leave_type'))
                    ->required(),
                DatePicker::make('from_date')
                    ->label(AdminTrans::field('from_date'))
                    ->required(),
                DatePicker::make('to_date')
                    ->label(AdminTrans::field('to_date'))
                    ->required()
                    ->afterOrEqual('from_date'),
                TextInput::make('days')
                    ->label(AdminTrans::field('days'))
                    ->numeric()
                    ->default(1)
                    ->required(),
                Select::make('status')
                    ->label(AdminTrans::field('status'))
                    ->options(AdminTrans::options('leave_status'))
                    ->default('pending')
                    ->required(),
                Textarea::make('notes')
                    ->label(AdminTrans::field('notes'))
                    ->columnSpanFull(),
            ]);
    }
}
