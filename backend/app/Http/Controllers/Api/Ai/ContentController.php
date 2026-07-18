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

class ContentController extends BaseAiController
{
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

}
