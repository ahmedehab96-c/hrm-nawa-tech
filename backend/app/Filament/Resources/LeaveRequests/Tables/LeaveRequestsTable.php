<?php

namespace App\Filament\Resources\LeaveRequests\Tables;

use App\Models\LeaveRequest;
use App\Services\LeaveDecisionService;
use App\Services\LeaveRecommendationService;
use App\Support\AdminTrans;
use Filament\Actions\Action;
use Filament\Actions\BulkAction;
use Filament\Actions\BulkActionGroup;
use Filament\Actions\DeleteBulkAction;
use Filament\Actions\EditAction;
use Filament\Notifications\Notification;
use Filament\Tables\Columns\TextColumn;
use Filament\Tables\Filters\SelectFilter;
use Filament\Tables\Table;
use Illuminate\Database\Eloquent\Collection;

class LeaveRequestsTable
{
    public static function configure(Table $table): Table
    {
        return $table
            ->defaultSort('created_at', 'desc')
            ->columns([
                TextColumn::make('employee.name')
                    ->label(AdminTrans::field('employee'))
                    ->searchable()
                    ->sortable(),
                TextColumn::make('type')
                    ->label(AdminTrans::field('type'))
                    ->badge()
                    ->formatStateUsing(fn (string $state): string => AdminTrans::optionLabel('leave_type', $state))
                    ->searchable(),
                TextColumn::make('from_date')
                    ->label(AdminTrans::field('from_date'))
                    ->date()
                    ->sortable(),
                TextColumn::make('to_date')
                    ->label(AdminTrans::field('to_date'))
                    ->date()
                    ->sortable(),
                TextColumn::make('days')
                    ->label(AdminTrans::field('days'))
                    ->numeric()
                    ->sortable(),
                TextColumn::make('status')
                    ->label(AdminTrans::field('status'))
                    ->badge()
                    ->formatStateUsing(fn (string $state): string => AdminTrans::optionLabel('leave_status', $state))
                    ->color(fn (string $state): string => match ($state) {
                        'approved' => 'success',
                        'rejected' => 'danger',
                        'pending' => 'warning',
                        default => 'gray',
                    })
                    ->sortable(),
                TextColumn::make('notes')
                    ->label(AdminTrans::field('notes'))
                    ->limit(30)
                    ->toggleable(isToggledHiddenByDefault: true),
                TextColumn::make('created_at')
                    ->label(AdminTrans::field('created_at'))
                    ->dateTime()
                    ->sortable()
                    ->toggleable(isToggledHiddenByDefault: true),
            ])
            ->filters([
                SelectFilter::make('status')
                    ->label(AdminTrans::field('status'))
                    ->options(AdminTrans::options('leave_status'))
                    ->default('pending'),
            ])
            ->recordActions([
                Action::make('aiRecommend')
                    ->label(AdminTrans::action('ai_recommend'))
                    ->icon('heroicon-o-sparkles')
                    ->color('info')
                    ->visible(fn (LeaveRequest $record): bool => $record->status === 'pending')
                    ->action(function (LeaveRequest $record): void {
                        $user = auth()->user();
                        abort_unless($user !== null, 401);

                        $result = app(LeaveRecommendationService::class)->recommend($record, (int) $user->id);
                        $rec = $result['recommendation'];
                        $actionLabel = AdminTrans::optionLabel('leave_status', $rec['action'] === 'approve' ? 'approved' : 'rejected');

                        Notification::make()
                            ->title(AdminTrans::notification('recommendation', ['action' => $actionLabel]))
                            ->body(AdminTrans::notification('recommendation_body', [
                                'reason' => $rec['reason'],
                                'confidence' => (string) round($rec['confidence'] * 100),
                            ]))
                            ->info()
                            ->duration(12000)
                            ->send();
                    }),
                Action::make('approve')
                    ->label(AdminTrans::action('approve'))
                    ->icon('heroicon-o-check-circle')
                    ->color('success')
                    ->visible(fn (LeaveRequest $record): bool => $record->status === 'pending')
                    ->requiresConfirmation()
                    ->action(function (LeaveRequest $record): void {
                        app(LeaveDecisionService::class)->approve($record);
                        Notification::make()
                            ->title(AdminTrans::notification('leave_approved'))
                            ->success()
                            ->send();
                    }),
                Action::make('reject')
                    ->label(AdminTrans::action('reject'))
                    ->icon('heroicon-o-x-circle')
                    ->color('danger')
                    ->visible(fn (LeaveRequest $record): bool => $record->status === 'pending')
                    ->requiresConfirmation()
                    ->action(function (LeaveRequest $record): void {
                        app(LeaveDecisionService::class)->reject($record);
                        Notification::make()
                            ->title(AdminTrans::notification('leave_rejected'))
                            ->danger()
                            ->send();
                    }),
                EditAction::make(),
            ])
            ->toolbarActions([
                BulkActionGroup::make([
                    BulkAction::make('approveSelected')
                        ->label(AdminTrans::action('approve_selected'))
                        ->icon('heroicon-o-check')
                        ->color('success')
                        ->requiresConfirmation()
                        ->action(function (Collection $records): void {
                            $service = app(LeaveDecisionService::class);
                            $count = 0;
                            foreach ($records as $record) {
                                if ($record instanceof LeaveRequest && $record->status === 'pending') {
                                    $service->approve($record);
                                    $count++;
                                }
                            }
                            Notification::make()
                                ->title(AdminTrans::notification('approved_count', ['count' => (string) $count]))
                                ->success()
                                ->send();
                        }),
                    BulkAction::make('rejectSelected')
                        ->label(AdminTrans::action('reject_selected'))
                        ->icon('heroicon-o-x-mark')
                        ->color('danger')
                        ->requiresConfirmation()
                        ->action(function (Collection $records): void {
                            $service = app(LeaveDecisionService::class);
                            $count = 0;
                            foreach ($records as $record) {
                                if ($record instanceof LeaveRequest && $record->status === 'pending') {
                                    $service->reject($record);
                                    $count++;
                                }
                            }
                            Notification::make()
                                ->title(AdminTrans::notification('rejected_count', ['count' => (string) $count]))
                                ->danger()
                                ->send();
                        }),
                    DeleteBulkAction::make(),
                ]),
            ]);
    }
}
