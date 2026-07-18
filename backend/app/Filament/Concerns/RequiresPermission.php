<?php

namespace App\Filament\Concerns;

trait RequiresPermission
{
    public static function canAccess(): bool
    {
        $user = auth()->user();

        return $user !== null
            && $user->company_id !== null
            && $user->hasPermission(static::$requiredPermission);
    }
}
