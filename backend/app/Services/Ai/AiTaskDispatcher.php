<?php

namespace App\Services\Ai;

use App\Jobs\ProcessAiTask;
use App\Models\AiTask;

/**
 * Centralizes creation and queuing of asynchronous AI tasks so the
 * Recruitment/Performance/Report controllers no longer duplicate the
 * "create AiTask + dispatch ProcessAiTask" boilerplate.
 */
class AiTaskDispatcher
{
    public const DEFAULT_QUEUE = 'ai-heavy';

    /**
     * @param  array<string, mixed>  $payload
     */
    public function dispatch(
        int $companyId,
        ?int $userId,
        string $taskType,
        array $payload,
        string $queue = self::DEFAULT_QUEUE,
    ): AiTask {
        $task = AiTask::query()->create([
            'company_id' => $companyId,
            'user_id' => $userId,
            'task_type' => $taskType,
            'status' => 'queued',
            'progress_percent' => 0,
            'queue_name' => $queue,
            'payload' => $payload,
        ]);

        ProcessAiTask::dispatch($task->id)->onQueue($queue);

        return $task;
    }
}
