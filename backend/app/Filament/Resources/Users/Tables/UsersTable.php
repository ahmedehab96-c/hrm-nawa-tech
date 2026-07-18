<?php

namespace App\Filament\Resources\Users\Tables;

use App\Models\User;
use App\Services\TeamUserService;
use App\Support\AdminTrans;
use Filament\Actions\Action;
use Filament\Actions\BulkActionGroup;
use Filament\Actions\DeleteAction;
use Filament\Actions\DeleteBulkAction;
use Filament\Actions\EditAction;
use Filament\Forms\Components\TextInput;
use Filament\Notifications\Notification;
use Filament\Tables\Columns\IconColumn;
use Filament\Tables\Columns\TextColumn;
use Filament\Tables\Table;
use Illuminate\Validation\Rules\Password;

class UsersTable
{
    public static function configure(Table $table): Table
    {
        return $table
            ->defaultSort('created_at', 'desc')
            ->columns([
                TextColumn::make('name')->label(AdminTrans::field('name'))->searchable()->sortable(),
                TextColumn::make('email')->label(AdminTrans::field('email'))->searchable(),
                TextColumn::make('role')
                    ->label(AdminTrans::field('role'))
                    ->badge()
                    ->formatStateUsing(fn (string $state): string => ucwords(str_replace('_', ' ', $state))),
                IconColumn::make('email_verified_at')
                    ->label(AdminTrans::field('verified'))
                    ->boolean()
                    ->getStateUsing(fn (User $record): bool => $record->hasVerifiedEmail()),
                TextColumn::make('created_at')
                    ->label(AdminTrans::field('created_at'))
                    ->dateTime()
                    ->sortable()
                    ->toggleable(),
            ])
            ->recordActions([
                Action::make('resetPassword')
                    ->label(AdminTrans::action('reset_password'))
                    ->icon('heroicon-o-key')
                    ->form([
                        TextInput::make('password')
                            ->label(AdminTrans::field('password'))
                            ->password()
                            ->revealable()
                            ->required()
                            ->rule(Password::default()),
                        TextInput::make('password_confirmation')
                            ->label(AdminTrans::field('password_confirmation'))
                            ->password()
                            ->revealable()
                            ->required()
                            ->same('password'),
                    ])
                    ->action(function (User $record, array $data): void {
                        app(TeamUserService::class)->resetPassword($record, $data['password']);
                        Notification::make()->title(AdminTrans::notification('password_updated'))->success()->send();
                    }),
                EditAction::make(),
                DeleteAction::make()
                    ->visible(fn (User $record): bool => (int) $record->id !== (int) auth()->id()),
            ])
            ->toolbarActions([
                BulkActionGroup::make([
                    DeleteBulkAction::make(),
                ]),
            ]);
    }
}
