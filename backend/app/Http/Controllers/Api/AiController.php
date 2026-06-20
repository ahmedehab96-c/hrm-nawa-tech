<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
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
use App\Services\AiAuditService;
use App\Services\AiEscalationService;
use App\Services\AiGatewayService;
use App\Services\AiPromptRegistryService;
use App\Services\PromptSafetyService;
use Illuminate\Support\Facades\DB;
use Illuminate\Http\Request;
use Illuminate\Support\Carbon;
use Throwable;

class AiController extends Controller
{
    public function __construct(
        private readonly AiGatewayService $aiGatewayService,
        private readonly AiPromptRegistryService $aiPromptRegistryService,
        private readonly AiAuditService $aiAuditService,
        private readonly AiEscalationService $aiEscalationService,
        private readonly PromptSafetyService $promptSafetyService,
    ) {}

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

    public function generateJobDescription(Request $request)
    {
        $validated = $request->validate([
            'job_title' => 'required|string|max:255',
            'department' => 'nullable|string|max:255',
            'location' => 'nullable|string|max:255',
            'employment_type' => 'nullable|string|max:64',
            'requirements' => 'nullable|string|max:3000',
            'responsibilities' => 'nullable|string|max:3000',
            'tone' => 'nullable|in:professional,concise,friendly,formal',
            'language_code' => 'nullable|string|max:8',
            'job_posting_id' => 'nullable|integer',
        ]);

        $user = $request->user();
        $company = Company::query()->find($user->company_id);
        if (! $company) {
            return response()->json(['message' => 'Company not found'], 404);
        }

        $languageCode = $validated['language_code'] ?? 'en';
        $tone = $validated['tone'] ?? 'professional';
        $jobTitle = trim((string) $validated['job_title']);
        $department = trim((string) ($validated['department'] ?? ''));
        $location = trim((string) ($validated['location'] ?? ''));
        $employmentType = trim((string) ($validated['employment_type'] ?? ''));
        $requirements = trim((string) ($validated['requirements'] ?? ''));
        $responsibilities = trim((string) ($validated['responsibilities'] ?? ''));

        $prompt = $this->buildJobDescriptionPrompt(
            languageCode: $languageCode,
            title: $jobTitle,
            department: $department,
            location: $location,
            employmentType: $employmentType,
            requirements: $requirements,
            responsibilities: $responsibilities,
            tone: $tone,
        );
        $promptProfile = $this->aiPromptRegistryService->resolvePrompt(
            companyId: (int) $company->id,
            featureKey: 'job_description',
            fallbackPrompt: $this->defaultSystemPromptForFeature('job_description', (string) $languageCode),
        );
        $safety = $this->promptSafetyService->assess(
            rawInput: $prompt,
            safetyLevel: (string) ($company->ai_safety_level ?? 'standard'),
        );
        if (! $safety['allowed']) {
            $this->logUsage(
                companyId: $company->id,
                userId: $user->id,
                conversationId: null,
                endpoint: 'ai/job-descriptions/generate',
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
                endpoint: 'ai/job-descriptions/generate',
                context: [
                    'reason' => $safety['reason'],
                    'feature' => 'job_description',
                ],
            );

            return response()->json([
                'message' => 'Prompt blocked by AI safety policy',
                'reason' => $safety['reason'],
            ], 422);
        }
        $prompt = $safety['sanitized'];

        $startedAt = microtime(true);
        $status = 'success';
        $errorMessage = null;
        $provider = $company->ai_provider ?: 'openai';
        $model = $company->ai_model;
        $promptTokens = null;
        $completionTokens = null;
        $totalTokens = null;

        try {
            $result = $this->aiGatewayService->generateChatReply(
                message: $prompt,
                languageCode: $languageCode,
                history: [],
                providerOverride: $provider,
                modelOverride: $model,
                systemPromptOverride: $promptProfile['prompt'],
            );
            $content = $result['content'];
            $provider = $result['provider'];
            $model = $result['model'];
            $promptTokens = $result['prompt_tokens'];
            $completionTokens = $result['completion_tokens'];
            $totalTokens = $result['total_tokens'];
        } catch (Throwable $e) {
            $status = 'error';
            $errorMessage = $e->getMessage();
            $content = str_starts_with($languageCode, 'ar')
                ? "المسمى الوظيفي: {$jobTitle}\n\nالوصف:\nيرجى المحاولة لاحقاً بعد تفعيل مزود الذكاء الاصطناعي."
                : "Job Title: {$jobTitle}\n\nDescription:\nPlease try again after enabling AI provider settings.";
        }

        $latencyMs = (int) round((microtime(true) - $startedAt) * 1000);

        $record = JobDescription::query()->create([
            'company_id' => $company->id,
            'job_posting_id' => $validated['job_posting_id'] ?? null,
            'created_by' => $user->id,
            'job_title' => $jobTitle,
            'department' => $department !== '' ? $department : null,
            'location' => $location !== '' ? $location : null,
            'employment_type' => $employmentType !== '' ? $employmentType : null,
            'language_code' => $languageCode,
            'tone' => $tone,
            'content' => $content,
            'provider' => $provider,
            'model' => $model,
        ]);

        $this->logUsage(
            companyId: $company->id,
            userId: $user->id,
            conversationId: null,
            endpoint: 'ai/job-descriptions/generate',
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
            endpoint: 'ai/job-descriptions/generate',
            context: [
                'provider' => $provider,
                'model' => $model,
                'status' => $status,
                'latency_ms' => $latencyMs,
                'prompt_version_id' => $promptProfile['version_id'],
            ],
        );

        return response()->json([
            'data' => [
                'id' => $record->id,
                'content' => $content,
                'provider' => $provider,
                'model' => $model,
                'latency_ms' => $latencyMs,
                'status' => $status,
            ],
        ]);
    }

    public function generateCommunication(Request $request)
    {
        $validated = $request->validate([
            'type' => 'required|in:email,letter',
            'purpose' => 'required|string|max:500',
            'recipient_name' => 'nullable|string|max:255',
            'employee_name' => 'nullable|string|max:255',
            'department' => 'nullable|string|max:255',
            'tone' => 'nullable|in:professional,friendly,formal,strict',
            'key_points' => 'nullable|string|max:3000',
            'language_code' => 'nullable|string|max:8',
        ]);

        $user = $request->user();
        $company = Company::query()->find($user->company_id);
        if (! $company) {
            return response()->json(['message' => 'Company not found'], 404);
        }

        $languageCode = $validated['language_code'] ?? 'en';
        $prompt = $this->buildCommunicationPrompt(
            languageCode: $languageCode,
            type: (string) $validated['type'],
            purpose: (string) $validated['purpose'],
            recipientName: (string) ($validated['recipient_name'] ?? ''),
            employeeName: (string) ($validated['employee_name'] ?? ''),
            department: (string) ($validated['department'] ?? ''),
            tone: (string) ($validated['tone'] ?? 'professional'),
            keyPoints: (string) ($validated['key_points'] ?? ''),
        );
        $promptProfile = $this->aiPromptRegistryService->resolvePrompt(
            companyId: (int) $company->id,
            featureKey: 'communication',
            fallbackPrompt: $this->defaultSystemPromptForFeature('communication', (string) $languageCode),
        );
        $safety = $this->promptSafetyService->assess(
            rawInput: $prompt,
            safetyLevel: (string) ($company->ai_safety_level ?? 'standard'),
        );
        if (! $safety['allowed']) {
            $this->logUsage(
                companyId: $company->id,
                userId: $user->id,
                conversationId: null,
                endpoint: 'ai/communications/generate',
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
                endpoint: 'ai/communications/generate',
                context: [
                    'reason' => $safety['reason'],
                    'feature' => 'communication',
                ],
            );

            return response()->json([
                'message' => 'Prompt blocked by AI safety policy',
                'reason' => $safety['reason'],
            ], 422);
        }
        $prompt = $safety['sanitized'];

        $startedAt = microtime(true);
        $status = 'success';
        $errorMessage = null;
        $provider = $company->ai_provider ?: 'openai';
        $model = $company->ai_model;
        $promptTokens = null;
        $completionTokens = null;
        $totalTokens = null;

        try {
            $result = $this->aiGatewayService->generateChatReply(
                message: $prompt,
                languageCode: $languageCode,
                history: [],
                providerOverride: $provider,
                modelOverride: $model,
                systemPromptOverride: $promptProfile['prompt'],
            );
            $content = $result['content'];
            $provider = $result['provider'];
            $model = $result['model'];
            $promptTokens = $result['prompt_tokens'];
            $completionTokens = $result['completion_tokens'];
            $totalTokens = $result['total_tokens'];
        } catch (Throwable $e) {
            $status = 'error';
            $errorMessage = $e->getMessage();
            $content = str_starts_with($languageCode, 'ar')
                ? "الموضوع: {$validated['purpose']}\n\nالنص:\nتعذّر التوليد حالياً، أعد المحاولة لاحقاً."
                : "Subject: {$validated['purpose']}\n\nBody:\nGeneration failed temporarily, please try again.";
        }

        $latencyMs = (int) round((microtime(true) - $startedAt) * 1000);

        $this->logUsage(
            companyId: $company->id,
            userId: $user->id,
            conversationId: null,
            endpoint: 'ai/communications/generate',
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
            endpoint: 'ai/communications/generate',
            context: [
                'provider' => $provider,
                'model' => $model,
                'status' => $status,
                'latency_ms' => $latencyMs,
                'prompt_version_id' => $promptProfile['version_id'],
            ],
        );

        return response()->json([
            'data' => [
                'content' => $content,
                'provider' => $provider,
                'model' => $model,
                'latency_ms' => $latencyMs,
                'status' => $status,
            ],
        ]);
    }

    public function usage(Request $request)
    {
        $user = $request->user();
        $company = Company::query()->find($user->company_id);
        if (! $company) {
            return response()->json(['message' => 'Company not found'], 404);
        }

        $monthStart = now()->startOfMonth();
        $monthEnd = now()->endOfMonth();
        $todayStart = now()->startOfDay();
        $todayEnd = now()->endOfDay();

        $monthlyTokensUsed = (int) AiUsageLog::query()
            ->where('company_id', $company->id)
            ->whereBetween('created_at', [$monthStart, $monthEnd])
            ->sum('total_tokens');
        $monthlyLimit = (int) ($company->ai_monthly_token_limit ?? 500000);

        $requestsToday = (int) AiUsageLog::query()
            ->where('company_id', $company->id)
            ->whereBetween('created_at', [$todayStart, $todayEnd])
            ->count();
        $errorsToday = (int) AiUsageLog::query()
            ->where('company_id', $company->id)
            ->whereBetween('created_at', [$todayStart, $todayEnd])
            ->where('status', 'error')
            ->count();

        $byEndpoint = AiUsageLog::query()
            ->where('company_id', $company->id)
            ->whereBetween('created_at', [$monthStart, $monthEnd])
            ->select('endpoint', DB::raw('COUNT(*) as requests'), DB::raw('COALESCE(SUM(total_tokens),0) as tokens'))
            ->groupBy('endpoint')
            ->orderByDesc('requests')
            ->get()
            ->map(fn ($row) => [
                'endpoint' => (string) $row->endpoint,
                'requests' => (int) $row->requests,
                'tokens' => (int) $row->tokens,
            ])
            ->values()
            ->all();

        $monthLogs = AiUsageLog::query()
            ->where('company_id', $company->id)
            ->whereBetween('created_at', [$monthStart, $monthEnd])
            ->get(['provider', 'model', 'prompt_tokens', 'completion_tokens']);
        $todayLogs = AiUsageLog::query()
            ->where('company_id', $company->id)
            ->whereBetween('created_at', [$todayStart, $todayEnd])
            ->get(['provider', 'model', 'prompt_tokens', 'completion_tokens']);

        $monthlyCostUsd = 0.0;
        $dailyCostUsd = 0.0;
        $costByProvider = [];
        $costByModel = [];

        foreach ($monthLogs as $log) {
            $cost = $this->estimateCostUsd(
                provider: (string) ($log->provider ?? ''),
                model: (string) ($log->model ?? ''),
                promptTokens: (int) ($log->prompt_tokens ?? 0),
                completionTokens: (int) ($log->completion_tokens ?? 0),
            );
            $monthlyCostUsd += $cost;

            $provider = (string) ($log->provider ?? 'unknown');
            $model = (string) ($log->model ?? 'unknown');
            $costByProvider[$provider] = round(($costByProvider[$provider] ?? 0) + $cost, 6);
            $costByModel[$model] = round(($costByModel[$model] ?? 0) + $cost, 6);
        }

        foreach ($todayLogs as $log) {
            $dailyCostUsd += $this->estimateCostUsd(
                provider: (string) ($log->provider ?? ''),
                model: (string) ($log->model ?? ''),
                promptTokens: (int) ($log->prompt_tokens ?? 0),
                completionTokens: (int) ($log->completion_tokens ?? 0),
            );
        }

        return response()->json([
            'data' => [
                'monthly_tokens_used' => $monthlyTokensUsed,
                'monthly_token_limit' => $monthlyLimit,
                'monthly_usage_percent' => $monthlyLimit > 0
                    ? round(($monthlyTokensUsed / $monthlyLimit) * 100, 2)
                    : 0,
                'requests_today' => $requestsToday,
                'errors_today' => $errorsToday,
                'estimated_cost_month_usd' => round($monthlyCostUsd, 4),
                'estimated_cost_today_usd' => round($dailyCostUsd, 4),
                'requests_per_minute_limit' => (int) ($company->ai_requests_per_minute ?? 60),
                'feature_flags' => is_array($company->ai_feature_flags) ? $company->ai_feature_flags : [],
                'by_endpoint' => $byEndpoint,
                'cost_by_provider' => $costByProvider,
                'cost_by_model' => $costByModel,
            ],
        ]);
    }

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

    public function observability(Request $request)
    {
        $user = $request->user();
        $company = Company::query()->find($user->company_id);
        if (! $company) {
            return response()->json(['message' => 'Company not found'], 404);
        }

        $days = max(1, min(90, (int) $request->query('days', 14)));
        $from = now()->startOfDay()->subDays($days - 1);
        $to = now()->endOfDay();

        $logs = AiUsageLog::query()
            ->where('company_id', $company->id)
            ->whereBetween('created_at', [$from, $to])
            ->get(['endpoint', 'status', 'latency_ms', 'created_at']);

        $daily = [];
        $endpointLatencies = [];
        $blockedCounts = [];
        foreach ($logs as $log) {
            $day = $log->created_at?->toDateString() ?? now()->toDateString();
            if (! isset($daily[$day])) {
                $daily[$day] = [
                    'date' => $day,
                    'requests' => 0,
                    'errors' => 0,
                    'blocked' => 0,
                    'latency_samples' => [],
                ];
            }

            $daily[$day]['requests']++;
            $status = (string) ($log->status ?? 'success');
            if ($status === 'error') {
                $daily[$day]['errors']++;
            }
            if (str_starts_with($status, 'blocked_')) {
                $daily[$day]['blocked']++;
                $blockedCounts[$status] = (int) ($blockedCounts[$status] ?? 0) + 1;
            }

            if ($log->latency_ms !== null && $log->latency_ms > 0) {
                $latency = (int) $log->latency_ms;
                $daily[$day]['latency_samples'][] = $latency;
                $endpoint = (string) ($log->endpoint ?? 'unknown');
                $endpointLatencies[$endpoint] ??= [];
                $endpointLatencies[$endpoint][] = $latency;
            }
        }

        ksort($daily);
        $dailyList = [];
        foreach ($daily as $item) {
            $samples = $item['latency_samples'];
            $avg = count($samples) > 0 ? (int) round(array_sum($samples) / count($samples)) : 0;
            unset($item['latency_samples']);
            $item['avg_latency_ms'] = $avg;
            $dailyList[] = $item;
        }

        $latencyByEndpoint = collect($endpointLatencies)
            ->map(function (array $samples, string $endpoint) {
                sort($samples);
                return [
                    'endpoint' => $endpoint,
                    'p95_latency_ms' => $this->percentile($samples, 0.95),
                    'avg_latency_ms' => (int) round(array_sum($samples) / max(1, count($samples))),
                ];
            })
            ->values()
            ->all();

        $queueRows = AiTask::query()
            ->where('company_id', $company->id)
            ->whereBetween('created_at', [$from, $to])
            ->get(['status', 'created_at', 'started_at', 'finished_at']);
        $queueStats = [
            'queued' => 0,
            'processing' => 0,
            'completed' => 0,
            'failed' => 0,
            'avg_duration_ms' => 0,
        ];
        $durations = [];
        foreach ($queueRows as $row) {
            $status = (string) ($row->status ?? 'queued');
            if (array_key_exists($status, $queueStats)) {
                $queueStats[$status]++;
            }
            if ($row->started_at && $row->finished_at) {
                $durations[] = (int) $row->finished_at->diffInMilliseconds($row->started_at);
            }
        }
        if (! empty($durations)) {
            $queueStats['avg_duration_ms'] = (int) round(array_sum($durations) / count($durations));
        }

        $today = now()->toDateString();
        $todayPoint = collect($dailyList)->firstWhere('date', $today);
        $todayRequests = (int) ($todayPoint['requests'] ?? 0);
        $todayErrors = (int) ($todayPoint['errors'] ?? 0);
        $todayErrorRate = $todayRequests > 0 ? round(($todayErrors / $todayRequests) * 100, 2) : 0;

        $allLatencies = [];
        foreach ($endpointLatencies as $samples) {
            foreach ($samples as $sample) {
                $allLatencies[] = (int) $sample;
            }
        }
        sort($allLatencies);
        $p95Overall = $this->percentile($allLatencies, 0.95);

        $policy = [
            'error_rate_threshold' => (float) ($company->ai_alert_error_rate_threshold ?? 5.0),
            'p95_latency_ms_threshold' => (int) ($company->ai_alert_p95_latency_ms_threshold ?? 2500),
            'queue_failure_threshold' => (int) ($company->ai_alert_queue_failure_threshold ?? 3),
        ];
        $alerts = [];
        if ($todayErrorRate > $policy['error_rate_threshold']) {
            $alerts[] = [
                'code' => 'high_error_rate',
                'level' => 'warning',
                'value' => $todayErrorRate,
                'threshold' => $policy['error_rate_threshold'],
                'message' => 'Today error rate exceeded configured threshold',
            ];
        }
        if ($p95Overall > $policy['p95_latency_ms_threshold']) {
            $alerts[] = [
                'code' => 'high_p95_latency',
                'level' => 'warning',
                'value' => $p95Overall,
                'threshold' => $policy['p95_latency_ms_threshold'],
                'message' => 'Overall p95 latency exceeded configured threshold',
            ];
        }
        if ((int) $queueStats['failed'] > $policy['queue_failure_threshold']) {
            $alerts[] = [
                'code' => 'queue_failures',
                'level' => 'critical',
                'value' => (int) $queueStats['failed'],
                'threshold' => $policy['queue_failure_threshold'],
                'message' => 'Queue failures exceeded configured threshold',
            ];
        }

        return response()->json([
            'data' => [
                'range_days' => $days,
                'daily' => $dailyList,
                'latency_by_endpoint' => $latencyByEndpoint,
                'queue' => $queueStats,
                'blocked' => $blockedCounts,
                'alerts' => $alerts,
                'policies' => $policy,
            ],
        ]);
    }

    public function canary(Request $request)
    {
        $company = Company::query()->find($request->user()->company_id);
        if (! $company) {
            return response()->json(['message' => 'Company not found'], 404);
        }

        $days = max(1, min(90, (int) $request->query('days', 14)));
        $from = now()->startOfDay()->subDays($days - 1);
        $to = now()->endOfDay();

        $logs = AiUsageLog::query()
            ->where('company_id', $company->id)
            ->whereBetween('created_at', [$from, $to])
            ->whereNotNull('provider')
            ->get(['provider', 'model', 'status', 'latency_ms', 'prompt_tokens', 'completion_tokens']);

        $groups = [];
        foreach ($logs as $log) {
            $provider = (string) ($log->provider ?? 'unknown');
            $model = (string) ($log->model ?? 'unknown');
            $key = "{$provider}:{$model}";
            if (! isset($groups[$key])) {
                $groups[$key] = [
                    'provider' => $provider,
                    'model' => $model,
                    'requests' => 0,
                    'success' => 0,
                    'error' => 0,
                    'blocked' => 0,
                    'latency_sum' => 0,
                    'latency_count' => 0,
                    'cost_sum' => 0.0,
                ];
            }

            $groups[$key]['requests']++;
            $status = (string) ($log->status ?? 'success');
            if ($status === 'success') {
                $groups[$key]['success']++;
            } elseif ($status === 'error') {
                $groups[$key]['error']++;
            } elseif (str_starts_with($status, 'blocked_')) {
                $groups[$key]['blocked']++;
            }

            if ($log->latency_ms !== null && $log->latency_ms > 0) {
                $groups[$key]['latency_sum'] += (int) $log->latency_ms;
                $groups[$key]['latency_count']++;
            }
            $groups[$key]['cost_sum'] += $this->estimateCostUsd(
                provider: $provider,
                model: $model,
                promptTokens: (int) ($log->prompt_tokens ?? 0),
                completionTokens: (int) ($log->completion_tokens ?? 0),
            );
        }

        $variants = collect($groups)
            ->map(function (array $row) {
                $requests = max(1, (int) $row['requests']);
                $successRate = round(((int) $row['success'] / $requests) * 100, 2);
                $avgLatency = (int) ($row['latency_count'] > 0
                    ? round((int) $row['latency_sum'] / (int) $row['latency_count'])
                    : 0);
                $avgCost = round((float) $row['cost_sum'] / $requests, 6);

                return [
                    'provider' => (string) $row['provider'],
                    'model' => (string) $row['model'],
                    'requests' => (int) $row['requests'],
                    'success' => (int) $row['success'],
                    'error' => (int) $row['error'],
                    'blocked' => (int) $row['blocked'],
                    'success_rate_percent' => $successRate,
                    'avg_latency_ms' => $avgLatency,
                    'avg_cost_usd' => $avgCost,
                ];
            })
            ->sortByDesc('success_rate_percent')
            ->sortBy('avg_latency_ms')
            ->values()
            ->all();

        return response()->json([
            'data' => [
                'range_days' => $days,
                'variants' => $variants,
                'recommended' => $variants[0] ?? null,
            ],
        ]);
    }

    public function incidentPlaybooks(Request $request)
    {
        $company = Company::query()->find($request->user()->company_id);
        if (! $company) {
            return response()->json(['message' => 'Company not found'], 404);
        }
        $days = max(1, min(90, (int) $request->query('days', 14)));
        $snapshot = $this->computeAlertSnapshot($company, $days);

        $runbooks = $this->resolveRunbookLinks($company);
        $playbooks = [
            [
                'id' => 'high_error_rate',
                'title' => 'High Error-Rate Response',
                'actions' => ['tighten_safety', 'reduce_rollout_50', 'switch_provider_openai'],
                'runbook_url' => $runbooks['high_error_rate'] ?? $runbooks['default'] ?? null,
            ],
            [
                'id' => 'high_p95_latency',
                'title' => 'High Latency Response',
                'actions' => ['switch_provider_gemini', 'reduce_rollout_50'],
                'runbook_url' => $runbooks['high_p95_latency'] ?? $runbooks['default'] ?? null,
            ],
            [
                'id' => 'queue_failures',
                'title' => 'Queue Failure Response',
                'actions' => ['disable_recruitment_ai', 'reduce_rollout_50'],
                'runbook_url' => $runbooks['queue_failures'] ?? $runbooks['default'] ?? null,
            ],
        ];

        return response()->json([
            'data' => [
                'alerts' => $snapshot['alerts'],
                'policies' => $snapshot['policy'],
                'playbooks' => $playbooks,
                'runbook_links' => $runbooks,
            ],
        ]);
    }

    public function applyRemediation(Request $request)
    {
        $validated = $request->validate([
            'action_id' => 'required|in:tighten_safety,reduce_rollout_50,disable_recruitment_ai,switch_provider_openai,switch_provider_gemini',
            'dry_run' => 'nullable|boolean',
        ]);
        $user = $request->user();
        $company = Company::query()->find($user->company_id);
        if (! $company) {
            return response()->json(['message' => 'Company not found'], 404);
        }

        $actionId = (string) $validated['action_id'];
        $dryRun = (bool) ($validated['dry_run'] ?? false);
        $before = $this->companyAiState($company);
        $after = $before;

        $this->applyRemediationAction($after, $actionId);
        if (! $dryRun) {
            $company->fill($after);
            $company->save();
        }

        $this->aiAuditService->log(
            companyId: (int) $company->id,
            userId: (int) $user->id,
            eventType: 'ai_remediation_applied',
            severity: 'warning',
            endpoint: 'ai/remediation/apply',
            context: [
                'action_id' => $actionId,
                'dry_run' => $dryRun,
                'before' => $before,
                'after' => $after,
            ],
        );

        return response()->json([
            'data' => [
                'action_id' => $actionId,
                'dry_run' => $dryRun,
                'before' => $before,
                'after' => $after,
            ],
        ]);
    }

    public function autoRemediate(Request $request)
    {
        $validated = $request->validate([
            'days' => 'nullable|integer|min:1|max:90',
            'dry_run' => 'nullable|boolean',
        ]);
        $user = $request->user();
        $company = Company::query()->find($user->company_id);
        if (! $company) {
            return response()->json(['message' => 'Company not found'], 404);
        }
        $days = (int) ($validated['days'] ?? 14);
        $dryRun = (bool) ($validated['dry_run'] ?? true);
        $snapshot = $this->computeAlertSnapshot($company, $days);
        $alerts = $snapshot['alerts'];

        $actions = [];
        foreach ($alerts as $alert) {
            $code = (string) ($alert['code'] ?? '');
            if ($code === 'high_error_rate') {
                $actions[] = 'tighten_safety';
                $actions[] = 'reduce_rollout_50';
            } elseif ($code === 'high_p95_latency') {
                $actions[] = $company->ai_provider === 'openai'
                    ? 'switch_provider_gemini'
                    : 'switch_provider_openai';
            } elseif ($code === 'queue_failures') {
                $actions[] = 'disable_recruitment_ai';
            }
        }
        $actions = array_values(array_unique($actions));

        $before = $this->companyAiState($company);
        $after = $before;
        foreach ($actions as $actionId) {
            $this->applyRemediationAction($after, $actionId);
        }
        if (! $dryRun && ! empty($actions)) {
            $company->fill($after);
            $company->save();
        }

        $this->aiAuditService->log(
            companyId: (int) $company->id,
            userId: (int) $user->id,
            eventType: 'ai_auto_remediation_run',
            severity: empty($actions) ? 'info' : 'warning',
            endpoint: 'ai/remediation/auto',
            context: [
                'days' => $days,
                'dry_run' => $dryRun,
                'actions' => $actions,
                'alerts' => $alerts,
            ],
        );

        return response()->json([
            'data' => [
                'dry_run' => $dryRun,
                'days' => $days,
                'actions' => $actions,
                'alerts' => $alerts,
                'before' => $before,
                'after' => $after,
            ],
        ]);
    }

    public function sloReport(Request $request)
    {
        $user = $request->user();
        $company = Company::query()->find($user->company_id);
        if (! $company) {
            return response()->json(['message' => 'Company not found'], 404);
        }

        $targetSuccessRate = (float) ($company->ai_slo_target_success_rate ?? 99.5);
        $burnRateThreshold = (float) ($company->ai_burn_rate_alert_threshold ?? 2.0);
        $errorBudgetPercent = max(0.01, 100 - $targetSuccessRate);

        $now = now();
        $lastHour = $this->computeWindowStats(
            companyId: (int) $company->id,
            from: $now->copy()->subHour(),
            to: $now,
        );
        $lastDay = $this->computeWindowStats(
            companyId: (int) $company->id,
            from: $now->copy()->subDay(),
            to: $now,
        );

        $burn1h = round(($lastHour['error_rate_percent'] / $errorBudgetPercent), 2);
        $burn24h = round(($lastDay['error_rate_percent'] / $errorBudgetPercent), 2);
        $alerts = [];
        if ($burn1h > $burnRateThreshold) {
            $alerts[] = [
                'code' => 'slo_burn_rate_1h',
                'level' => 'critical',
                'value' => $burn1h,
                'threshold' => $burnRateThreshold,
                'message' => '1h SLO burn-rate exceeded threshold',
            ];
        }
        if ($burn24h > $burnRateThreshold) {
            $alerts[] = [
                'code' => 'slo_burn_rate_24h',
                'level' => 'warning',
                'value' => $burn24h,
                'threshold' => $burnRateThreshold,
                'message' => '24h SLO burn-rate exceeded threshold',
            ];
        }

        $autoDispatch = $request->boolean('dispatch', false);
        $autoDispatchResult = null;
        if ($autoDispatch && ! empty($alerts)) {
            $first = $alerts[0];
            $alertCode = (string) ($first['code'] ?? 'slo_burn_rate_24h');
            $severity = (string) ($first['level'] ?? 'warning');
            $channels = is_array($company->ai_alert_channels) ? array_values($company->ai_alert_channels) : ['in_app'];
            $level = $this->selectEscalationLevel($alertCode, $severity);
            $matrix = $this->resolveEscalationMatrix($company);
            $recipients = (array) ($matrix[$level]['recipients'] ?? []);
            $policy = (string) ($matrix[$level]['policy'] ?? 'notify_now');
            $queued = $this->aiEscalationService->queueNotifications(
                company: $company,
                triggeredByUserId: (int) $user->id,
                alertCode: $alertCode,
                severity: $severity,
                level: $level,
                policy: $policy,
                message: "SLO alert auto-escalation for {$alertCode}",
                channels: $channels,
                recipients: $recipients,
            );
            $autoDispatchResult = [
                'alert_code' => $alertCode,
                'severity' => $severity,
                'queued_notifications' => count($queued),
            ];
        }

        return response()->json([
            'data' => [
                'slo_target_success_rate' => $targetSuccessRate,
                'error_budget_percent' => round($errorBudgetPercent, 2),
                'burn_rate_threshold' => $burnRateThreshold,
                'windows' => [
                    'last_1h' => array_merge($lastHour, ['burn_rate' => $burn1h]),
                    'last_24h' => array_merge($lastDay, ['burn_rate' => $burn24h]),
                ],
                'alerts' => $alerts,
                'escalation_recommendation' => [
                    'level' => ! empty($alerts) ? $this->selectEscalationLevel(
                        alertCode: (string) ($alerts[0]['code'] ?? 'slo_burn_rate_24h'),
                        severity: (string) ($alerts[0]['level'] ?? 'warning'),
                    ) : 'none',
                    'channels' => is_array($company->ai_alert_channels) ? array_values($company->ai_alert_channels) : ['in_app'],
                ],
                'auto_dispatch' => $autoDispatchResult,
            ],
        ]);
    }

    public function costAnomalies(Request $request)
    {
        $validated = $request->validate([
            'days' => 'nullable|integer|min:14|max:90',
        ]);
        $company = Company::query()->find($request->user()->company_id);
        if (! $company) {
            return response()->json(['message' => 'Company not found'], 404);
        }

        $days = (int) ($validated['days'] ?? 35);
        $multiplier = (float) ($company->ai_cost_anomaly_multiplier ?? 2.0);
        $from = now()->startOfDay()->subDays($days - 1);
        $to = now()->endOfDay();

        $logs = AiUsageLog::query()
            ->where('company_id', $company->id)
            ->whereBetween('created_at', [$from, $to])
            ->get(['provider', 'model', 'prompt_tokens', 'completion_tokens', 'created_at']);

        $dailyCost = [];
        foreach ($logs as $log) {
            $day = $log->created_at?->toDateString() ?? now()->toDateString();
            $cost = $this->estimateCostUsd(
                provider: (string) ($log->provider ?? ''),
                model: (string) ($log->model ?? ''),
                promptTokens: (int) ($log->prompt_tokens ?? 0),
                completionTokens: (int) ($log->completion_tokens ?? 0),
            );
            $dailyCost[$day] = round((float) ($dailyCost[$day] ?? 0.0) + $cost, 6);
        }

        $today = now()->toDateString();
        $todayCost = (float) ($dailyCost[$today] ?? 0.0);
        $trailingValues = [];
        for ($i = 1; $i <= 7; $i++) {
            $d = now()->copy()->subDays($i)->toDateString();
            $trailingValues[] = (float) ($dailyCost[$d] ?? 0.0);
        }
        $trailingAvg = count($trailingValues) > 0 ? (array_sum($trailingValues) / count($trailingValues)) : 0.0;
        $dailyThreshold = $trailingAvg * $multiplier;
        $dailyAnomaly = $trailingAvg > 0 && $todayCost > $dailyThreshold;

        $currentWeekStart = now()->startOfWeek();
        $currentWeekValues = [];
        for ($d = $currentWeekStart->copy(); $d->lte(now()); $d->addDay()) {
            $currentWeekValues[] = (float) ($dailyCost[$d->toDateString()] ?? 0.0);
        }
        $currentWeekAvg = count($currentWeekValues) > 0 ? (array_sum($currentWeekValues) / count($currentWeekValues)) : 0.0;

        $prevWeeksValues = [];
        for ($i = 7; $i <= 34; $i++) {
            $d = now()->copy()->subDays($i)->toDateString();
            $prevWeeksValues[] = (float) ($dailyCost[$d] ?? 0.0);
        }
        $prevWeeksAvg = count($prevWeeksValues) > 0 ? (array_sum($prevWeeksValues) / count($prevWeeksValues)) : 0.0;
        $weeklyThreshold = $prevWeeksAvg * $multiplier;
        $weeklyAnomaly = $prevWeeksAvg > 0 && $currentWeekAvg > $weeklyThreshold;

        $recommendations = [];
        if ($dailyAnomaly || $weeklyAnomaly) {
            $recommendations[] = 'Run canary and switch to lower-cost model if quality is stable';
            $recommendations[] = 'Reduce rollout percentage temporarily for high-cost AI features';
            $recommendations[] = 'Tighten prompt templates to reduce output token size';
        }

        ksort($dailyCost);
        $series = collect($dailyCost)
            ->map(fn (float $cost, string $date) => ['date' => $date, 'cost_usd' => round($cost, 4)])
            ->values()
            ->all();

        return response()->json([
            'data' => [
                'range_days' => $days,
                'multiplier' => $multiplier,
                'daily' => [
                    'today_cost_usd' => round($todayCost, 4),
                    'trailing_7d_avg_usd' => round($trailingAvg, 4),
                    'threshold_usd' => round($dailyThreshold, 4),
                    'is_anomaly' => $dailyAnomaly,
                ],
                'weekly' => [
                    'current_week_avg_daily_cost_usd' => round($currentWeekAvg, 4),
                    'prev_4w_avg_daily_cost_usd' => round($prevWeeksAvg, 4),
                    'threshold_usd' => round($weeklyThreshold, 4),
                    'is_anomaly' => $weeklyAnomaly,
                ],
                'recommendations' => $recommendations,
                'series' => $series,
            ],
        ]);
    }

    public function dispatchEscalation(Request $request)
    {
        $validated = $request->validate([
            'alert_code' => 'required|string|max:100',
            'severity' => 'nullable|in:info,warning,critical',
            'channels' => 'nullable|array',
            'channels.*' => 'string|in:email,slack,in_app',
            'message' => 'nullable|string|max:500',
            'dry_run' => 'nullable|boolean',
        ]);
        $user = $request->user();
        $company = Company::query()->find($user->company_id);
        if (! $company) {
            return response()->json(['message' => 'Company not found'], 404);
        }

        $alertCode = (string) $validated['alert_code'];
        $severity = (string) ($validated['severity'] ?? 'warning');
        $dryRun = (bool) ($validated['dry_run'] ?? true);
        $channels = is_array($validated['channels'] ?? null)
            ? array_values($validated['channels'])
            : (is_array($company->ai_alert_channels) ? array_values($company->ai_alert_channels) : ['in_app']);

        $level = $this->selectEscalationLevel($alertCode, $severity);
        $matrix = $this->resolveEscalationMatrix($company);
        $recipients = (array) ($matrix[$level]['recipients'] ?? []);
        $policy = (string) ($matrix[$level]['policy'] ?? 'notify_now');

        $payload = [
            'company_id' => (int) $company->id,
            'alert_code' => $alertCode,
            'severity' => $severity,
            'level' => $level,
            'channels' => $channels,
            'recipients' => $recipients,
            'policy' => $policy,
            'message' => (string) ($validated['message'] ?? "Escalation triggered for {$alertCode}"),
            'runbook_url' => $this->resolveRunbookLinks($company)[$alertCode]
                ?? $this->resolveRunbookLinks($company)['default']
                ?? null,
            'triggered_at' => now()->toIso8601String(),
            'dry_run' => $dryRun,
        ];

        $queued = [];
        if (! $dryRun) {
            $queued = $this->aiEscalationService->queueNotifications(
                company: $company,
                triggeredByUserId: (int) $user->id,
                alertCode: $alertCode,
                severity: $severity,
                level: $level,
                policy: $policy,
                message: (string) $payload['message'],
                channels: $channels,
                recipients: $recipients,
            );
        }

        $this->aiAuditService->log(
            companyId: (int) $company->id,
            userId: (int) $user->id,
            eventType: 'ai_escalation_dispatched',
            severity: $severity,
            endpoint: 'ai/escalation/dispatch',
            context: $payload,
        );

        return response()->json([
            'data' => array_merge($payload, [
                'queued_notifications' => count($queued),
                'notification_ids' => collect($queued)->map(fn (AiEscalationNotification $n) => (int) $n->id)->values()->all(),
            ]),
        ]);
    }

    public function escalationNotifications(Request $request)
    {
        $validated = $request->validate([
            'limit' => 'nullable|integer|min:10|max:200',
        ]);
        $limit = (int) ($validated['limit'] ?? 50);
        $companyId = (int) $request->user()->company_id;

        $rows = AiEscalationNotification::query()
            ->where('company_id', $companyId)
            ->orderByDesc('id')
            ->limit($limit)
            ->get();
        $statusCounts = AiEscalationNotification::query()
            ->where('company_id', $companyId)
            ->select('status', DB::raw('COUNT(*) as total'))
            ->groupBy('status')
            ->get()
            ->mapWithKeys(fn ($r) => [(string) $r->status => (int) $r->total])
            ->all();

        return response()->json([
            'data' => [
                'status_counts' => $statusCounts,
                'items' => $rows->map(fn (AiEscalationNotification $row) => [
                    'id' => (int) $row->id,
                    'alert_code' => (string) $row->alert_code,
                    'severity' => (string) $row->severity,
                    'level' => (string) $row->level,
                    'channel' => (string) $row->channel,
                    'recipient' => $row->recipient,
                    'status' => (string) $row->status,
                    'attempts' => (int) $row->attempts,
                    'max_attempts' => (int) $row->max_attempts,
                    'last_error' => $row->last_error,
                    'scheduled_for' => $row->scheduled_for?->toIso8601String(),
                    'sent_at' => $row->sent_at?->toIso8601String(),
                    'failed_at' => $row->failed_at?->toIso8601String(),
                    'created_at' => $row->created_at?->toIso8601String(),
                ])->values()->all(),
            ],
        ]);
    }

    public function escalationRunbooks(Request $request)
    {
        $company = Company::query()->find($request->user()->company_id);
        if (! $company) {
            return response()->json(['message' => 'Company not found'], 404);
        }

        return response()->json([
            'data' => [
                'runbook_links' => $this->resolveRunbookLinks($company),
                'silence_windows' => $this->resolveSilenceWindows($company),
                'digest' => [
                    'enabled' => (bool) ($company->ai_digest_enabled ?? true),
                    'window_minutes' => (int) ($company->ai_digest_window_minutes ?? 60),
                ],
            ],
        ]);
    }

    public function runEscalationDigest(Request $request)
    {
        $validated = $request->validate([
            'window_minutes' => 'nullable|integer|min:5|max:1440',
            'queue' => 'nullable|boolean',
            'dry_run' => 'nullable|boolean',
        ]);
        $user = $request->user();
        $company = Company::query()->find($user->company_id);
        if (! $company) {
            return response()->json(['message' => 'Company not found'], 404);
        }

        $windowMinutes = (int) ($validated['window_minutes'] ?? $company->ai_digest_window_minutes ?? 60);
        $queue = (bool) ($validated['queue'] ?? true);
        $dryRun = (bool) ($validated['dry_run'] ?? false);

        if ($queue && ! $dryRun) {
            dispatch(new ProcessAiEscalationDigest(
                companyId: (int) $company->id,
                triggeredByUserId: (int) $user->id,
                windowMinutes: $windowMinutes,
            ));

            return response()->json([
                'data' => [
                    'queued' => true,
                    'window_minutes' => $windowMinutes,
                ],
            ]);
        }

        $result = $this->aiEscalationService->queueDigestForCompany(
            company: $company,
            triggeredByUserId: (int) $user->id,
            windowMinutes: $windowMinutes,
            dryRun: $dryRun,
        );

        return response()->json(['data' => array_merge(['queued' => false], $result)]);
    }

    public function queueHealthEvents(Request $request)
    {
        $validated = $request->validate([
            'limit' => 'nullable|integer|min:5|max:200',
            'window_minutes' => 'nullable|integer|min:5|max:10080',
        ]);
        $companyId = (int) $request->user()->company_id;
        $limit = (int) ($validated['limit'] ?? 30);
        $windowMinutes = (int) ($validated['window_minutes'] ?? 1440);
        $from = now()->subMinutes($windowMinutes);

        $rows = AiAuditEvent::query()
            ->where('company_id', $companyId)
            ->where('event_type', 'ai_queue_failures_alerted')
            ->where('created_at', '>=', $from)
            ->orderByDesc('id')
            ->limit($limit)
            ->get();
        $company = Company::query()->find($companyId);
        $runbooks = $company ? $this->resolveRunbookLinks($company) : ['default' => 'https://runbooks.example.com/ai/general'];

        $latest = $rows->map(function (AiAuditEvent $row) use ($runbooks) {
            $ctx = is_array($row->context) ? $row->context : [];
            $alertCode = (string) ($ctx['alert_code'] ?? 'queue_failures_runtime');
            $runbookUrl = $runbooks[$alertCode] ?? $runbooks['queue_failures'] ?? $runbooks['default'] ?? null;

            return [
                'id' => (int) $row->id,
                'event_at' => $row->event_at?->toIso8601String() ?? $row->created_at?->toIso8601String(),
                'alert_code' => $alertCode,
                'severity' => (string) $row->severity,
                'failed_total' => (int) ($ctx['failed_total'] ?? 0),
                'failed_ai_tasks' => (int) ($ctx['failed_ai_tasks'] ?? 0),
                'failed_escalation_notifications' => (int) ($ctx['failed_escalation_notifications'] ?? 0),
                'threshold' => (int) ($ctx['threshold'] ?? 0),
                'cooldown_minutes' => (int) ($ctx['cooldown_minutes'] ?? 0),
                'queued_notifications' => (int) ($ctx['queued_notifications'] ?? 0),
                'dry_run' => (bool) ($ctx['dry_run'] ?? false),
                'runbook_url' => is_string($runbookUrl) ? $runbookUrl : null,
            ];
        })->values()->all();

        $totals = [
            'alerts' => count($latest),
            'critical' => count(array_filter($latest, fn (array $x) => ($x['severity'] ?? 'info') === 'critical')),
            'warning' => count(array_filter($latest, fn (array $x) => ($x['severity'] ?? 'info') === 'warning')),
        ];

        return response()->json([
            'data' => [
                'window_minutes' => $windowMinutes,
                'totals' => $totals,
                'latest' => $latest,
            ],
        ]);
    }

    public function auditTrail(Request $request)
    {
        $validated = $request->validate([
            'limit' => 'nullable|integer|min:10|max:200',
            'event_type' => 'nullable|string|max:100',
        ]);
        $limit = (int) ($validated['limit'] ?? 80);
        $companyId = (int) $request->user()->company_id;

        $query = AiAuditEvent::query()
            ->where('company_id', $companyId)
            ->with(['user:id,name,email'])
            ->orderByDesc('id');
        if (! empty($validated['event_type'])) {
            $query->where('event_type', (string) $validated['event_type']);
        }
        $events = $query->limit($limit)->get();

        $timeline = $events->map(function (AiAuditEvent $event) {
            $context = is_array($event->context) ? $event->context : [];

            return [
                'id' => (int) $event->id,
                'event_type' => (string) $event->event_type,
                'severity' => (string) $event->severity,
                'endpoint' => $event->endpoint,
                'event_at' => $event->event_at?->toIso8601String(),
                'user' => $event->user ? [
                    'id' => (int) $event->user->id,
                    'name' => (string) $event->user->name,
                    'email' => (string) $event->user->email,
                ] : null,
                'context' => $context,
                'diff' => $this->buildDiffFromContext($context),
            ];
        })->values()->all();

        return response()->json([
            'data' => [
                'total' => count($timeline),
                'timeline' => $timeline,
            ],
        ]);
    }

    private function resolveConversation(
        int $companyId,
        int $userId,
        ?int $conversationId,
        string $languageCode,
    ): AiConversation {
        if ($conversationId !== null) {
            $found = AiConversation::query()
                ->where('company_id', $companyId)
                ->where('id', $conversationId)
                ->first();
            if ($found) {
                return $found;
            }
        }

        return AiConversation::query()->create([
            'company_id' => $companyId,
            'user_id' => $userId,
            'language_code' => $languageCode,
            'provider' => null,
            'model' => null,
            'last_message_at' => Carbon::now(),
        ]);
    }

    private function buildJobDescriptionPrompt(
        string $languageCode,
        string $title,
        string $department,
        string $location,
        string $employmentType,
        string $requirements,
        string $responsibilities,
        string $tone,
    ): string {
        $ar = str_starts_with($languageCode, 'ar');
        if ($ar) {
            return "أنشئ وصفاً وظيفياً احترافياً باللغة العربية.\n"
                ."المسمى: {$title}\n"
                ."القسم: ".($department !== '' ? $department : 'غير محدد')."\n"
                ."الموقع: ".($location !== '' ? $location : 'غير محدد')."\n"
                ."نوع التوظيف: ".($employmentType !== '' ? $employmentType : 'دوام كامل')."\n"
                ."النبرة: {$tone}\n"
                ."المتطلبات: ".($requirements !== '' ? $requirements : 'غير محددة')."\n"
                ."المهام: ".($responsibilities !== '' ? $responsibilities : 'غير محددة')."\n"
                ."النتيجة المطلوبة: أقسام واضحة تشمل نبذة، المسؤوليات، المتطلبات، المزايا، وتعليمات التقديم.";
        }

        return "Generate a professional job description in English.\n"
            ."Title: {$title}\n"
            ."Department: ".($department !== '' ? $department : 'Not specified')."\n"
            ."Location: ".($location !== '' ? $location : 'Not specified')."\n"
            ."Employment type: ".($employmentType !== '' ? $employmentType : 'Full-time')."\n"
            ."Tone: {$tone}\n"
            ."Requirements: ".($requirements !== '' ? $requirements : 'Not specified')."\n"
            ."Responsibilities: ".($responsibilities !== '' ? $responsibilities : 'Not specified')."\n"
            ."Return a structured draft with sections: Overview, Responsibilities, Requirements, Benefits, and Apply instructions.";
    }

    private function buildCommunicationPrompt(
        string $languageCode,
        string $type,
        string $purpose,
        string $recipientName,
        string $employeeName,
        string $department,
        string $tone,
        string $keyPoints,
    ): string {
        $ar = str_starts_with($languageCode, 'ar');
        if ($ar) {
            return "أنشئ ".($type === 'letter' ? 'خطاباً' : 'بريداً إلكترونياً')." باللغة العربية بنبرة {$tone}.\n"
                ."الغرض: {$purpose}\n"
                ."اسم المستلم: ".($recipientName !== '' ? $recipientName : 'غير محدد')."\n"
                ."اسم الموظف: ".($employeeName !== '' ? $employeeName : 'غير محدد')."\n"
                ."القسم: ".($department !== '' ? $department : 'غير محدد')."\n"
                ."نقاط أساسية: ".($keyPoints !== '' ? $keyPoints : 'لا توجد')."\n"
                ."النتيجة: اكتب Subject واضح ثم Body منظم وجاهز للإرسال.";
        }

        return "Generate an HR ".($type === 'letter' ? 'letter' : 'email')." in English with {$tone} tone.\n"
            ."Purpose: {$purpose}\n"
            ."Recipient: ".($recipientName !== '' ? $recipientName : 'Not specified')."\n"
            ."Employee name: ".($employeeName !== '' ? $employeeName : 'Not specified')."\n"
            ."Department: ".($department !== '' ? $department : 'Not specified')."\n"
            ."Key points: ".($keyPoints !== '' ? $keyPoints : 'None')."\n"
            ."Output format: include a concise Subject and a ready-to-send Body.";
    }

    private function logUsage(
        int $companyId,
        int $userId,
        ?int $conversationId,
        string $endpoint,
        string $provider,
        ?string $model,
        int $latencyMs,
        ?int $promptTokens,
        ?int $completionTokens,
        ?int $totalTokens,
        string $status,
        ?string $errorMessage,
    ): void {
        AiUsageLog::query()->create([
            'company_id' => $companyId,
            'user_id' => $userId,
            'conversation_id' => $conversationId,
            'endpoint' => $endpoint,
            'provider' => $provider,
            'model' => $model,
            'latency_ms' => $latencyMs,
            'prompt_tokens' => $promptTokens,
            'completion_tokens' => $completionTokens,
            'total_tokens' => $totalTokens,
            'status' => $status,
            'error_message' => $errorMessage,
        ]);
    }

    private function estimateCostUsd(
        string $provider,
        string $model,
        int $promptTokens,
        int $completionTokens,
    ): float {
        $pricing = config('services.ai.pricing', []);
        $fallback = [
            'input_per_million' => 0.15,
            'output_per_million' => 0.6,
        ];

        $providerPricing = is_array($pricing[$provider] ?? null) ? $pricing[$provider] : [];
        $modelPricing = is_array($providerPricing[$model] ?? null) ? $providerPricing[$model] : [];
        $rates = array_merge($fallback, $modelPricing);

        $inputPerMillion = (float) ($rates['input_per_million'] ?? $fallback['input_per_million']);
        $outputPerMillion = (float) ($rates['output_per_million'] ?? $fallback['output_per_million']);

        $inputCost = ($promptTokens / 1_000_000) * $inputPerMillion;
        $outputCost = ($completionTokens / 1_000_000) * $outputPerMillion;

        return max(0, $inputCost + $outputCost);
    }

    private function defaultSystemPromptForFeature(string $featureKey, string $languageCode): string
    {
        $ar = str_starts_with($languageCode, 'ar');

        return match ($featureKey) {
            'job_description' => $ar
                ? 'أنت خبير موارد بشرية. أنشئ وصفاً وظيفياً احترافياً واضحاً ومختصراً.'
                : 'You are an HR expert. Generate clear and professional job descriptions.',
            'communication' => $ar
                ? 'أنت كاتب اتصالات موارد بشرية. أنشئ رسائل رسمية دقيقة وجاهزة للإرسال.'
                : 'You are an HR communications writer. Generate concise and ready-to-send messages.',
            default => $ar
                ? 'أنت مساعد موارد بشرية لمنصة HRM. أعطِ إجابات عملية وقصيرة.'
                : 'You are an HR assistant for an HRM platform. Provide practical concise answers.',
        };
    }

    /**
     * @return array{
     *   alerts:array<int,array<string,mixed>>,
     *   policy:array<string,mixed>
     * }
     */
    private function computeAlertSnapshot(Company $company, int $days): array
    {
        $from = now()->startOfDay()->subDays($days - 1);
        $to = now()->endOfDay();

        $logs = AiUsageLog::query()
            ->where('company_id', $company->id)
            ->whereBetween('created_at', [$from, $to])
            ->get(['status', 'latency_ms', 'created_at']);
        $today = now()->toDateString();
        $todayRequests = 0;
        $todayErrors = 0;
        $allLatencies = [];
        foreach ($logs as $log) {
            $day = $log->created_at?->toDateString();
            if ($day === $today) {
                $todayRequests++;
                if ((string) $log->status === 'error') {
                    $todayErrors++;
                }
            }
            if ($log->latency_ms !== null && $log->latency_ms > 0) {
                $allLatencies[] = (int) $log->latency_ms;
            }
        }
        sort($allLatencies);
        $p95Overall = $this->percentile($allLatencies, 0.95);
        $todayErrorRate = $todayRequests > 0 ? round(($todayErrors / $todayRequests) * 100, 2) : 0;

        $queueFailures = (int) AiTask::query()
            ->where('company_id', $company->id)
            ->whereBetween('created_at', [$from, $to])
            ->where('status', 'failed')
            ->count();

        $policy = [
            'error_rate_threshold' => (float) ($company->ai_alert_error_rate_threshold ?? 5.0),
            'p95_latency_ms_threshold' => (int) ($company->ai_alert_p95_latency_ms_threshold ?? 2500),
            'queue_failure_threshold' => (int) ($company->ai_alert_queue_failure_threshold ?? 3),
        ];
        $alerts = [];
        if ($todayErrorRate > $policy['error_rate_threshold']) {
            $alerts[] = [
                'code' => 'high_error_rate',
                'level' => 'warning',
                'value' => $todayErrorRate,
                'threshold' => $policy['error_rate_threshold'],
            ];
        }
        if ($p95Overall > $policy['p95_latency_ms_threshold']) {
            $alerts[] = [
                'code' => 'high_p95_latency',
                'level' => 'warning',
                'value' => $p95Overall,
                'threshold' => $policy['p95_latency_ms_threshold'],
            ];
        }
        if ($queueFailures > $policy['queue_failure_threshold']) {
            $alerts[] = [
                'code' => 'queue_failures',
                'level' => 'critical',
                'value' => $queueFailures,
                'threshold' => $policy['queue_failure_threshold'],
            ];
        }

        return [
            'alerts' => $alerts,
            'policy' => $policy,
        ];
    }

    /**
     * @return array<string,mixed>
     */
    private function companyAiState(Company $company): array
    {
        $flags = is_array($company->ai_feature_flags) ? $company->ai_feature_flags : [];

        return [
            'ai_provider' => (string) ($company->ai_provider ?? 'openai'),
            'ai_safety_level' => (string) ($company->ai_safety_level ?? 'standard'),
            'ai_rollout_percentage' => (int) ($company->ai_rollout_percentage ?? 100),
            'ai_feature_flags' => $flags,
        ];
    }

    /**
     * @param  array<string,mixed>  $state
     */
    private function applyRemediationAction(array &$state, string $actionId): void
    {
        $flags = is_array($state['ai_feature_flags'] ?? null) ? $state['ai_feature_flags'] : [];

        if ($actionId === 'tighten_safety') {
            $state['ai_safety_level'] = 'strict';
        } elseif ($actionId === 'reduce_rollout_50') {
            $state['ai_rollout_percentage'] = min((int) ($state['ai_rollout_percentage'] ?? 100), 50);
        } elseif ($actionId === 'disable_recruitment_ai') {
            $flags['recruitment_parse'] = false;
            $flags['recruitment_match'] = false;
        } elseif ($actionId === 'switch_provider_openai') {
            $state['ai_provider'] = 'openai';
        } elseif ($actionId === 'switch_provider_gemini') {
            $state['ai_provider'] = 'gemini';
        }

        $state['ai_feature_flags'] = $flags;
    }

    /**
     * @return array{
     *   request_count:int,
     *   error_count:int,
     *   error_rate_percent:float,
     *   p95_latency_ms:int
     * }
     */
    private function computeWindowStats(int $companyId, Carbon $from, Carbon $to): array
    {
        $logs = AiUsageLog::query()
            ->where('company_id', $companyId)
            ->whereBetween('created_at', [$from, $to])
            ->get(['status', 'latency_ms']);

        $requestCount = $logs->count();
        $errorCount = $logs->where('status', 'error')->count();
        $errorRate = $requestCount > 0 ? round(($errorCount / $requestCount) * 100, 2) : 0.0;

        $latencies = $logs
            ->pluck('latency_ms')
            ->filter(fn ($v) => $v !== null && (int) $v > 0)
            ->map(fn ($v) => (int) $v)
            ->values()
            ->all();
        sort($latencies);

        return [
            'request_count' => (int) $requestCount,
            'error_count' => (int) $errorCount,
            'error_rate_percent' => (float) $errorRate,
            'p95_latency_ms' => $this->percentile($latencies, 0.95),
        ];
    }

    /**
     * @return array<string,array<string,mixed>>
     */
    private function resolveEscalationMatrix(Company $company): array
    {
        $custom = is_array($company->ai_escalation_matrix) ? $company->ai_escalation_matrix : [];

        $defaults = [
            'l1' => [
                'policy' => 'notify_in_5m',
                'recipients' => ['hr-oncall@company.local'],
            ],
            'l2' => [
                'policy' => 'notify_now',
                'recipients' => ['engineering-oncall@company.local', 'hr-manager@company.local'],
            ],
            'l3' => [
                'policy' => 'page_immediately',
                'recipients' => ['cto@company.local', 'security@company.local'],
            ],
        ];

        foreach ($custom as $level => $item) {
            if (! is_string($level) || ! is_array($item)) {
                continue;
            }
            if (array_key_exists($level, $defaults)) {
                $defaults[$level] = array_merge($defaults[$level], $item);
                if (! is_array($defaults[$level]['recipients'] ?? null)) {
                    $defaults[$level]['recipients'] = [];
                }
            }
        }

        return $defaults;
    }

    /**
     * @return array<string,string>
     */
    private function resolveRunbookLinks(Company $company): array
    {
        $links = is_array($company->ai_runbook_links) ? $company->ai_runbook_links : [];
        $defaults = [
            'high_error_rate' => 'https://runbooks.example.com/ai/high-error-rate',
            'high_p95_latency' => 'https://runbooks.example.com/ai/high-latency',
            'queue_failures' => 'https://runbooks.example.com/ai/queue-failures',
            'slo_burn_rate_1h' => 'https://runbooks.example.com/ai/slo-burn-rate',
            'slo_burn_rate_24h' => 'https://runbooks.example.com/ai/slo-burn-rate',
            'default' => 'https://runbooks.example.com/ai/general',
        ];

        foreach ($links as $key => $value) {
            if (is_string($key) && is_string($value) && trim($value) !== '') {
                $defaults[$key] = trim($value);
            }
        }

        return $defaults;
    }

    /**
     * @return array<int,array<string,mixed>>
     */
    private function resolveSilenceWindows(Company $company): array
    {
        $windows = is_array($company->ai_silence_windows) ? $company->ai_silence_windows : [];
        $items = [];
        foreach ($windows as $window) {
            if (! is_array($window)) {
                continue;
            }
            $items[] = [
                'name' => (string) ($window['name'] ?? 'window'),
                'days' => array_values(array_map('intval', is_array($window['days'] ?? null) ? $window['days'] : [])),
                'start' => (string) ($window['start'] ?? '00:00'),
                'end' => (string) ($window['end'] ?? '00:00'),
            ];
        }

        return $items;
    }

    private function selectEscalationLevel(string $alertCode, string $severity): string
    {
        if ($severity === 'critical') {
            return 'l3';
        }
        if ($alertCode === 'queue_failures' || $alertCode === 'slo_burn_rate_1h') {
            return 'l2';
        }

        return 'l1';
    }

    /**
     * @param  array<string,mixed>  $context
     * @return array<int,array<string,mixed>>
     */
    private function buildDiffFromContext(array $context): array
    {
        if (! is_array($context['before'] ?? null) || ! is_array($context['after'] ?? null)) {
            return [];
        }
        $before = (array) $context['before'];
        $after = (array) $context['after'];
        $keys = array_values(array_unique(array_merge(array_keys($before), array_keys($after))));
        $diff = [];
        foreach ($keys as $key) {
            $old = $before[$key] ?? null;
            $new = $after[$key] ?? null;
            if ($old !== $new) {
                $diff[] = [
                    'field' => (string) $key,
                    'before' => $old,
                    'after' => $new,
                ];
            }
        }

        return $diff;
    }

    private function percentile(array $sortedSamples, float $p): int
    {
        if (empty($sortedSamples)) {
            return 0;
        }
        $count = count($sortedSamples);
        $index = (int) ceil($p * $count) - 1;
        $index = max(0, min($count - 1, $index));
        return (int) $sortedSamples[$index];
    }
}
