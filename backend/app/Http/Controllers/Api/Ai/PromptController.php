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

class PromptController extends BaseAiController
{
    public function listPromptVersions(Request $request)
    {
        $companyId = (int) $request->user()->company_id;
        $featureKey = (string) ($request->query('feature_key') ?? '');
        $items = $this->aiPromptRegistryService->list(
            companyId: $companyId,
            featureKey: $featureKey !== '' ? $featureKey : null,
        )->map(fn (AiPromptVersion $v) => [
            'id' => $v->id,
            'feature_key' => $v->feature_key,
            'version_label' => $v->version_label,
            'system_prompt' => $v->system_prompt,
            'is_active' => (bool) $v->is_active,
            'created_by' => $v->created_by,
            'created_at' => $v->created_at?->toIso8601String(),
        ])->values()->all();

        return response()->json(['data' => $items]);
    }

    public function createPromptVersion(Request $request)
    {
        $validated = $request->validate([
            'feature_key' => 'required|in:assistant_chat,job_description,communication',
            'version_label' => 'required|string|max:64',
            'system_prompt' => 'required|string|max:12000',
            'activate' => 'nullable|boolean',
        ]);

        $user = $request->user();
        $version = $this->aiPromptRegistryService->create(
            companyId: (int) $user->company_id,
            userId: (int) $user->id,
            featureKey: (string) $validated['feature_key'],
            versionLabel: (string) $validated['version_label'],
            systemPrompt: (string) $validated['system_prompt'],
            activate: (bool) ($validated['activate'] ?? false),
        );
        $this->aiAuditService->log(
            companyId: (int) $user->company_id,
            userId: (int) $user->id,
            eventType: 'prompt_version_created',
            endpoint: 'ai/prompts',
            context: [
                'prompt_version_id' => $version->id,
                'feature_key' => $version->feature_key,
                'version_label' => $version->version_label,
                'is_active' => (bool) $version->is_active,
            ],
        );

        return response()->json([
            'data' => [
                'id' => $version->id,
                'feature_key' => $version->feature_key,
                'version_label' => $version->version_label,
                'is_active' => (bool) $version->is_active,
            ],
        ], 201);
    }

    public function activatePromptVersion(Request $request, string $id)
    {
        $user = $request->user();
        $version = $this->aiPromptRegistryService->activate(
            companyId: (int) $user->company_id,
            versionId: (int) $id,
        );
        if (! $version) {
            return response()->json(['message' => 'Prompt version not found'], 404);
        }

        $this->aiAuditService->log(
            companyId: (int) $user->company_id,
            userId: (int) $user->id,
            eventType: 'prompt_version_activated',
            endpoint: "ai/prompts/{$id}/activate",
            context: [
                'prompt_version_id' => $version->id,
                'feature_key' => $version->feature_key,
                'version_label' => $version->version_label,
            ],
        );

        return response()->json([
            'data' => [
                'id' => $version->id,
                'feature_key' => $version->feature_key,
                'version_label' => $version->version_label,
                'is_active' => (bool) $version->is_active,
            ],
        ]);
    }

}
