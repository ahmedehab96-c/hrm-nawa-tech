<?php

namespace App\Filament\Resources\AttendanceRecords\Tables;

use App\Support\AdminTrans;
use Filament\Actions\BulkActionGroup;
use Filament\Actions\DeleteBulkAction;
use Filament\Actions\EditAction;
use Filament\Tables\Columns\TextColumn;
use Filament\Tables\Table;

class AttendanceRecordsTable
{
    public static function configure(Table $table): Table
    {
        return $table
            ->columns([
                TextColumn::make('company_id')
                    ->label(AdminTrans::field('company'))
                    ->numeric()
                    ->sortable(),
                TextColumn::make('employee.name')
                    ->label(AdminTrans::field('employee'))
                    ->searchable(),
                TextColumn::make('work_date')
                    ->label(AdminTrans::field('work_date'))
                    ->date()
                    ->sortable(),
                TextColumn::make('check_in_at')
                    ->label(AdminTrans::field('check_in_at'))
                    ->dateTime()
                    ->sortable(),
                TextColumn::make('check_out_at')
                    ->label(AdminTrans::field('check_out_at'))
                    ->dateTime()
                    ->sortable(),
                TextColumn::make('status')
                    ->label(AdminTrans::field('status'))
                    ->formatStateUsing(fn (string $state): string => AdminTrans::optionLabel('attendance_status', $state))
                    ->searchable(),
                TextColumn::make('created_at')
                    ->label(AdminTrans::field('created_at'))
                    ->dateTime()
                    ->sortable()
                    ->toggleable(isToggledHiddenByDefault: true),
                TextColumn::make('updated_at')
                    ->label(AdminTrans::field('updated_at'))
                    ->dateTime()
                    ->sortable()
                    ->toggleable(isToggledHiddenByDefault: true),
            ])
            ->filters([
                //
            ])
            ->recordActions([
                EditAction::make(),
            ])
            ->toolbarActions([
                BulkActionGroup::make([
                    DeleteBulkAction::make(),
                ]),
            ]);
    }
}
