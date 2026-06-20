<?php

namespace App\Jobs;

use App\Models\AiEscalationNotification;
use App\Services\AiEscalationService;
use Illuminate\Contracts\Queue\ShouldQueue;
use Illuminate\Foundation\Queue\Queueable;

class ProcessAiEscalationNotification implements ShouldQueue
{
    use Queueable;

    public int $tries = 3;

    public array $backoff = [30, 120, 300];

    public function __construct(public readonly int $notificationId)
    {
        $this->onQueue('ai-alerts');
    }

    public function handle(AiEscalationService $service): void
    {
        $notification = AiEscalationNotification::query()->with('company')->find($this->notificationId);
        if (! $notification) {
            return;
        }
        if ($notification->status === 'sent') {
            return;
        }
        if ($notification->scheduled_for && $notification->scheduled_for->isFuture()) {
            $this->release($notification->scheduled_for->diffInSeconds(now()));
            return;
        }

        $service->process($notification);
    }

    public function failed(\Throwable $e): void
    {
        $notification = AiEscalationNotification::query()->find($this->notificationId);
        if (! $notification) {
            return;
        }

        $service = app(AiEscalationService::class);
        $service->markFailed($notification, $e->getMessage());
    }
}
