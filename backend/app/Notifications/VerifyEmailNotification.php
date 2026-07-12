<?php

namespace App\Notifications;

use Illuminate\Auth\Notifications\VerifyEmail as BaseVerifyEmail;
use Illuminate\Notifications\Messages\MailMessage;
use Illuminate\Support\Carbon;
use Illuminate\Support\Facades\Config;
use Illuminate\Support\Facades\URL;

class VerifyEmailNotification extends BaseVerifyEmail
{
    protected function verificationUrl(mixed $notifiable): string
    {
        $apiBase = rtrim(config('app.url'), '/');

        // Signed API URL — Flutter / browser can open it to confirm.
        return URL::temporarySignedRoute(
            'verification.verify',
            Carbon::now()->addMinutes((int) Config::get('auth.verification.expire', 60)),
            [
                'id' => $notifiable->getKey(),
                'hash' => sha1($notifiable->getEmailForVerification()),
            ],
            absolute: true
        );
    }

    public function toMail(mixed $notifiable): MailMessage
    {
        $url = $this->verificationUrl($notifiable);

        return (new MailMessage)
            ->subject('Verify your Nawa Tech HRM email')
            ->greeting('Hello!')
            ->line('Please verify your email to activate your HRM trial account.')
            ->action('Verify email', $url)
            ->line('This link expires in ' . (int) Config::get('auth.verification.expire', 60) . ' minutes.')
            ->salutation('Nawa Tech HRM');
    }
}
