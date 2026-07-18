<?php

namespace App\Filament\Resources\Users\Pages;

use App\Filament\Concerns\SetsCompanyOnCreate;
use App\Filament\Resources\Users\UserResource;
use App\Models\Company;
use App\Notifications\TeamUserWelcomeNotification;
use App\Services\TeamUserService;
use Filament\Resources\Pages\CreateRecord;
use Illuminate\Support\Facades\Notification;

class CreateUser extends CreateRecord
{
    use SetsCompanyOnCreate;

    protected static string $resource = UserResource::class;

    protected function afterCreate(): void
    {
        app(TeamUserService::class)->syncRole($this->record, (string) $this->record->role);

        $plainPassword = $this->data['password'] ?? null;
        if (! filled($plainPassword)) {
            return;
        }

        $company = Company::query()->find($this->record->company_id);
        $companyName = $company?->name ?? 'your company';

        try {
            Notification::send(
                $this->record,
                new TeamUserWelcomeNotification((string) $plainPassword, $companyName),
            );
        } catch (\Throwable) {
            // Mail may be log/unavailable in local dev.
        }
    }
}
