<?php

namespace App\Filament\Resources\PerformanceReviews\Tables;

use App\Models\Company;
use App\Models\PerformanceReview;
use App\Services\PerformanceReviewAnalysisService;
use App\Support\AdminTrans;
use Filament\Actions\Action;
use Filament\Actions\BulkActionGroup;
use Filament\Actions\DeleteBulkAction;
use Filament\Actions\EditAction;
use Filament\Notifications\Notification;
use Filament\Tables\Columns\TextColumn;
use Filament\Tables\Filters\SelectFilter;
use Filament\Tables\Table;

class PerformanceReviewsTable
{
    public static function configure(Table $table): Table
    {
        return $table
            ->defaultSort('reviewed_at', 'desc')
            ->columns([
                TextColumn::make('employee.name')
                    ->label(AdminTrans::field('employee'))
                    ->searchable()
                    ->sortable(),
                TextColumn::make('period_label')
                    ->label(AdminTrans::field('period'))
                    ->searchable()
                    ->sortable(),
                TextColumn::make('rating')
                    ->label(AdminTrans::field('rating'))
                    ->numeric()
                    ->sortable()
                    ->badge()
                    ->color(fn (?int $state): string => match (true) {
                        $state === null => 'gray',
                        $state >= 4 => 'success',
                        $state === 3 => 'warning',
                        default => 'danger',
                    }),
                TextColumn::make('ai_summary')
                    ->label(AdminTrans::field('ai_summary'))
                    ->limit(40)
                    ->toggleable(),
                TextColumn::make('reviewed_at')
                    ->label(AdminTrans::field('reviewed_at'))
                    ->dateTime()
                    ->sortable(),
            ])
            ->filters([
                SelectFilter::make('rating')
                    ->label(AdminTrans::field('rating'))
                    ->options(AdminTrans::options('performance_rating')),
            ])
            ->recordActions([
                Action::make('analyzeAi')
                    ->label(AdminTrans::action('ai_analyze'))
                    ->icon('heroicon-o-sparkles')
                    ->requiresConfirmation()
                    ->action(function (PerformanceReview $record): void {
                        $company = Company::query()->find($record->company_id);
                        if ($company === null) {
                            Notification::make()->title(AdminTrans::notification('company_not_found'))->danger()->send();

                            return;
                        }
                        app(PerformanceReviewAnalysisService::class)->analyze($record, $company);
                        Notification::make()->title(AdminTrans::notification('ai_summary_updated'))->success()->send();
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
