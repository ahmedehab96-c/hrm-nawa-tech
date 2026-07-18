<?php

namespace App\Filament\Resources\Users\Schemas;

use App\Services\TeamUserService;
use App\Support\AdminTrans;
use Filament\Forms\Components\Select;
use Filament\Forms\Components\TextInput;
use Filament\Schemas\Schema;
use Illuminate\Validation\Rules\Password;

class UserForm
{
    public static function configure(Schema $schema): Schema
    {
        $roles = collect(app(TeamUserService::class)->assignableRoles(auth()->user()))
            ->mapWithKeys(fn (string $role) => [$role => ucwords(str_replace('_', ' ', $role))])
            ->all();

        return $schema
            ->components([
                TextInput::make('name')->label(AdminTrans::field('name'))->required()->maxLength(255),
                TextInput::make('email')->label(AdminTrans::field('email'))->email()->required()->maxLength(255),
                Select::make('role')
                    ->label(AdminTrans::field('role'))
                    ->options($roles)
                    ->default('hr')
                    ->required(),
                TextInput::make('password')
                    ->password()
                    ->revealable()
                    ->rule(Password::default())
                    ->required(fn (string $operation): bool => $operation === 'create')
                    ->dehydrated(fn (?string $state): bool => filled($state))
                    ->label(fn (string $operation): string => $operation === 'edit'
                        ? AdminTrans::field('new_password_optional')
                        : AdminTrans::field('password')),
            ]);
    }
}
