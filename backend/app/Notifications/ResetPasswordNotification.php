<?php

namespace App\Notifications;

use Illuminate\Auth\Notifications\ResetPassword as BaseResetPassword;
use Illuminate\Notifications\Messages\MailMessage;

class ResetPasswordNotification extends BaseResetPassword
{
    protected function resetUrl(mixed $notifiable): string
    {
        $appUrl = rtrim(config('app.url'), '/');

        return $appUrl . '/reset-password?' . http_build_query([
            'token' => $this->token,
            'email' => $notifiable->getEmailForPasswordReset(),
        ]);
    }

    public function toMail(mixed $notifiable): MailMessage
    {
        $url = $this->resetUrl($notifiable);

        return (new MailMessage)
            ->subject('Reset your HRM password')
            ->greeting('Hello!')
            ->line('You requested a password reset for your HRM account.')
            ->action('Reset password', $url)
            ->line('This link expires in ' . config('auth.passwords.users.expire', 60) . ' minutes.')
            ->line('If you did not request this, no action is needed.')
            ->salutation('HRM Team');
    }
}
