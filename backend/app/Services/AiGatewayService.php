<?php

namespace App\Services;

use Illuminate\Support\Facades\Http;
use RuntimeException;

class AiGatewayService
{
    /**
     * @param  array<int, array{role:string,content:string}>  $history
     * @return array{
     *     content:string,
     *     provider:string,
     *     model:string,
     *     prompt_tokens:int|null,
     *     completion_tokens:int|null,
     *     total_tokens:int|null,
     *     metadata:array<string,mixed>
     * }
     */
    public function generateChatReply(
        string $message,
        string $languageCode,
        array $history = [],
        ?string $providerOverride = null,
        ?string $modelOverride = null,
        ?string $systemPromptOverride = null,
    ): array {
        $provider = $providerOverride ?: config('services.ai.default_provider', 'openai');
        $provider = in_array($provider, ['openai', 'gemini'], true) ? $provider : 'openai';

        return match ($provider) {
            'gemini' => $this->generateWithGemini($message, $languageCode, $history, $modelOverride, $systemPromptOverride),
            default => $this->generateWithOpenAi($message, $languageCode, $history, $modelOverride, $systemPromptOverride),
        };
    }

    /**
     * @param  array<int, array{role:string,content:string}>  $history
     * @return array{
     *     content:string,
     *     provider:string,
     *     model:string,
     *     prompt_tokens:int|null,
     *     completion_tokens:int|null,
     *     total_tokens:int|null,
     *     metadata:array<string,mixed>
     * }
     */
    private function generateWithOpenAi(
        string $message,
        string $languageCode,
        array $history,
        ?string $modelOverride,
        ?string $systemPromptOverride,
    ): array {
        $apiKey = (string) config('services.openai.key', '');
        $model = $modelOverride ?: (string) config('services.openai.model', 'gpt-4o-mini');

        if ($apiKey === '') {
            return $this->fallbackReply($message, $languageCode, 'openai', $model, 'missing_api_key');
        }

        $messages = [
            [
                'role' => 'system',
                'content' => $systemPromptOverride ?: $this->systemPrompt($languageCode),
            ],
        ];

        foreach ($history as $item) {
            $role = $item['role'] === 'assistant' ? 'assistant' : 'user';
            $messages[] = [
                'role' => $role,
                'content' => $item['content'],
            ];
        }

        $messages[] = [
            'role' => 'user',
            'content' => $message,
        ];

        $response = Http::timeout((int) config('services.ai.timeout_seconds', 25))
            ->withToken($apiKey)
            ->post('https://api.openai.com/v1/chat/completions', [
                'model' => $model,
                'messages' => $messages,
                'temperature' => 0.3,
            ]);

        if (! $response->successful()) {
            throw new RuntimeException('OpenAI request failed: '.$response->status().' '.$response->body());
        }

        $json = $response->json();
        $text = trim((string) data_get($json, 'choices.0.message.content', ''));
        if ($text === '') {
            throw new RuntimeException('OpenAI returned empty content');
        }

        $promptTokens = data_get($json, 'usage.prompt_tokens');
        $completionTokens = data_get($json, 'usage.completion_tokens');
        $totalTokens = data_get($json, 'usage.total_tokens');

        return [
            'content' => $text,
            'provider' => 'openai',
            'model' => $model,
            'prompt_tokens' => is_numeric($promptTokens) ? (int) $promptTokens : null,
            'completion_tokens' => is_numeric($completionTokens) ? (int) $completionTokens : null,
            'total_tokens' => is_numeric($totalTokens) ? (int) $totalTokens : null,
            'metadata' => ['source' => 'openai'],
        ];
    }

    /**
     * @param  array<int, array{role:string,content:string}>  $history
     * @return array{
     *     content:string,
     *     provider:string,
     *     model:string,
     *     prompt_tokens:int|null,
     *     completion_tokens:int|null,
     *     total_tokens:int|null,
     *     metadata:array<string,mixed>
     * }
     */
    private function generateWithGemini(
        string $message,
        string $languageCode,
        array $history,
        ?string $modelOverride,
        ?string $systemPromptOverride,
    ): array {
        $apiKey = (string) config('services.gemini.key', '');
        $model = $modelOverride ?: (string) config('services.gemini.model', 'gemini-1.5-flash');

        if ($apiKey === '') {
            return $this->fallbackReply($message, $languageCode, 'gemini', $model, 'missing_api_key');
        }

        $contents = [];
        foreach ($history as $item) {
            $role = $item['role'] === 'assistant' ? 'model' : 'user';
            $contents[] = [
                'role' => $role,
                'parts' => [
                    ['text' => $item['content']],
                ],
            ];
        }

        $contents[] = [
            'role' => 'user',
            'parts' => [
                ['text' => $message],
            ],
        ];

        $response = Http::timeout((int) config('services.ai.timeout_seconds', 25))
            ->post(
                "https://generativelanguage.googleapis.com/v1beta/models/{$model}:generateContent?key={$apiKey}",
                [
                    'system_instruction' => [
                        'parts' => [
                            ['text' => $systemPromptOverride ?: $this->systemPrompt($languageCode)],
                        ],
                    ],
                    'contents' => $contents,
                    'generationConfig' => [
                        'temperature' => 0.3,
                    ],
                ]
            );

        if (! $response->successful()) {
            throw new RuntimeException('Gemini request failed: '.$response->status().' '.$response->body());
        }

        $json = $response->json();
        $text = trim((string) data_get($json, 'candidates.0.content.parts.0.text', ''));
        if ($text === '') {
            throw new RuntimeException('Gemini returned empty content');
        }

        $promptTokens = data_get($json, 'usageMetadata.promptTokenCount');
        $completionTokens = data_get($json, 'usageMetadata.candidatesTokenCount');
        $totalTokens = data_get($json, 'usageMetadata.totalTokenCount');

        return [
            'content' => $text,
            'provider' => 'gemini',
            'model' => $model,
            'prompt_tokens' => is_numeric($promptTokens) ? (int) $promptTokens : null,
            'completion_tokens' => is_numeric($completionTokens) ? (int) $completionTokens : null,
            'total_tokens' => is_numeric($totalTokens) ? (int) $totalTokens : null,
            'metadata' => ['source' => 'gemini'],
        ];
    }

    /**
     * @return array{
     *     content:string,
     *     provider:string,
     *     model:string,
     *     prompt_tokens:int|null,
     *     completion_tokens:int|null,
     *     total_tokens:int|null,
     *     metadata:array<string,mixed>
     * }
     */
    private function fallbackReply(
        string $message,
        string $languageCode,
        string $provider,
        string $model,
        string $reason,
    ): array {
        $lower = mb_strtolower(trim($message));
        $ar = str_starts_with($languageCode, 'ar');

        $reply = $ar
            ? 'استلمت سؤالك وسأساعدك. يمكن الآن تفعيل مزوّد AI من إعدادات الخادم للحصول على إجابات أكثر ذكاءً.'
            : 'I received your request. Enable the AI provider on the server for richer answers.';

        if (str_contains($lower, 'leave') || str_contains($lower, 'إجاز')) {
            $reply = $ar
                ? 'بالنسبة للإجازات: يمكنني مساعدتك في معرفة الرصيد، نوع الإجازة المناسب، وخطوات التقديم.'
                : 'For leave management, I can help with balances, leave type guidance, and request steps.';
        } elseif (str_contains($lower, 'attendance') || str_contains($lower, 'حضور')) {
            $reply = $ar
                ? 'بالنسبة للحضور: أستطيع شرح سجل الحضور، حالات التأخير، وآلية تسجيل الدخول والخروج.'
                : 'For attendance, I can explain records, late status, and check-in/check-out flows.';
        }

        return [
            'content' => $reply,
            'provider' => $provider,
            'model' => $model,
            'prompt_tokens' => null,
            'completion_tokens' => null,
            'total_tokens' => null,
            'metadata' => ['source' => 'fallback', 'reason' => $reason],
        ];
    }

    private function systemPrompt(string $languageCode): string
    {
        $ar = str_starts_with($languageCode, 'ar');

        if ($ar) {
            return 'أنت مساعد موارد بشرية لمنصة HRM. أعطِ إجابات عملية وقصيرة. '
                .'لا تذكر أي بيانات خارج سياق الشركة. عند عدم توفر معلومات كافية اطلب توضيحاً.';
        }

        return 'You are an HR assistant for an HRM platform. Provide practical concise answers. '
            .'Never assume cross-company data. Ask for clarification when context is insufficient.';
    }
}
