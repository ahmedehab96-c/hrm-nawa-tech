<?php

namespace App\Filament\Resources\AttendanceRecords\Schemas;

use App\Support\AdminTrans;
use Filament\Forms\Components\DatePicker;
use Filament\Forms\Components\DateTimePicker;
use Filament\Forms\Components\Select;
use Filament\Forms\Components\TextInput;
use Filament\Schemas\Schema;

class AttendanceRecordForm
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
                DatePicker::make('work_date')
                    ->label(AdminTrans::field('work_date'))
                    ->required(),
                DateTimePicker::make('check_in_at')
                    ->label(AdminTrans::field('check_in_at')),
                DateTimePicker::make('check_out_at')
                    ->label(AdminTrans::field('check_out_at')),
                Select::make('status')
                    ->label(AdminTrans::field('status'))
                    ->options(AdminTrans::options('attendance_status'))
                    ->default('present')
                    ->required(),
            ]);
    }
}
