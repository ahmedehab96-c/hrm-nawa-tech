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

    protected function mobileVerificationUrl(mixed $notifiable): ?string
    {
        $scheme = (string) config('app.mobile_deep_link_scheme', '');
        if ($scheme === '') {
            return null;
        }

        $apiUrl = parse_url($this->verificationUrl($notifiable));
        $path = $apiUrl['path'] ?? '';
        if (! preg_match('#/email/verify/(\d+)/([^/]+)#', $path, $matches)) {
            return null;
        }

        parse_str($apiUrl['query'] ?? '', $query);

        return $scheme.'://verify-email?'.http_build_query([
            'id' => $matches[1],
            'hash' => $matches[2],
            'expires' => $query['expires'] ?? '',
            'signature' => $query['signature'] ?? '',
        ]);
    }

    public function toMail(mixed $notifiable): MailMessage
    {
        $url = $this->verificationUrl($notifiable);
        $mobileUrl = $this->mobileVerificationUrl($notifiable);

        $mail = (new MailMessage)
            ->subject('Verify your Nawa Tech HRM email')
            ->greeting('Hello!')
            ->line('Please verify your email to activate your HRM trial account.')
            ->action('Verify email', $url)
            ->line('This link expires in '.(int) Config::get('auth.verification.expire', 60).' minutes.');

        if ($mobileUrl !== null) {
            $mail->line('On mobile, open the employee app with this link:')
                ->line($mobileUrl);
        }

        return $mail->salutation('Nawa Tech HRM');
    }
}
