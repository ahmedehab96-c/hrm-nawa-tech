<?php

namespace App\Filament\Resources\Companies\Tables;

use App\Models\Company;
use App\Services\BillingService;
use App\Services\PlatformCompanyService;
use App\Support\AdminTrans;
use Filament\Actions\Action;
use Filament\Actions\ActionGroup;
use Filament\Actions\BulkActionGroup;
use Filament\Actions\DeleteBulkAction;
use Filament\Actions\EditAction;
use Filament\Forms\Components\Select;
use Filament\Notifications\Notification;
use Filament\Tables\Columns\TextColumn;
use Filament\Tables\Filters\SelectFilter;
use Filament\Tables\Table;

class CompaniesTable
{
    public static function configure(Table $table): Table
    {
        return $table
            ->defaultSort('created_at', 'desc')
            ->columns([
                TextColumn::make('name')->label(AdminTrans::field('name'))->searchable()->sortable(),
                TextColumn::make('email')->label(AdminTrans::field('email'))->searchable()->toggleable(),
                TextColumn::make('status')
                    ->label(AdminTrans::field('status'))
                    ->formatStateUsing(fn (string $state): string => AdminTrans::optionLabel('company_status', $state))
                    ->badge(),
                TextColumn::make('plan')
                    ->label(AdminTrans::field('plan'))
                    ->formatStateUsing(fn (string $state): string => AdminTrans::optionLabel('plan', $state) !== $state
                        ? AdminTrans::optionLabel('plan', $state)
                        : AdminTrans::optionLabel('company_status', $state))
                    ->badge()
                    ->sortable(),
                TextColumn::make('trial_ends_at')
                    ->label(AdminTrans::field('trial_ends'))
                    ->dateTime()
                    ->sortable()
                    ->placeholder('—'),
                TextColumn::make('employees_count')
                    ->label(AdminTrans::field('employees'))
                    ->counts('employees')
                    ->sortable(),
                TextColumn::make('created_at')
                    ->label(AdminTrans::field('created_at'))
                    ->dateTime()
                    ->sortable()
                    ->toggleable(isToggledHiddenByDefault: true),
            ])
            ->filters([
                SelectFilter::make('status')
                    ->label(AdminTrans::field('status'))
                    ->options(AdminTrans::options('company_status')),
                SelectFilter::make('plan')
                    ->label(AdminTrans::field('plan'))
                    ->options(array_merge(
                        ['trial' => AdminTrans::optionLabel('company_status', 'trial')],
                        AdminTrans::options('plan'),
                    )),
            ])
            ->recordActions([
                EditAction::make(),
                ActionGroup::make([
                    Action::make('suspend')
                        ->icon('heroicon-o-pause')
                        ->color('warning')
                        ->visible(fn (Company $record): bool => $record->status !== 'suspended')
                        ->requiresConfirmation()
                        ->action(function (Company $record): void {
                            app(PlatformCompanyService::class)->suspend($record);
                            Notification::make()->title(AdminTrans::notification('company_suspended'))->success()->send();
                        }),
                    Action::make('activate')
                        ->icon('heroicon-o-play')
                        ->color('success')
                        ->visible(fn (Company $record): bool => $record->status !== 'active')
                        ->requiresConfirmation()
                        ->action(function (Company $record): void {
                            app(PlatformCompanyService::class)->activate($record);
                            Notification::make()->title(AdminTrans::notification('company_activated'))->success()->send();
                        }),
                    Action::make('extend_trial')
                        ->icon('heroicon-o-calendar-days')
                        ->requiresConfirmation()
                        ->modalDescription(AdminTrans::helpers('extend_trial_modal'))
                        ->action(function (Company $record): void {
                            app(PlatformCompanyService::class)->extendTrial($record, 14);
                            Notification::make()->title(AdminTrans::notification('trial_extended'))->success()->send();
                        }),
                    Action::make('set_plan')
                        ->icon('heroicon-o-credit-card')
                        ->form([
                            Select::make('plan')
                                ->label(AdminTrans::field('plan'))
                                ->options(array_merge(
                                    ['trial' => AdminTrans::optionLabel('company_status', 'trial')],
                                    collect(app(BillingService::class)->catalog())
                                        ->mapWithKeys(fn (array $meta, string $key) => [$key => $meta['label']])
                                        ->all(),
                                ))
                                ->required(),
                        ])
                        ->action(function (Company $record, array $data): void {
                            app(PlatformCompanyService::class)->setPlan($record, $data['plan']);
                            Notification::make()->title(AdminTrans::notification('plan_updated'))->success()->send();
                        }),
                ])->label(AdminTrans::navGroup('platform')),
            ])
            ->toolbarActions([
                BulkActionGroup::make([
                    DeleteBulkAction::make(),
                ]),
            ]);
    }
}
