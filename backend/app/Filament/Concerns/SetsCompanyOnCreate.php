<?php

namespace App\Filament\Concerns;

trait SetsCompanyOnCreate
{
    /**
     * @param  array<string, mixed>  $data
     * @return array<string, mixed>
     */
    protected function mutateFormDataBeforeCreate(array $data): array
    {
        $user = auth()->user();

        if ($user !== null && ! $user->hasRole('super_admin') && $user->company_id !== null) {
            $data['company_id'] = $user->company_id;
        }

        return $data;
    }
}
