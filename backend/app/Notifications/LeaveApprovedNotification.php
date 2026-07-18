<?php

namespace App\Notifications;

use App\Models\LeaveRequest;
use Illuminate\Bus\Queueable;
use Illuminate\Contracts\Queue\ShouldQueue;
use Illuminate\Notifications\Messages\MailMessage;
use Illuminate\Notifications\Notification;

class LeaveApprovedNotification extends Notification implements ShouldQueue
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
            ->subject('Leave request approved')
            ->greeting('Hello '.$notifiable->name.'!')
            ->line('Your leave request has been approved.')
            ->line("Type: {$this->leave->type}")
            ->line("Dates: {$from} → {$to}")
            ->line('Days: '.$this->leave->days)
            ->salutation('Nawa Tech HRM');
    }
}
