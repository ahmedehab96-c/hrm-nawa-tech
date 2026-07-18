<?php

namespace App\Notifications;

use App\Models\LeaveRequest;
use Illuminate\Bus\Queueable;
use Illuminate\Contracts\Queue\ShouldQueue;
use Illuminate\Notifications\Messages\MailMessage;
use Illuminate\Notifications\Notification;

class LeaveRejectedNotification extends Notification implements ShouldQueue
{
    use Queueable;

    public function __construct(private readonly LeaveRequest $leave) {}

    /**
     * @return list<string>
     */
    public function via(object $notifiable): array
    {
        return ['mail'];
    }

    public function toMail(object $notifiable): MailMessage
    {
        $from = $this->leave->from_date?->toFormattedDateString() ?? '';
        $to = $this->leave->to_date?->toFormattedDateString() ?? '';

        return (new MailMessage)
            ->subject('Leave request rejected')
            ->greeting('Hello '.$notifiable->name.'!')
            ->line('Your leave request was not approved.')
            ->line("Type: {$this->leave->type}")
            ->line("Dates: {$from} → {$to}")
            ->line('Please contact your manager if you have questions.')
            ->salutation('Nawa Tech HRM');
    }
}
