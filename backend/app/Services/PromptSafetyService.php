<?php

namespace App\Services;

class PromptSafetyService
{
    /**
     * @return array{
     *   allowed:bool,
     *   reason:string|null,
     *   sanitized:string
     * }
     */
    public function assess(string $rawInput, string $safetyLevel = 'standard'): array
    {
        $text = $this->sanitize($rawInput);
        $lower = mb_strtolower($text);

        $secretExfilPatterns = [
            '/\b(api[\s_-]*key|secret|access[\s_-]*token|private[\s_-]*key)\b/ui',
            '/\b(show|reveal|print|expose)\b.{0,30}\b(system[\s_-]*prompt|internal instructions?)\b/ui',
            '/\b(passwords?)\b/ui',
        ];

        foreach ($secretExfilPatterns as $pattern) {
            if (preg_match($pattern, $text) === 1) {
                return [
                    'allowed' => false,
                    'reason' => 'potential_secret_exfiltration',
                    'sanitized' => $text,
                ];
            }
        }

        if ($safetyLevel === 'strict') {
            $jailbreakPatterns = [
                '/\b(ignore|bypass)\b.{0,25}\b(instruction|policy|guardrails?)\b/ui',
                '/\bact as\b.{0,20}\b(system|developer)\b/ui',
                '/\bdo anything now\b/ui',
                '/\bjailbreak\b/ui',
            ];

            foreach ($jailbreakPatterns as $pattern) {
                if (preg_match($pattern, $text) === 1) {
                    return [
                        'allowed' => false,
                        'reason' => 'prompt_injection_detected',
                        'sanitized' => $text,
                    ];
                }
            }

            if (mb_strlen($lower) > 12000) {
                return [
                    'allowed' => false,
                    'reason' => 'input_too_long_for_strict_safety',
                    'sanitized' => mb_substr($text, 0, 12000),
                ];
            }
        }

        return [
            'allowed' => true,
            'reason' => null,
            'sanitized' => $text,
        ];
    }

    private function sanitize(string $raw): string
    {
        $normalized = preg_replace('/[\x00-\x08\x0B\x0C\x0E-\x1F\x7F]/u', ' ', $raw) ?? $raw;
        $normalized = preg_replace('/\s+/u', ' ', $normalized) ?? $normalized;
        return trim($normalized);
    }
}
