<?php

namespace App\Services;

use App\Models\Company;
use App\Models\ReportSummary;
use App\Models\User;
use App\Services\AiGatewayService;

class ReportGenerationService
{
    public function __construct(
        private readonly HrMetricsService $metrics,
        private readonly AiGatewayService $aiGateway,
    ) {}

    public function generate(
        Company $company,
        User $user,
        string $periodStart,
        string $periodEnd,
        string $reportType = 'hr_overview',
        string $languageCode = 'en',
        bool $withAiNarrative = true,
    ): ReportSummary {
        $metrics = $this->metrics->aggregate($company->id, $periodStart, $periodEnd);
        $provider = $company->ai_provider ?: 'openai';
        $model = $company->ai_model;
        $narrative = $this->fallbackNarrative($metrics, $periodStart, $periodEnd, $languageCode);

        if ($withAiNarrative && $company->ai_enabled) {
            try {
                $reply = $this->aiGateway->generateChatReply(
                    message: $this->buildPrompt($metrics, $periodStart, $periodEnd, $languageCode),
                    languageCode: $languageCode,
                    history: [],
                    providerOverride: $provider,
                    modelOverride: $model,
                );
                $narrative = $reply['content'];
                $provider = $reply['provider'];
                $model = $reply['model'];
            } catch (\Throwable) {
                // Keep fallback narrative when AI is unavailable.
            }
        }

        return ReportSummary::query()->create([
            'company_id' => $company->id,
            'generated_by' => $user->id,
            'report_type' => $reportType,
            'period_start' => $periodStart,
            'period_end' => $periodEnd,
            'metrics_json' => $metrics,
            'narrative' => $narrative,
            'provider' => $provider,
            'model' => $model,
        ]);
    }

    /**
     * @param  array<string, int>  $metrics
     */
    private function fallbackNarrative(
        array $metrics,
        string $periodStart,
        string $periodEnd,
        string $languageCode,
    ): string {
        if (str_starts_with($languageCode, 'ar')) {
            return "ملخص الموارد البشرية للفترة {$periodStart} — {$periodEnd}:\n"
                ."- الموظفون النشطون: {$metrics['employees_active']} / {$metrics['employees_total']}\n"
                ."- حضور: {$metrics['attendance_present']} | تأخير: {$metrics['attendance_late']} | غياب: {$metrics['attendance_absent']}\n"
                ."- إجازات معلّقة: {$metrics['leave_pending']} | معتمدة في الفترة: {$metrics['leave_approved_in_period']}\n"
                ."- كشوف رواتب معالجة: {$metrics['payroll_processed']}";
        }

        return "HR summary for {$periodStart} — {$periodEnd}:\n"
            ."- Active employees: {$metrics['employees_active']} / {$metrics['employees_total']}\n"
            ."- Attendance — present: {$metrics['attendance_present']}, late: {$metrics['attendance_late']}, absent: {$metrics['attendance_absent']}\n"
            ."- Leave — pending: {$metrics['leave_pending']}, approved in period: {$metrics['leave_approved_in_period']}\n"
            ."- Payroll records processed: {$metrics['payroll_processed']}";
    }

    /**
     * @param  array<string, int>  $metrics
     */
    private function buildPrompt(array $metrics, string $periodStart, string $periodEnd, string $languageCode): string
    {
        $payload = json_encode($metrics, JSON_UNESCAPED_UNICODE | JSON_UNESCAPED_SLASHES);
        if (str_starts_with($languageCode, 'ar')) {
            return "أنشئ ملخصا تنفيذيا لتقرير الموارد البشرية للفترة من {$periodStart} إلى {$periodEnd}.\n"
                ."المؤشرات JSON: {$payload}\n"
                ."اجعل الملخص من 5-7 نقاط واضحة مع تنبيهات عملية.";
        }

        return "Create an executive HR dashboard summary for period {$periodStart} to {$periodEnd}.\n"
            ."Metrics JSON: {$payload}\n"
            ."Return 5-7 concise bullet points with practical actions.";
    }
}
