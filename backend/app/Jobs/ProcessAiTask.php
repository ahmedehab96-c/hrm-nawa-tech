<?php

namespace App\Jobs;

use App\Models\AiTask;
use App\Models\AiUsageLog;
use App\Models\AttendanceRecord;
use App\Models\Candidate;
use App\Models\CandidateMatchScore;
use App\Models\Company;
use App\Models\Employee;
use App\Models\JobPosting;
use App\Models\LeaveRequest;
use App\Models\PayrollRecord;
use App\Models\PerformanceReview;
use App\Models\ReportSummary;
use App\Services\AiGatewayService;
use App\Services\RecruitmentAiService;
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
                'recruitment_match_candidates' => $this->runRecruitmentMatchCandidates($task, $recruitmentAiService),
                'performance_analyze' => $this->runPerformanceAnalyze($task, $aiGatewayService),
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

    private function runRecruitmentMatchCandidates(AiTask $task, RecruitmentAiService $recruitmentAiService): array
    {
        $payload = $task->payload ?? [];
        $job = JobPosting::query()
            ->where('company_id', $task->company_id)
            ->find((int) ($payload['job_id'] ?? 0));
        if (! $job) {
            throw new \RuntimeException('Job not found');
        }

        $company = Company::query()->find($task->company_id);
        if (! $company) {
            throw new \RuntimeException('Company not found');
        }

        $candidates = $job->candidates()->orderBy('id')->get();
        $languageCode = (string) ($payload['language_code'] ?? 'en');
        if ($candidates->isEmpty()) {
            return ['job_id' => $job->id, 'candidates' => []];
        }

        $scores = $recruitmentAiService->scoreCandidates(
            job: $job,
            candidates: $candidates,
            languageCode: $languageCode,
            provider: $company->ai_provider ?: 'openai',
            model: $company->ai_model,
        );

        foreach ($scores as $item) {
            /** @var Candidate|null $candidate */
            $candidate = $candidates->firstWhere('id', $item['candidate_id']);
            if (! $candidate) {
                continue;
            }

            $candidate->ai_fit_score = $item['score'];
            $candidate->ai_match_reason = $item['reason'];
            $candidate->save();

            CandidateMatchScore::query()->create([
                'company_id' => $task->company_id,
                'job_posting_id' => $job->id,
                'candidate_id' => $candidate->id,
                'created_by' => $task->user_id,
                'score' => $item['score'],
                'reason' => $item['reason'],
            ]);
        }

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

    private function runPerformanceAnalyze(AiTask $task, AiGatewayService $aiGatewayService): array
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
        $prompt = $this->buildPerformancePrompt($review, $languageCode);

        $startedAt = microtime(true);
        $status = 'success';
        $errorMessage = null;
        $provider = $company->ai_provider ?: 'openai';
        $model = $company->ai_model;
        $promptTokens = null;
        $completionTokens = null;
        $totalTokens = null;

        try {
            $reply = $aiGatewayService->generateChatReply(
                message: $prompt,
                languageCode: $languageCode,
                history: [],
                providerOverride: $provider,
                modelOverride: $model,
            );
            $summary = $reply['content'];
            $provider = $reply['provider'];
            $model = $reply['model'];
            $promptTokens = $reply['prompt_tokens'];
            $completionTokens = $reply['completion_tokens'];
            $totalTokens = $reply['total_tokens'];
        } catch (\Throwable $e) {
            $status = 'error';
            $errorMessage = $e->getMessage();
            $summary = str_starts_with($languageCode, 'ar')
                ? 'تحليل الأداء غير متاح مؤقتا. راجع البيانات اليدوية وأعد المحاولة.'
                : 'Performance analysis is temporarily unavailable. Please review manually and try again.';
        }

        $latencyMs = (int) round((microtime(true) - $startedAt) * 1000);

        $review->ai_summary = $summary;
        $review->save();

        $this->logUsage(
            companyId: $task->company_id,
            userId: $task->user_id,
            endpoint: 'performance/reviews/analyze',
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
            'review_id' => $review->id,
            'ai_summary' => $summary,
            'provider' => $provider,
            'model' => $model,
            'status' => $status,
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

    private function buildPerformancePrompt(PerformanceReview $review, string $languageCode): string
    {
        $employeeName = (string) ($review->employee?->name ?? 'Employee');
        $department = (string) ($review->employee?->department ?? 'N/A');
        $position = (string) ($review->employee?->position ?? 'N/A');
        $rating = $review->rating !== null ? (string) $review->rating : 'N/A';

        if (str_starts_with($languageCode, 'ar')) {
            return "حلل أداء الموظف وقدّم ملخصا تنفيذيا باللغة العربية مع توصيات عملية.\n"
                ."الاسم: {$employeeName}\n"
                ."القسم: {$department}\n"
                ."المنصب: {$position}\n"
                ."التقييم: {$rating}/5\n"
                ."الأهداف: ".($review->goals_summary ?? '-')."\n"
                ."نقاط القوة: ".($review->strengths ?? '-')."\n"
                ."مجالات التحسين: ".($review->improvement_areas ?? '-')."\n"
                ."تعليق المدير: ".($review->manager_comment ?? '-');
        }

        return "Analyze employee performance and provide an executive summary with actionable recommendations.\n"
            ."Name: {$employeeName}\n"
            ."Department: {$department}\n"
            ."Position: {$position}\n"
            ."Rating: {$rating}/5\n"
            ."Goals summary: ".($review->goals_summary ?? '-')."\n"
            ."Strengths: ".($review->strengths ?? '-')."\n"
            ."Improvement areas: ".($review->improvement_areas ?? '-')."\n"
            ."Manager comment: ".($review->manager_comment ?? '-');
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
