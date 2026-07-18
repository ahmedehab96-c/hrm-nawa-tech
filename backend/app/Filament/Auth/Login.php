<?php

namespace App\Filament\Auth;

use Filament\Auth\Pages\Login as BaseLogin;

class Login extends BaseLogin
{
    protected static string $layout = 'filament.layouts.auth-split';

    public function hasLogo(): bool
    {
        return false;
    }
}
