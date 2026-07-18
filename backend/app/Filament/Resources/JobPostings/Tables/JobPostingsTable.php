<?php

namespace App\Filament\Resources\JobPostings\Tables;

use App\Models\JobPosting;
use App\Services\RecruitmentMatchService;
use App\Support\AdminTrans;
use Filament\Actions\Action;
use Filament\Actions\BulkActionGroup;
use Filament\Actions\DeleteBulkAction;
use Filament\Actions\EditAction;
use Filament\Forms\Components\Select;
use Filament\Notifications\Notification;
use Filament\Tables\Columns\TextColumn;
use Filament\Tables\Filters\SelectFilter;
use Filament\Tables\Table;

class JobPostingsTable
{
    public static function configure(Table $table): Table
    {
        return $table
            ->defaultSort('created_at', 'desc')
            ->columns([
                TextColumn::make('title')
                    ->label(AdminTrans::field('title'))
                    ->searchable()
                    ->sortable(),
                TextColumn::make('department')
                    ->label(AdminTrans::field('department'))
                    ->searchable()
                    ->toggleable(),
                TextColumn::make('location')
                    ->label(AdminTrans::field('location'))
                    ->toggleable(),
                TextColumn::make('status')
                    ->label(AdminTrans::field('status'))
                    ->formatStateUsing(fn (string $state): string => AdminTrans::optionLabel('job_status', $state))
                    ->badge()
                    ->color(fn (string $state): string => match ($state) {
                        'open' => 'success',
                        'closed' => 'gray',
                        default => 'warning',
                    }),
                TextColumn::make('candidates_count')
                    ->counts('candidates')
                    ->label(AdminTrans::page('candidates')),
                TextColumn::make('created_at')
                    ->label(AdminTrans::field('created_at'))
                    ->dateTime()
                    ->sortable()
                    ->toggleable(isToggledHiddenByDefault: true),
            ])
            ->filters([
                SelectFilter::make('status')
                    ->label(AdminTrans::field('status'))
                    ->options(AdminTrans::options('job_status')),
            ])
            ->recordActions([
                Action::make('aiMatch')
                    ->label(AdminTrans::action('ai_match_candidates'))
                    ->icon('heroicon-o-sparkles')
                    ->color('info')
                    ->visible(fn (JobPosting $record): bool => $record->candidates()->exists())
                    ->form([
                        Select::make('language_code')
                            ->options(AdminTrans::options('language'))
                            ->default('en'),
                    ])
                    ->requiresConfirmation()
                    ->action(function (JobPosting $record, array $data): void {
                        $user = auth()->user();
                        abort_unless($user !== null, 401);

                        $count = app(RecruitmentMatchService::class)->matchCandidates(
                            $record,
                            $user,
                            (string) ($data['language_code'] ?? 'en'),
                        );

                        Notification::make()
                            ->title(AdminTrans::notification('candidates_scored', ['count' => (string) $count]))
                            ->success()
                            ->send();
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
