<?php

namespace App\Filament\Resources\Roles\Tables;

use App\Support\AdminTrans;
use Filament\Actions\EditAction;
use Filament\Tables\Columns\TextColumn;
use Filament\Tables\Table;

class RolesTable
{
    public static function configure(Table $table): Table
    {
        return $table
            ->defaultSort('name')
            ->columns([
                TextColumn::make('display_name')
                    ->label(AdminTrans::field('role'))
                    ->searchable()
                    ->sortable(),
                TextColumn::make('name')->label(AdminTrans::field('name'))->badge()->toggleable(),
                TextColumn::make('permissions_count')
                    ->counts('permissions')
                    ->label(AdminTrans::field('permissions'))
                    ->sortable(),
                TextColumn::make('users_count')
                    ->counts('users')
                    ->label(AdminTrans::field('users'))
                    ->sortable(),
            ])
            ->recordActions([
                EditAction::make(),
            ]);
    }
}
