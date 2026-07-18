<?php

namespace App\Filament\Resources\PayrollRecords\Tables;

use App\Support\AdminTrans;
use Filament\Actions\BulkActionGroup;
use Filament\Actions\DeleteBulkAction;
use Filament\Actions\EditAction;
use Filament\Tables\Columns\TextColumn;
use Filament\Tables\Table;

class PayrollRecordsTable
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
                TextColumn::make('month')
                    ->label(AdminTrans::field('month'))
                    ->searchable(),
                TextColumn::make('base_salary')
                    ->label(AdminTrans::field('base_salary'))
                    ->numeric()
                    ->sortable(),
                TextColumn::make('allowances')
                    ->label(AdminTrans::field('allowances'))
                    ->numeric()
                    ->sortable(),
                TextColumn::make('deductions')
                    ->label(AdminTrans::field('deductions'))
                    ->numeric()
                    ->sortable(),
                TextColumn::make('net_salary')
                    ->label(AdminTrans::field('net_salary'))
                    ->numeric()
                    ->sortable(),
                TextColumn::make('status')
                    ->label(AdminTrans::field('status'))
                    ->formatStateUsing(fn (string $state): string => AdminTrans::optionLabel('payroll_status', $state))
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
