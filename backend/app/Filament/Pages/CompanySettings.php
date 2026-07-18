<?php

namespace App\Filament\Pages;

use App\Filament\Resources\Users\UserResource;
use App\Models\Company;
use App\Support\AdminTrans;
use BackedEnum;
use Filament\Actions\Action;
use Filament\Forms\Components\Select;
use Filament\Forms\Components\TextInput;
use Filament\Forms\Components\Toggle;
use Filament\Notifications\Notification;
use Filament\Pages\Page;
use Filament\Schemas\Components\Actions;
use Filament\Schemas\Components\EmbeddedSchema;
use Filament\Schemas\Components\Form;
use Filament\Schemas\Components\Section;
use Filament\Schemas\Schema;
use Filament\Support\Icons\Heroicon;
use UnitEnum;

/**
 * @property-read Schema $form
 */
class CompanySettings extends Page
{
    protected static string|BackedEnum|null $navigationIcon = Heroicon::OutlinedCog6Tooth;

    protected static string|UnitEnum|null $navigationGroup = null;

    protected static ?string $navigationLabel = null;

    protected static ?int $navigationSort = 10;

    public static function getNavigationLabel(): string
    {
        return __('admin.nav.settings');
    }

    public function getTitle(): string
    {
        return AdminTrans::page('company_settings');
    }

    protected string $view = 'filament.pages.company-settings';

    /**
     * @var array<string, mixed> | null
     */
    public ?array $data = [];

    public static function canAccess(): bool
    {
        $user = auth()->user();

        return $user !== null
            && ! $user->hasRole('super_admin')
            && $user->company_id !== null
            && $user->hasPermission('settings.manage');
    }

    public function mount(): void
    {
        $company = $this->company();
        abort_unless($company !== null, 404);

        $this->form->fill([
            'name' => $company->name,
            'email' => $company->email,
            'phone' => $company->phone,
            'address' => $company->address,
            'wifi_ssid' => $company->wifi_ssid,
            'plan' => $company->plan,
            'trial_ends_at' => $company->trial_ends_at?->toDateString(),
            'ai_enabled' => (bool) $company->ai_enabled,
            'ai_plan' => $company->ai_plan,
            'ai_provider' => $company->ai_provider ?? 'openai',
            'ai_model' => $company->ai_model,
            'ai_requests_per_minute' => $company->ai_requests_per_minute ?? 60,
            'ai_monthly_token_limit' => $company->ai_monthly_token_limit ?? 500000,
            'ai_safety_level' => $company->ai_safety_level ?? 'standard',
            'ai_digest_enabled' => (bool) ($company->ai_digest_enabled ?? true),
            'ai_slack_webhook_url' => $company->ai_slack_webhook_url,
            'ai_alert_email_from' => $company->ai_alert_email_from,
        ]);
    }

    public function defaultForm(Schema $schema): Schema
    {
        return $schema
            ->statePath('data');
    }

    public function form(Schema $schema): Schema
    {
        return $schema
            ->components([
                Section::make(AdminTrans::section('company_profile'))
                    ->schema([
                        TextInput::make('name')->label(AdminTrans::field('name'))->required()->maxLength(255),
                        TextInput::make('email')->label(AdminTrans::field('email'))->email()->maxLength(255),
                        TextInput::make('phone')->label(AdminTrans::field('phone'))->tel()->maxLength(64),
                        TextInput::make('address')->label(AdminTrans::field('address'))->maxLength(500),
                        TextInput::make('wifi_ssid')
                            ->label(AdminTrans::field('wifi_ssid'))
                            ->helperText(AdminTrans::helpers('wifi_ssid'))
                            ->maxLength(128),
                        TextInput::make('plan')->label(AdminTrans::field('plan'))->disabled(),
                        TextInput::make('trial_ends_at')->label(AdminTrans::field('trial_ends'))->disabled(),
                    ])
                    ->columns(2),
                Section::make(AdminTrans::section('ai_settings'))
                    ->schema([
                        Toggle::make('ai_enabled')->label(AdminTrans::field('ai_enabled')),
                        Select::make('ai_plan')
                            ->label(AdminTrans::field('ai_plan'))
                            ->options(AdminTrans::options('plan')),
                        Select::make('ai_provider')
                            ->label(AdminTrans::field('ai_provider'))
                            ->options(AdminTrans::options('ai_provider')),
                        TextInput::make('ai_model')->label(AdminTrans::field('ai_model'))->maxLength(64),
                        TextInput::make('ai_requests_per_minute')
                            ->label(AdminTrans::field('ai_requests_per_minute'))
                            ->numeric()
                            ->minValue(1)
                            ->maxValue(600),
                        TextInput::make('ai_monthly_token_limit')
                            ->label(AdminTrans::field('ai_monthly_token_limit'))
                            ->numeric()
                            ->minValue(1000),
                        Select::make('ai_safety_level')
                            ->label(AdminTrans::field('ai_safety_level'))
                            ->options(AdminTrans::options('ai_safety')),
                        Toggle::make('ai_digest_enabled')->label(AdminTrans::field('ai_digest_enabled')),
                        TextInput::make('ai_alert_email_from')
                            ->label(AdminTrans::field('ai_alert_email_from'))
                            ->email()
                            ->maxLength(255),
                        TextInput::make('ai_slack_webhook_url')
                            ->label(AdminTrans::field('ai_slack_webhook_url'))
                            ->url()
                            ->maxLength(2000)
                            ->columnSpanFull(),
                    ])
                    ->columns(2),
            ]);
    }

    public function content(Schema $schema): Schema
    {
        return $schema
            ->components([
                Form::make([EmbeddedSchema::make('form')])
                    ->id('form')
                    ->livewireSubmitHandler('save')
                    ->footer([
                        Actions::make([
                            Action::make('save')
                                ->label(AdminTrans::action('save_settings'))
                                ->submit('save')
                                ->keyBindings(['mod+s']),
                        ]),
                    ]),
            ]);
    }

    /**
     * @return array<Action>
     */
    protected function getHeaderActions(): array
    {
        return [
            Action::make('teamUsers')
                ->label(AdminTrans::action('team_users'))
                ->icon(Heroicon::OutlinedUserGroup)
                ->url(UserResource::getUrl()),
            Action::make('billing')
                ->label(AdminTrans::action('billing'))
                ->icon(Heroicon::OutlinedCreditCard)
                ->url(BillingUpgrade::getUrl()),
            Action::make('roles')
                ->label(AdminTrans::action('roles_access'))
                ->icon(Heroicon::OutlinedShieldCheck)
                ->url(RolesOverview::getUrl()),
        ];
    }

    public function save(): void
    {
        $company = $this->company();
        abort_unless($company !== null, 404);

        $data = $this->form->getState();

        $company->fill([
            'name' => $data['name'],
            'email' => $data['email'] ?? null,
            'phone' => $data['phone'] ?? null,
            'address' => $data['address'] ?? null,
            'wifi_ssid' => $data['wifi_ssid'] ?? null,
            'ai_enabled' => (bool) ($data['ai_enabled'] ?? false),
            'ai_plan' => $data['ai_plan'] ?? $company->ai_plan,
            'ai_provider' => $data['ai_provider'] ?? $company->ai_provider,
            'ai_model' => $data['ai_model'] ?? null,
            'ai_requests_per_minute' => $data['ai_requests_per_minute'] ?? $company->ai_requests_per_minute,
            'ai_monthly_token_limit' => $data['ai_monthly_token_limit'] ?? $company->ai_monthly_token_limit,
            'ai_safety_level' => $data['ai_safety_level'] ?? $company->ai_safety_level,
            'ai_digest_enabled' => (bool) ($data['ai_digest_enabled'] ?? true),
            'ai_alert_email_from' => $data['ai_alert_email_from'] ?? null,
            'ai_slack_webhook_url' => $data['ai_slack_webhook_url'] ?? null,
        ]);
        $company->save();

        Notification::make()
            ->title(AdminTrans::notification('settings_saved'))
            ->success()
            ->send();
    }

    protected function company(): ?Company
    {
        $user = auth()->user();
        if ($user?->company_id === null) {
            return null;
        }

        return Company::query()->find($user->company_id);
    }
}
