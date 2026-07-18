<?php

namespace App\Filament\Resources\Employees\Tables;

use App\Models\Employee;
use App\Services\EmployeeAppAccessService;
use App\Support\AdminTrans;
use Filament\Actions\Action;
use Filament\Actions\BulkActionGroup;
use Filament\Actions\DeleteBulkAction;
use Filament\Actions\EditAction;
use Filament\Forms\Components\TextInput;
use Filament\Notifications\Notification;
use Filament\Tables\Columns\IconColumn;
use Filament\Tables\Columns\TextColumn;
use Filament\Tables\Table;

class EmployeesTable
{
    public static function configure(Table $table): Table
    {
        return $table
            ->columns([
                TextColumn::make('name')
                    ->label(AdminTrans::field('name'))
                    ->searchable()
                    ->sortable(),
                TextColumn::make('email')
                    ->label(AdminTrans::field('email'))
                    ->searchable(),
                TextColumn::make('department')
                    ->label(AdminTrans::field('department'))
                    ->searchable()
                    ->toggleable(),
                TextColumn::make('position')
                    ->label(AdminTrans::field('position'))
                    ->searchable()
                    ->toggleable(),
                IconColumn::make('app_login')
                    ->label(AdminTrans::field('mobile_app'))
                    ->boolean()
                    ->getStateUsing(fn (Employee $record): bool => app(EmployeeAppAccessService::class)->isEnabled($record))
                    ->trueIcon('heroicon-o-device-phone-mobile')
                    ->falseIcon('heroicon-o-x-circle'),
                IconColumn::make('is_active')
                    ->boolean()
                    ->label(AdminTrans::field('is_active')),
                TextColumn::make('hire_date')
                    ->label(AdminTrans::field('hire_date'))
                    ->date()
                    ->sortable()
                    ->toggleable(),
                TextColumn::make('base_salary')
                    ->label(AdminTrans::field('base_salary'))
                    ->numeric()
                    ->sortable()
                    ->toggleable(isToggledHiddenByDefault: true),
            ])
            ->filters([
                //
            ])
            ->recordActions([
                Action::make('app_access')
                    ->label(fn (Employee $record): string => app(EmployeeAppAccessService::class)->isEnabled($record)
                        ? AdminTrans::action('disable_app_login')
                        : AdminTrans::action('enable_app_login'))
                    ->icon('heroicon-o-device-phone-mobile')
                    ->color(fn (Employee $record): string => app(EmployeeAppAccessService::class)->isEnabled($record)
                        ? 'danger'
                        : 'success')
                    ->visible(fn (Employee $record): bool => filled($record->email))
                    ->form(fn (Employee $record): array => app(EmployeeAppAccessService::class)->isEnabled($record)
                        ? []
                        : [
                            TextInput::make('password')
                                ->label(AdminTrans::field('password'))
                                ->password()
                                ->revealable()
                                ->required()
                                ->minLength(8),
                            TextInput::make('password_confirmation')
                                ->label(AdminTrans::field('password_confirmation'))
                                ->password()
                                ->revealable()
                                ->required()
                                ->same('password'),
                        ])
                    ->requiresConfirmation()
                    ->modalHeading(fn (Employee $record): string => app(EmployeeAppAccessService::class)->isEnabled($record)
                        ? AdminTrans::action('disable_mobile_login')
                        : AdminTrans::action('enable_mobile_login'))
                    ->modalDescription(fn (Employee $record): string => app(EmployeeAppAccessService::class)->isEnabled($record)
                        ? AdminTrans::helpers('disable_mobile_login')
                        : AdminTrans::helpers('enable_mobile_login'))
                    ->action(function (Employee $record, array $data): void {
                        $service = app(EmployeeAppAccessService::class);
                        if ($service->isEnabled($record)) {
                            $service->disable($record);
                            Notification::make()->title(AdminTrans::notification('app_login_disabled'))->success()->send();

                            return;
                        }

                        $service->enable($record, $data['password']);
                        Notification::make()->title(AdminTrans::notification('app_login_enabled'))->success()->send();
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
