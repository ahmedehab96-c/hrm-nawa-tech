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

class ChatController extends BaseAiController
{
    public function chat(Request $request)
    {
        $validated = $request->validate([
            'message' => 'required|string|max:4000',
            'language_code' => 'nullable|string|max:8',
            'conversation_id' => 'nullable|integer',
        ]);

        $user = $request->user();
        $company = Company::query()->find($user->company_id);
        if (! $company) {
            return response()->json(['message' => 'Company not found'], 404);
        }

        $conversation = $this->resolveConversation(
            $company->id,
            $user->id,
            $validated['conversation_id'] ?? null,
            $validated['language_code'] ?? 'en',
        );
        $languageCode = (string) ($validated['language_code'] ?? 'en');
        $promptProfile = $this->aiPromptRegistryService->resolvePrompt(
            companyId: (int) $company->id,
            featureKey: 'assistant_chat',
            fallbackPrompt: $this->defaultSystemPromptForFeature('assistant_chat', $languageCode),
        );

        $userMessage = trim((string) $validated['message']);
        $safety = $this->promptSafetyService->assess(
            rawInput: $userMessage,
            safetyLevel: (string) ($company->ai_safety_level ?? 'standard'),
        );
        if (! $safety['allowed']) {
            $this->logUsage(
                companyId: $company->id,
                userId: $user->id,
                conversationId: $conversation->id,
                endpoint: 'ai/chat',
                provider: $company->ai_provider ?: 'openai',
                model: $company->ai_model,
                latencyMs: 0,
                promptTokens: 0,
                completionTokens: 0,
                totalTokens: 0,
                status: 'blocked_safety',
                errorMessage: $safety['reason'],
            );
            $this->aiAuditService->log(
                companyId: (int) $company->id,
                userId: (int) $user->id,
                eventType: 'ai_request_blocked_safety',
                severity: 'warning',
                endpoint: 'ai/chat',
                context: [
                    'reason' => $safety['reason'],
                    'feature' => 'assistant_chat',
                ],
            );

            return response()->json([
                'message' => 'Prompt blocked by AI safety policy',
                'reason' => $safety['reason'],
            ], 422);
        }
        $userMessage = $safety['sanitized'];

        AiMessage::query()->create([
            'conversation_id' => $conversation->id,
            'user_id' => $user->id,
            'role' => 'user',
            'content' => $userMessage,
        ]);

        $history = $conversation->messages()
            ->orderByDesc('id')
            ->limit(8)
            ->get(['role', 'content'])
            ->reverse()
            ->map(fn (AiMessage $message) => [
                'role' => (string) $message->role,
                'content' => (string) $message->content,
            ])
            ->values()
            ->all();

        $startedAt = microtime(true);
        $replyText = '';
        $provider = $company->ai_provider ?: 'openai';
        $model = $company->ai_model;
        $promptTokens = null;
        $completionTokens = null;
        $totalTokens = null;
        $metadata = [];
        $status = 'success';
        $errorMessage = null;

        try {
            $reply = $this->aiGatewayService->generateChatReply(
                message: $userMessage,
                languageCode: $languageCode,
                history: $history,
                providerOverride: $provider,
                modelOverride: $model,
                systemPromptOverride: $promptProfile['prompt'],
            );
            $replyText = $reply['content'];
            $provider = $reply['provider'];
            $model = $reply['model'];
            $promptTokens = $reply['prompt_tokens'];
            $completionTokens = $reply['completion_tokens'];
            $totalTokens = $reply['total_tokens'];
            $metadata = $reply['metadata'];
            $metadata['prompt_version_id'] = $promptProfile['version_id'];
            $metadata['prompt_version_label'] = $promptProfile['version_label'];
        } catch (Throwable $e) {
            $status = 'error';
            $errorMessage = $e->getMessage();
            $replyText = str_starts_with((string) ($validated['language_code'] ?? 'en'), 'ar')
                ? 'حدث خطأ مؤقت في خدمة الذكاء الاصطناعي. تمت معالجة الطلب محلياً.'
                : 'A temporary AI service error occurred. The request was handled locally.';
            $metadata = ['source' => 'controller-fallback'];
        }

        $latencyMs = (int) round((microtime(true) - $startedAt) * 1000);

        AiMessage::query()->create([
            'conversation_id' => $conversation->id,
            'user_id' => null,
            'role' => 'assistant',
            'content' => $replyText,
            'prompt_tokens' => $promptTokens,
            'completion_tokens' => $completionTokens,
            'total_tokens' => $totalTokens,
            'metadata' => $metadata,
        ]);

        $conversation->provider = $provider;
        $conversation->model = $model;
        $conversation->language_code = $languageCode;
        $conversation->last_message_at = Carbon::now();
        $conversation->save();

        $this->logUsage(
            companyId: $company->id,
            userId: $user->id,
            conversationId: $conversation->id,
            endpoint: 'ai/chat',
            provider: $provider,
            model: $model,
            latencyMs: $latencyMs,
            promptTokens: $promptTokens,
            completionTokens: $completionTokens,
            totalTokens: $totalTokens,
            status: $status,
            errorMessage: $errorMessage,
        );
        $this->aiAuditService->log(
            companyId: (int) $company->id,
            userId: (int) $user->id,
            eventType: $status === 'success' ? 'ai_request_processed' : 'ai_request_failed',
            severity: $status === 'success' ? 'info' : 'error',
            endpoint: 'ai/chat',
            context: [
                'provider' => $provider,
                'model' => $model,
                'latency_ms' => $latencyMs,
                'status' => $status,
                'prompt_version_id' => $promptProfile['version_id'],
            ],
        );

        return response()->json([
            'data' => [
                'conversation_id' => $conversation->id,
                'reply' => $replyText,
                'provider' => $provider,
                'model' => $model,
                'latency_ms' => $latencyMs,
                'status' => $status,
            ],
        ]);
    }

}
