<?php

namespace App\Notifications;

use Illuminate\Bus\Queueable;
use Illuminate\Contracts\Queue\ShouldQueue;
use Illuminate\Notifications\Messages\MailMessage;
use Illuminate\Notifications\Notification;

class TeamUserWelcomeNotification extends Notification implements ShouldQueue
{
    use Queueable;

    public function __construct(
        private readonly string $plainPassword,
        private readonly string $companyName,
    ) {}

    /**
     * @return list<string>
     */
    public function via(object $notifiable): array
    {
        return ['mail'];
    }

    public function toMail(object $notifiable): MailMessage
    {
        $adminUrl = rtrim((string) config('app.url'), '/').'/admin';

        return (new MailMessage)
            ->subject('Your Nawa Tech HRM admin account')
            ->greeting('Hello '.$notifiable->name.'!')
            ->line('An administrator created an account for you on **'.$this->companyName.'**.')
            ->line('Email: '.$notifiable->email)
            ->line('Temporary password: '.$this->plainPassword)
            ->action('Sign in to admin', $adminUrl)
            ->line('Please change your password after the first login.')
            ->salutation('Nawa Tech HRM');
    }
}
