<?php

namespace App\Filament\Pages;

use App\Models\Role;
use App\Services\TeamUserService;
use App\Support\AdminTrans;
use BackedEnum;
use Filament\Pages\Page;
use Filament\Support\Icons\Heroicon;
use UnitEnum;

class RolesOverview extends Page
{
    protected static string|BackedEnum|null $navigationIcon = Heroicon::OutlinedShieldCheck;

    protected static string|UnitEnum|null $navigationGroup = 'Company';

    protected static ?string $navigationLabel = null;

    protected static ?int $navigationSort = 93;

    public static function getNavigationLabel(): string
    {
        return __('admin.nav.roles_access');
    }

    public function getTitle(): string
    {
        return AdminTrans::page('roles_access');
    }

    public static function shouldRegisterNavigation(): bool
    {
        return false;
    }

    protected string $view = 'filament.pages.roles-overview';

    public static function canAccess(): bool
    {
        return auth()->user()?->hasRole('company_admin') ?? false;
    }

    /**
     * @return list<array{name: string, display_name: string, permissions: list<string>}>
     */
    public function getRoles(): array
    {
        return Role::query()
            ->whereIn('name', TeamUserService::ADMIN_ROLES)
            ->with('permissions:id,name,display_name')
            ->orderBy('name')
            ->get()
            ->map(fn (Role $role) => [
                'name' => $role->name,
                'display_name' => $role->display_name ?? $role->name,
                'permissions' => $role->permissions
                    ->pluck('display_name')
                    ->filter()
                    ->values()
                    ->all(),
            ])
            ->all();
    }
}
