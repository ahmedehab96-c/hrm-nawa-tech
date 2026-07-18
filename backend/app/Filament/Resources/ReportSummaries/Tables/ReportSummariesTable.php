<?php

namespace App\Filament\Resources\ReportSummaries\Tables;

use App\Support\AdminTrans;
use Filament\Actions\ViewAction;
use Filament\Tables\Columns\TextColumn;
use Filament\Tables\Table;

class ReportSummariesTable
{
    public static function configure(Table $table): Table
    {
        return $table
            ->defaultSort('created_at', 'desc')
            ->columns([
                TextColumn::make('report_type')
                    ->label(AdminTrans::field('report_type'))
                    ->formatStateUsing(fn (string $state): string => AdminTrans::optionLabel('report_type', $state))
                    ->badge()
                    ->searchable(),
                TextColumn::make('period_start')
                    ->label(AdminTrans::field('period_start'))
                    ->date()
                    ->sortable(),
                TextColumn::make('period_end')
                    ->label(AdminTrans::field('period_end'))
                    ->date()
                    ->sortable(),
                TextColumn::make('narrative')
                    ->label(AdminTrans::field('narrative'))
                    ->limit(60)
                    ->wrap()
                    ->toggleable(),
                TextColumn::make('provider')
                    ->label(AdminTrans::field('provider'))
                    ->toggleable(isToggledHiddenByDefault: true),
                TextColumn::make('created_at')
                    ->label(AdminTrans::field('created_at'))
                    ->dateTime()
                    ->sortable(),
            ])
            ->filters([])
            ->recordActions([
                ViewAction::make(),
            ])
            ->toolbarActions([]);
    }
}
