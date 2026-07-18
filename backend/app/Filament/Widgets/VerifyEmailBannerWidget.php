<?php

namespace App\Filament\Widgets;

use App\Support\AdminTrans;
use Filament\Notifications\Notification;
use Filament\Widgets\Widget;

class VerifyEmailBannerWidget extends Widget
{
    protected static ?int $sort = -1;

    protected int|string|array $columnSpan = 'full';

    protected string $view = 'filament.widgets.verify-email-banner';

    public static function canView(): bool
    {
        $user = auth()->user();

        return $user !== null && ! $user->hasVerifiedEmail();
    }

    public function resend(): void
    {
        $user = auth()->user();
        abort_unless($user !== null, 401);

        $user->sendEmailVerificationNotification();

        Notification::make()
            ->title(AdminTrans::notification('verification_sent'))
            ->success()
            ->send();
    }
}
