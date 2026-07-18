<?php

namespace App\Filament\Resources\AiUsageLogs\Tables;

use App\Support\AdminTrans;
use Filament\Tables\Columns\TextColumn;
use Filament\Tables\Filters\SelectFilter;
use Filament\Tables\Table;

class AiUsageLogsTable
{
    public static function configure(Table $table): Table
    {
        return $table
            ->defaultSort('created_at', 'desc')
            ->columns([
                TextColumn::make('created_at')
                    ->label(AdminTrans::field('when'))
                    ->dateTime()
                    ->sortable(),
                TextColumn::make('endpoint')
                    ->label(AdminTrans::field('endpoint'))
                    ->searchable()
                    ->limit(40),
                TextColumn::make('provider')
                    ->label(AdminTrans::field('provider'))
                    ->badge()
                    ->toggleable(),
                TextColumn::make('model')
                    ->label(AdminTrans::field('ai_model'))
                    ->toggleable(),
                TextColumn::make('status')
                    ->label(AdminTrans::field('status'))
                    ->formatStateUsing(fn (string $state): string => AdminTrans::optionLabel('ai_log_status', $state))
                    ->badge()
                    ->color(fn (string $state): string => match ($state) {
                        'ok', 'success' => 'success',
                        'error' => 'danger',
                        default => 'gray',
                    }),
                TextColumn::make('total_tokens')
                    ->label(AdminTrans::field('tokens'))
                    ->numeric()
                    ->sortable(),
                TextColumn::make('latency_ms')
                    ->label(AdminTrans::field('latency'))
                    ->numeric()
                    ->suffix(' ms')
                    ->sortable(),
                TextColumn::make('user.name')
                    ->label(AdminTrans::field('user'))
                    ->toggleable(),
                TextColumn::make('company.name')
                    ->label(AdminTrans::field('company'))
                    ->visible(fn (): bool => auth()->user()?->hasRole('super_admin') ?? false)
                    ->toggleable(),
                TextColumn::make('error_message')
                    ->limit(40)
                    ->toggleable(isToggledHiddenByDefault: true),
            ])
            ->filters([
                SelectFilter::make('status')
                    ->label(AdminTrans::field('status'))
                    ->options(AdminTrans::options('ai_log_status')),
                SelectFilter::make('provider')
                    ->label(AdminTrans::field('provider'))
                    ->options(AdminTrans::options('ai_provider')),
            ])
            ->recordActions([])
            ->toolbarActions([]);
    }
}
