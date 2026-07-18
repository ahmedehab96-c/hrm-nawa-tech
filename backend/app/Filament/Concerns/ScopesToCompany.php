<?php

namespace App\Filament\Concerns;

use Illuminate\Database\Eloquent\Builder;

trait ScopesToCompany
{
    public static function getEloquentQuery(): Builder
    {
        $query = parent::getEloquentQuery();
        $user = auth()->user();

        if ($user === null || $user->hasRole('super_admin')) {
            return $query;
        }

        if ($user->company_id !== null) {
            $query->where(
                $query->getModel()->getTable().'.company_id',
                $user->company_id,
            );
        }

        return $query;
    }
}
