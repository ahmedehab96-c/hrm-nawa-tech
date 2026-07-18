<?php

namespace App\Filament\Resources\Roles\Schemas;

use App\Support\AdminTrans;
use Filament\Forms\Components\CheckboxList;
use Filament\Forms\Components\TextInput;
use Filament\Schemas\Schema;

class RoleForm
{
    public static function configure(Schema $schema): Schema
    {
        return $schema
            ->components([
                TextInput::make('name')->label(AdminTrans::field('name'))->disabled(),
                TextInput::make('display_name')
                    ->label(AdminTrans::field('display_name'))
                    ->required()
                    ->maxLength(255),
                CheckboxList::make('permissions')
                    ->label(AdminTrans::field('permissions'))
                    ->relationship(titleAttribute: 'display_name')
                    ->columns(2)
                    ->searchable()
                    ->bulkToggleable()
                    ->columnSpanFull(),
            ]);
    }
}
