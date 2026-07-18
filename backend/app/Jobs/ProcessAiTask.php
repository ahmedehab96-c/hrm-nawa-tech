<?php

namespace App\Jobs;

use App\Models\AiTask;
use App\Models\AiUsageLog;
use App\Models\AttendanceRecord;
use App\Models\Candidate;
use App\Models\Company;
use App\Models\Employee;
use App\Models\JobPosting;
use App\Models\LeaveRequest;
use App\Models\PayrollRecord;
use App\Models\PerformanceReview;
use App\Models\ReportSummary;
use App\Models\User;
use App\Services\AiGatewayService;
use App\Services\PerformanceReviewAnalysisService;
use App\Services\RecruitmentAiService;
use App\Services\RecruitmentMatchService;
use Illuminate\Contracts\Queue\ShouldQueue;
use Illuminate\Foundation\Queue\Queueable;

class ProcessAiTask implements ShouldQueue
{
    use Queueable;

    public function __construct(public readonly int $taskId)
    {
        $this->onQueue('ai-heavy');
    }

    public function handle(
        AiGatewayService $aiGatewayService,
        RecruitmentAiService $recruitmentAiService,
        RecruitmentMatchService $recruitmentMatchService,
        PerformanceReviewAnalysisService $performanceReviewAnalysisService,
    ): void {
        $task = AiTask::query()->find($this->taskId);
        if (! $task || ! in_array($task->status, ['queued', 'processing'], true)) {
            return;
        }

        $task->status = 'processing';
        $task->progress_percent = 10;
        $task->started_at = $task->started_at ?? now();
        $task->save();

        try {
            $result = match ($task->task_type) {
                'recruitment_parse_cv' => $this->runRecruitmentParseCv($task, $recruitmentAiService),
                'recruitment_match_candidates' => $this->runRecruitmentMatchCandidates($task, $recruitmentMatchService),
                'performance_analyze' => $this->runPerformanceAnalyze($task, $performanceReviewAnalysisService),
                'reports_summarize' => $this->runReportSummarize($task, $aiGatewayService),
                default => throw new \RuntimeException('Unsupported AI task type: '.$task->task_type),
            };

            $task->status = 'completed';
            $task->progress_percent = 100;
            $task->result = $result;
            $task->error_message = null;
            $task->finished_at = now();
            $task->save();
        } catch (\Throwable $e) {
            $task->status = 'failed';
            $task->progress_percent = 100;
            $task->error_message = $e->getMessage();
            $task->finished_at = now();
            $task->save();
        }
    }

    private function runRecruitmentParseCv(AiTask $task, RecruitmentAiService $recruitmentAiService): array
    {
        $payload = $task->payload ?? [];
        $languageCode = (string) ($payload['language_code'] ?? 'en');
        $cvText = trim((string) ($payload['cv_text'] ?? ''));
        if ($cvText === '') {
            throw new \InvalidArgumentException('cv_text is required');
        }

        $candidate = Candidate::query()
            ->where('company_id', $task->company_id)
            ->find((int) ($payload['candidate_id'] ?? 0));
        if (! $candidate) {
            throw new \RuntimeException('Candidate not found');
        }

        $company = Company::query()->find($task->company_id);
        if (! $company) {
            throw new \RuntimeException('Company not found');
        }

        $parsed = $recruitmentAiService->parseCv(
            cvText: $cvText,
            languageCode: $languageCode,
            provider: $company->ai_provider ?: 'openai',
            model: $company->ai_model,
        );

        $candidate->resume_text = $cvText;
        $candidate->cv_summary = $parsed['summary'] !== '' ? $parsed['summary'] : null;
        $candidate->skills_json = $parsed['skills'];
        $candidate->years_experience = $parsed['years_experience'] > 0 ? $parsed['years_experience'] : null;
        $candidate->ai_parsed_at = now();
        $candidate->save();

        return [
            'candidate_id' => $candidate->id,
            'summary' => $candidate->cv_summary,
            'skills' => $candidate->skills_json ?? [],
            'years_experience' => $candidate->years_experience,
        ];
    }

    private function runRecruitmentMatchCandidates(AiTask $task, RecruitmentMatchService $recruitmentMatchService): array
    {
        $payload = $task->payload ?? [];
        $job = JobPosting::query()
            ->where('company_id', $task->company_id)
            ->find((int) ($payload['job_id'] ?? 0));
        if (! $job) {
            throw new \RuntimeException('Job not found');
        }

        $user = User::query()->find((int) $task->user_id);
        if (! $user) {
            throw new \RuntimeException('User not found');
        }

        $languageCode = (string) ($payload['language_code'] ?? 'en');
        $recruitmentMatchService->matchCandidates($job, $user, $languageCode);

        $top = $job->candidates()
            ->orderByDesc('ai_fit_score')
            ->orderBy('id')
            ->limit(10)
            ->get()
            ->map(fn (Candidate $c) => [
                'id' => $c->id,
                'name' => $c->name,
                'ai_fit_score' => $c->ai_fit_score,
                'ai_match_reason' => $c->ai_match_reason,
            ])
            ->values()
            ->all();

        return [
            'job_id' => $job->id,
            'candidates' => $top,
        ];
    }

    private function runPerformanceAnalyze(AiTask $task, PerformanceReviewAnalysisService $performanceReviewAnalysisService): array
    {
        $payload = $task->payload ?? [];
        $review = PerformanceReview::query()
            ->where('company_id', $task->company_id)
            ->with('employee:id,name,department,position')
            ->find((int) ($payload['review_id'] ?? 0));
        if (! $review) {
            throw new \RuntimeException('Performance review not found');
        }

        $company = Company::query()->find($task->company_id);
        if (! $company) {
            throw new \RuntimeException('Company not found');
        }

        $languageCode = (string) ($payload['language_code'] ?? 'en');
        $review = $performanceReviewAnalysisService->analyze($review, $company, $languageCode);

        return [
            'review_id' => $review->id,
            'ai_summary' => $review->ai_summary,
            'provider' => $company->ai_provider ?: 'openai',
            'model' => $company->ai_model,
            'status' => 'success',
        ];
    }

    private function runReportSummarize(AiTask $task, AiGatewayService $aiGatewayService): array
    {
        $payload = $task->payload ?? [];
        $periodStart = (string) ($payload['period_start'] ?? '');
        $periodEnd = (string) ($payload['period_end'] ?? '');
        $reportType = (string) ($payload['report_type'] ?? 'hr_overview');
        $languageCode = (string) ($payload['language_code'] ?? 'en');
        if ($periodStart === '' || $periodEnd === '') {
            throw new \InvalidArgumentException('period_start and period_end are required');
        }

        $company = Company::query()->find($task->company_id);
        if (! $company) {
            throw new \RuntimeException('Company not found');
        }

        $metrics = [
            'employees_total' => Employee::query()->where('company_id', $task->company_id)->count(),
            'attendance_present' => AttendanceRecord::query()
                ->where('company_id', $task->company_id)
                ->whereBetween('work_date', [$periodStart, $periodEnd])
                ->where('status', 'present')
                ->count(),
            'attendance_late' => AttendanceRecord::query()
                ->where('company_id', $task->company_id)
                ->whereBetween('work_date', [$periodStart, $periodEnd])
                ->where('status', 'late')
                ->count(),
            'attendance_absent' => AttendanceRecord::query()
                ->where('company_id', $task->company_id)
                ->whereBetween('work_date', [$periodStart, $periodEnd])
                ->where('status', 'absent')
                ->count(),
            'leave_pending' => LeaveRequest::query()
                ->where('company_id', $task->company_id)
                ->where('status', 'pending')
                ->count(),
            'leave_approved_in_period' => LeaveRequest::query()
                ->where('company_id', $task->company_id)
                ->where('status', 'approved')
                ->whereBetween('from_date', [$periodStart, $periodEnd])
                ->count(),
            'payroll_processed' => PayrollRecord::query()
                ->where('company_id', $task->company_id)
                ->where('status', 'processed')
                ->count(),
        ];

        $provider = $company->ai_provider ?: 'openai';
        $model = $company->ai_model;
        $status = 'success';
        $errorMessage = null;
        $promptTokens = null;
        $completionTokens = null;
        $totalTokens = null;
        $startedAt = microtime(true);

        try {
            $reply = $aiGatewayService->generateChatReply(
                message: $this->buildReportPrompt($metrics, $periodStart, $periodEnd, $languageCode),
                languageCode: $languageCode,
                history: [],
                providerOverride: $provider,
                modelOverride: $model,
            );
            $narrative = $reply['content'];
            $provider = $reply['provider'];
            $model = $reply['model'];
            $promptTokens = $reply['prompt_tokens'];
            $completionTokens = $reply['completion_tokens'];
            $totalTokens = $reply['total_tokens'];
        } catch (\Throwable $e) {
            $status = 'error';
            $errorMessage = $e->getMessage();
            $narrative = str_starts_with($languageCode, 'ar')
                ? 'تم تجميع المؤشرات، لكن توليد الملخص النصي غير متاح مؤقتا.'
                : 'Metrics were aggregated, but narrative generation is temporarily unavailable.';
        }

        $latencyMs = (int) round((microtime(true) - $startedAt) * 1000);

        $record = ReportSummary::query()->create([
            'company_id' => $task->company_id,
            'generated_by' => $task->user_id,
            'report_type' => $reportType,
            'period_start' => $periodStart,
            'period_end' => $periodEnd,
            'metrics_json' => $metrics,
            'narrative' => $narrative,
            'provider' => $provider,
            'model' => $model,
        ]);

        $this->logUsage(
            companyId: $task->company_id,
            userId: $task->user_id,
            endpoint: 'reports/summaries',
            provider: $provider,
            model: $model,
            latencyMs: $latencyMs,
            promptTokens: $promptTokens,
            completionTokens: $completionTokens,
            totalTokens: $totalTokens,
            status: $status,
            errorMessage: $errorMessage,
        );

        return [
            'id' => $record->id,
            'report_type' => $reportType,
            'period_start' => $periodStart,
            'period_end' => $periodEnd,
            'metrics' => $metrics,
            'narrative' => $narrative,
            'provider' => $provider,
            'model' => $model,
            'status' => $status,
        ];
    }

    private function buildReportPrompt(array $metrics, string $periodStart, string $periodEnd, string $languageCode): string
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

    private function logUsage(
        int $companyId,
        ?int $userId,
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
            'conversation_id' => null,
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
}
