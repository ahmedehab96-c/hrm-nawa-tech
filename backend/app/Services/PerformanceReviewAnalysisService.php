<?php

namespace App\Services;

use App\Models\Company;
use App\Models\PerformanceReview;
use App\Services\AiGatewayService;

class PerformanceReviewAnalysisService
{
    public function __construct(private readonly AiGatewayService $aiGateway) {}

    public function analyze(PerformanceReview $review, Company $company, string $languageCode = 'en'): PerformanceReview
    {
        $review->loadMissing('employee:id,name,department,position');

        $provider = $company->ai_provider ?: 'openai';
        $model = $company->ai_model;

        try {
            $reply = $this->aiGateway->generateChatReply(
                message: $this->buildPrompt($review, $languageCode),
                languageCode: $languageCode,
                history: [],
                providerOverride: $provider,
                modelOverride: $model,
            );
            $review->ai_summary = $reply['content'];
        } catch (\Throwable) {
            $review->ai_summary = str_starts_with($languageCode, 'ar')
                ? 'تعذر توليد ملخص AI حالياً. راجع التقييم يدوياً.'
                : 'AI summary is temporarily unavailable. Review manually.';
        }

        $review->save();

        return $review;
    }

    private function buildPrompt(PerformanceReview $review, string $languageCode): string
    {
        $employee = $review->employee;
        $payload = json_encode([
            'employee' => $employee?->name,
            'department' => $employee?->department,
            'position' => $employee?->position,
            'period' => $review->period_label,
            'rating' => $review->rating,
            'goals' => $review->goals_summary,
            'strengths' => $review->strengths,
            'improvement_areas' => $review->improvement_areas,
            'manager_comment' => $review->manager_comment,
        ], JSON_UNESCAPED_UNICODE | JSON_UNESCAPED_SLASHES);

        if (str_starts_with($languageCode, 'ar')) {
            return "حلل تقييم الأداء التالي وقدّم ملخصاً موجزاً للمدير (3-5 نقاط):\n{$payload}";
        }

        return "Analyze this performance review and return a concise manager summary (3-5 bullets):\n{$payload}";
    }
}
