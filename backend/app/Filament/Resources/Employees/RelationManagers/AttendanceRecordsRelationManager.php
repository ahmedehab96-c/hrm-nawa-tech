<?php

namespace App\Filament\Resources\Employees\RelationManagers;

use App\Support\AdminTrans;
use Filament\Actions\BulkActionGroup;
use Filament\Actions\CreateAction;
use Filament\Actions\DeleteAction;
use Filament\Actions\DeleteBulkAction;
use Filament\Actions\EditAction;
use Filament\Forms\Components\DatePicker;
use Filament\Forms\Components\DateTimePicker;
use Filament\Forms\Components\Select;
use Filament\Resources\RelationManagers\RelationManager;
use Filament\Schemas\Schema;
use Filament\Tables\Columns\TextColumn;
use Filament\Tables\Table;

class AttendanceRecordsRelationManager extends RelationManager
{
    protected static string $relationship = 'attendanceRecords';

    public function form(Schema $schema): Schema
    {
        return $schema
            ->components([
                DatePicker::make('work_date')->label(AdminTrans::field('work_date'))->required(),
                DateTimePicker::make('check_in_at')->label(AdminTrans::field('check_in_at')),
                DateTimePicker::make('check_out_at')->label(AdminTrans::field('check_out_at')),
                Select::make('status')
                    ->label(AdminTrans::field('status'))
                    ->options(AdminTrans::options('attendance_status'))
                    ->default('present')
                    ->required(),
            ]);
    }

    public function table(Table $table): Table
    {
        return $table
            ->recordTitleAttribute('work_date')
            ->defaultSort('work_date', 'desc')
            ->columns([
                TextColumn::make('work_date')->label(AdminTrans::field('work_date'))->date()->sortable(),
                TextColumn::make('check_in_at')->label(AdminTrans::field('check_in_at'))->dateTime()->toggleable(),
                TextColumn::make('check_out_at')->label(AdminTrans::field('check_out_at'))->dateTime()->toggleable(),
                TextColumn::make('status')
                    ->label(AdminTrans::field('status'))
                    ->formatStateUsing(fn (string $state): string => AdminTrans::optionLabel('attendance_status', $state))
                    ->badge(),
            ])
            ->headerActions([
                CreateAction::make()
                    ->mutateFormDataUsing(function (array $data): array {
                        $owner = $this->getOwnerRecord();
                        $data['company_id'] = $owner->company_id;
                        $data['employee_id'] = $owner->id;

                        return $data;
                    }),
            ])
            ->recordActions([
                EditAction::make(),
                DeleteAction::make(),
            ])
            ->toolbarActions([
                BulkActionGroup::make([
                    DeleteBulkAction::make(),
                ]),
            ]);
    }
}
