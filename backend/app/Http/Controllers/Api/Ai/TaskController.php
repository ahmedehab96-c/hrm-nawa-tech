<?php

namespace App\Http\Controllers\Api\Ai;

use App\Jobs\ProcessAiEscalationDigest;
use App\Models\AiConversation;
use App\Models\AiAuditEvent;
use App\Models\AiEscalationNotification;
use App\Models\AiMessage;
use App\Models\AiPromptVersion;
use App\Models\AiTask;
use App\Models\AiUsageLog;
use App\Models\Company;
use App\Models\JobDescription;
use Illuminate\Support\Facades\DB;
use Illuminate\Http\Request;
use Illuminate\Support\Carbon;
use Throwable;

class TaskController extends BaseAiController
{
    public function taskStatus(Request $request, string $id)
    {
        $task = AiTask::query()
            ->where('company_id', $request->user()->company_id)
            ->find($id);
        if (! $task) {
            return response()->json(['message' => 'Task not found'], 404);
        }

        if ($task->user_id !== null && (int) $task->user_id !== (int) $request->user()->id && ! $request->user()->hasRole('company_admin')) {
            return response()->json(['message' => 'Forbidden'], 403);
        }

        return response()->json([
            'data' => [
                'id' => $task->id,
                'task_type' => $task->task_type,
                'status' => $task->status,
                'progress_percent' => $task->progress_percent,
                'queue_name' => $task->queue_name,
                'result' => $task->result,
                'error_message' => $task->error_message,
                'started_at' => $task->started_at?->toIso8601String(),
                'finished_at' => $task->finished_at?->toIso8601String(),
                'created_at' => $task->created_at?->toIso8601String(),
            ],
        ]);
    }

}
