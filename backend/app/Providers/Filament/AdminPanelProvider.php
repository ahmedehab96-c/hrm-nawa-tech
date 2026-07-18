<?php

namespace App\Providers\Filament;

use App\Filament\Auth\Login;
use App\Filament\Auth\Register;
use App\Filament\Pages\AdminDashboard;
use App\Http\Middleware\SetAdminLocale;
use App\Support\AdminTrans;
use Filament\Enums\ThemeMode;
use Filament\Http\Middleware\Authenticate;
use Filament\Http\Middleware\AuthenticateSession;
use Filament\Http\Middleware\DisableBladeIconComponents;
use Filament\Http\Middleware\DispatchServingFilamentEvent;
use Filament\Navigation\NavigationGroup;
use Filament\Panel;
use Filament\PanelProvider;
use Filament\Support\Colors\Color;
use Filament\Support\Facades\FilamentView;
use Filament\View\PanelsRenderHook;
use Illuminate\Cookie\Middleware\AddQueuedCookiesToResponse;
use Illuminate\Cookie\Middleware\EncryptCookies;
use Illuminate\Foundation\Http\Middleware\PreventRequestForgery;
use Illuminate\Routing\Middleware\SubstituteBindings;
use Illuminate\Session\Middleware\StartSession;
use Illuminate\Support\HtmlString;
use Illuminate\View\Middleware\ShareErrorsFromSession;

class AdminPanelProvider extends PanelProvider
{
    public function panel(Panel $panel): Panel
    {
        return $panel
            ->default()
            ->id('admin')
            ->path('admin')
            ->login(Login::class)
            ->registration(Register::class)
            ->brandName(__('admin.brand.name'))
            ->brandLogo(asset('images/hrm_logo_mark.png'))
            ->brandLogoHeight('3rem')
            ->font('Cairo')
            ->colors([
                'primary' => Color::hex('#2563EB'),
                'success' => Color::hex('#10B981'),
                'warning' => Color::hex('#F59E0B'),
                'danger' => Color::hex('#EF4444'),
                'info' => Color::hex('#3B82F6'),
                'gray' => Color::Slate,
            ])
            ->defaultThemeMode(ThemeMode::Light)
            ->sidebarWidth('16.25rem')
            ->sidebarCollapsibleOnDesktop()
            ->collapsibleNavigationGroups(false)
            ->navigationGroups([
                NavigationGroup::make('Company')
                    ->label(fn (): string => AdminTrans::navGroup('company')),
                NavigationGroup::make('Recruitment')
                    ->label(fn (): string => AdminTrans::navGroup('recruitment')),
                NavigationGroup::make('AI')
                    ->label(fn (): string => AdminTrans::navGroup('ai')),
                NavigationGroup::make('Reports')
                    ->label(fn (): string => AdminTrans::navGroup('reports')),
                NavigationGroup::make('Platform')
                    ->label(fn (): string => AdminTrans::navGroup('platform')),
            ])
            ->discoverResources(in: app_path('Filament/Resources'), for: 'App\Filament\Resources')
            ->discoverPages(in: app_path('Filament/Pages'), for: 'App\Filament\Pages')
            ->pages([
                AdminDashboard::class,
            ])
            ->discoverWidgets(in: app_path('Filament/Widgets'), for: 'App\Filament\Widgets')
            ->middleware([
                EncryptCookies::class,
                AddQueuedCookiesToResponse::class,
                StartSession::class,
                SetAdminLocale::class,
                AuthenticateSession::class,
                ShareErrorsFromSession::class,
                PreventRequestForgery::class,
                SubstituteBindings::class,
                DisableBladeIconComponents::class,
                DispatchServingFilamentEvent::class,
            ])
            ->authMiddleware([
                Authenticate::class,
            ]);
    }

    public function boot(): void
    {
        FilamentView::registerRenderHook(
            PanelsRenderHook::HEAD_END,
            fn (): HtmlString => new HtmlString(
                '<link rel="stylesheet" href="'.asset('css/nawa-admin.css').'?v=6" />'
                .'<link rel="preconnect" href="https://fonts.googleapis.com">'
                .'<link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>'
                .'<link href="https://fonts.googleapis.com/css2?family=Cairo:wght@400;500;600;700&display=swap" rel="stylesheet">'
            ),
        );

        FilamentView::registerRenderHook(
            PanelsRenderHook::TOPBAR_LOGO_AFTER,
            fn (): string => view('filament.hooks.topbar-company')->render(),
        );

        FilamentView::registerRenderHook(
            PanelsRenderHook::GLOBAL_SEARCH_BEFORE,
            fn (): string => view('filament.hooks.topbar-ai')->render(),
        );

        FilamentView::registerRenderHook(
            PanelsRenderHook::USER_MENU_BEFORE,
            fn (): string => view('filament.hooks.topbar-controls')->render(),
        );
    }
}
