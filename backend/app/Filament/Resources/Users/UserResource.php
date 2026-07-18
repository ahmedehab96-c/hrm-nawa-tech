<?php

namespace App\Filament\Resources\Users;

use App\Filament\Concerns\ScopesToCompany;
use App\Filament\Resources\Users\Pages\CreateUser;
use App\Filament\Resources\Users\Pages\EditUser;
use App\Filament\Resources\Users\Pages\ListUsers;
use App\Filament\Resources\Users\Schemas\UserForm;
use App\Filament\Resources\Users\Tables\UsersTable;
use App\Models\User;
use App\Services\TeamUserService;
use App\Support\AdminTrans;
use BackedEnum;
use Filament\Resources\Resource;
use Filament\Schemas\Schema;
use Filament\Support\Icons\Heroicon;
use Filament\Tables\Table;
use Illuminate\Database\Eloquent\Builder;
use UnitEnum;

class UserResource extends Resource
{
    use ScopesToCompany {
        getEloquentQuery as protected scopedToCompanyQuery;
    }

    protected static ?string $model = User::class;

    protected static string|BackedEnum|null $navigationIcon = Heroicon::OutlinedUserGroup;

    protected static string|UnitEnum|null $navigationGroup = 'Company';

    protected static ?string $navigationLabel = null;

    protected static ?string $recordTitleAttribute = 'name';

    protected static ?int $navigationSort = 92;

    public static function getNavigationLabel(): string
    {
        return __('admin.nav.team_users');
    }

    public static function getModelLabel(): string
    {
        return AdminTrans::page('team_user');
    }

    public static function getPluralModelLabel(): string
    {
        return AdminTrans::page('team_users');
    }

    public static function shouldRegisterNavigation(): bool
    {
        return false;
    }

    public static function canAccess(): bool
    {
        return auth()->user()?->hasRole('company_admin') ?? false;
    }

    public static function getEloquentQuery(): Builder
    {
        // Compose the company scope from ScopesToCompany instead of bypassing it
        // via parent::getEloquentQuery(), so team users stay tenant-isolated.
        return static::scopedToCompanyQuery()
            ->whereIn('role', TeamUserService::ADMIN_ROLES);
    }

    public static function form(Schema $schema): Schema
    {
        return UserForm::configure($schema);
    }

    public static function table(Table $table): Table
    {
        return UsersTable::configure($table);
    }

    public static function getRelations(): array
    {
        return [];
    }

    public static function getPages(): array
    {
        return [
            'index' => ListUsers::route('/'),
            'create' => CreateUser::route('/create'),
            'edit' => EditUser::route('/{record}/edit'),
        ];
    }
}
