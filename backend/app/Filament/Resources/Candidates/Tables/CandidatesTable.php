<?php

namespace App\Filament\Resources\Candidates\Tables;

use App\Models\Candidate;
use App\Support\AdminTrans;
use Filament\Actions\Action;
use Filament\Actions\BulkActionGroup;
use Filament\Actions\DeleteBulkAction;
use Filament\Actions\EditAction;
use Filament\Notifications\Notification;
use Filament\Tables\Columns\TextColumn;
use Filament\Tables\Filters\SelectFilter;
use Filament\Tables\Table;

class CandidatesTable
{
    public static function configure(Table $table): Table
    {
        return $table
            ->defaultSort('created_at', 'desc')
            ->columns([
                TextColumn::make('name')
                    ->label(AdminTrans::field('name'))
                    ->searchable()
                    ->sortable(),
                TextColumn::make('jobPosting.title')
                    ->label(AdminTrans::field('job'))
                    ->searchable()
                    ->toggleable(),
                TextColumn::make('email')
                    ->label(AdminTrans::field('email'))
                    ->searchable()
                    ->toggleable(),
                TextColumn::make('phone')
                    ->label(AdminTrans::field('phone'))
                    ->toggleable(isToggledHiddenByDefault: true),
                TextColumn::make('stage')
                    ->label(AdminTrans::field('stage'))
                    ->formatStateUsing(fn (string $state): string => AdminTrans::optionLabel('candidate_stage', $state))
                    ->badge()
                    ->color(fn (string $state): string => match ($state) {
                        'hired' => 'success',
                        'offer' => 'info',
                        'interview' => 'warning',
                        'rejected' => 'danger',
                        default => 'gray',
                    })
                    ->sortable(),
                TextColumn::make('ai_fit_score')
                    ->label(AdminTrans::field('ai_fit'))
                    ->numeric()
                    ->sortable()
                    ->toggleable(),
                TextColumn::make('years_experience')
                    ->label(AdminTrans::field('experience_years'))
                    ->numeric()
                    ->toggleable(isToggledHiddenByDefault: true),
                TextColumn::make('created_at')
                    ->label(AdminTrans::field('created_at'))
                    ->dateTime()
                    ->sortable()
                    ->toggleable(isToggledHiddenByDefault: true),
            ])
            ->filters([
                SelectFilter::make('stage')
                    ->label(AdminTrans::field('stage'))
                    ->options(AdminTrans::options('candidate_stage')),
            ])
            ->recordActions([
                Action::make('toInterview')
                    ->label(AdminTrans::action('interview'))
                    ->icon('heroicon-o-chat-bubble-left-right')
                    ->visible(fn (Candidate $record): bool => ! in_array($record->stage, ['interview', 'hired', 'rejected'], true))
                    ->action(function (Candidate $record): void {
                        $record->update(['stage' => 'interview']);
                        Notification::make()->title(AdminTrans::notification('moved_interview'))->success()->send();
                    }),
                Action::make('hire')
                    ->label(AdminTrans::action('hire'))
                    ->icon('heroicon-o-check-badge')
                    ->color('success')
                    ->visible(fn (Candidate $record): bool => $record->stage !== 'hired')
                    ->requiresConfirmation()
                    ->action(function (Candidate $record): void {
                        $record->update(['stage' => 'hired']);
                        Notification::make()->title(AdminTrans::notification('candidate_hired'))->success()->send();
                    }),
                Action::make('reject')
                    ->label(AdminTrans::action('reject'))
                    ->icon('heroicon-o-x-circle')
                    ->color('danger')
                    ->visible(fn (Candidate $record): bool => $record->stage !== 'rejected')
                    ->requiresConfirmation()
                    ->action(function (Candidate $record): void {
                        $record->update(['stage' => 'rejected']);
                        Notification::make()->title(AdminTrans::notification('candidate_rejected'))->danger()->send();
                    }),
                EditAction::make(),
            ])
            ->toolbarActions([
                BulkActionGroup::make([
                    DeleteBulkAction::make(),
                ]),
            ]);
    }
}
