<?php

namespace App\Filament\Auth;

use App\Services\CompanyRegistrationService;
use Filament\Auth\Pages\Register as BaseRegister;
use Filament\Forms\Components\TextInput;
use Filament\Schemas\Components\Component;
use Filament\Schemas\Schema;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Validation\Rules\Password;
use SensitiveParameter;

class Register extends BaseRegister
{
    protected static string $layout = 'filament.layouts.auth-split';

    public function hasLogo(): bool
    {
        return false;
    }

    public function form(Schema $schema): Schema
    {
        return $schema
            ->components([
                $this->getCompanyNameFormComponent(),
                $this->getNameFormComponent(),
                $this->getEmailFormComponent(),
                $this->getPasswordFormComponent(),
                $this->getPasswordConfirmationFormComponent(),
            ]);
    }

    protected function getCompanyNameFormComponent(): Component
    {
        return TextInput::make('company_name')
            ->label(__('admin.auth.company_name'))
            ->required()
            ->maxLength(255)
            ->autofocus();
    }

    protected function getNameFormComponent(): Component
    {
        return TextInput::make('name')
            ->label(__('filament-panels::auth/pages/register.form.name.label'))
            ->required()
            ->maxLength(255);
    }

    /**
     * Keep plain password so CompanyRegistrationService can hash once.
     */
    protected function getPasswordFormComponent(): Component
    {
        return TextInput::make('password')
            ->label(__('filament-panels::auth/pages/register.form.password.label'))
            ->password()
            ->revealable(filament()->arePasswordsRevealable())
            ->required()
            ->rule(Password::default())
            ->showAllValidationMessages()
            ->same('passwordConfirmation')
            ->validationAttribute(__('filament-panels::auth/pages/register.form.password.validation_attribute'));
    }

    /**
     * @param  array<string, mixed>  $data
     */
    protected function handleRegistration(#[SensitiveParameter] array $data): Model
    {
        $result = app(CompanyRegistrationService::class)->register(
            adminName: (string) $data['name'],
            email: (string) $data['email'],
            password: (string) $data['password'],
            companyName: (string) ($data['company_name'] ?? $data['name']),
        );

        $user = $result['user'];

        try {
            $user->sendEmailVerificationNotification();
        } catch (\Throwable) {
            // Mail may be unavailable in local dev.
        }

        return $user;
    }
}
