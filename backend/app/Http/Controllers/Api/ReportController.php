<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Jobs\ProcessAiTask;
use App\Models\AiTask;
use App\Models\AttendanceRecord;
use App\Models\Company;
use App\Models\Employee;
use App\Models\LeaveRequest;
use App\Models\PayrollRecord;
use App\Models\ReportSummary;
use App\Services\AiGatewayService;
use Illuminate\Http\Request;

class ReportController extends Controller
{
    public function __construct(private readonly AiGatewayService $aiGatewayService) {}

    public function summarize(Request $request)
    {
        $validated = $request->validate([
            'period_start' => 'required|date',
            'period_end' => 'required|date|after_or_equal:period_start',
            'report_type' => 'nullable|string|max:64',
            'language_code' => 'nullable|string|max:8',
        ]);

        $user = $request->user();
        $company = Company::query()->find($user->company_id);
        if (! $company) {
            return response()->json(['message' => 'Company not found'], 404);
        }

        $periodStart = $validated['period_start'];
        $periodEnd = $validated['period_end'];
        $reportType = $validated['report_type'] ?? 'hr_overview';
        $languageCode = $validated['language_code'] ?? 'en';

        $metrics = [
            'employees_total' => Employee::query()->where('company_id', $user->company_id)->count(),
            'attendance_present' => AttendanceRecord::query()
                ->where('company_id', $user->company_id)
                ->whereBetween('work_date', [$periodStart, $periodEnd])
                ->where('status', 'present')
                ->count(),
            'attendance_late' => AttendanceRecord::query()
                ->where('company_id', $user->company_id)
                ->whereBetween('work_date', [$periodStart, $periodEnd])
                ->where('status', 'late')
                ->count(),
            'attendance_absent' => AttendanceRecord::query()
                ->where('company_id', $user->company_id)
                ->whereBetween('work_date', [$periodStart, $periodEnd])
                ->where('status', 'absent')
                ->count(),
            'leave_pending' => LeaveRequest::query()
                ->where('company_id', $user->company_id)
                ->where('status', 'pending')
                ->count(),
            'leave_approved_in_period' => LeaveRequest::query()
                ->where('company_id', $user->company_id)
                ->where('status', 'approved')
                ->whereBetween('from_date', [$periodStart, $periodEnd])
                ->count(),
            'payroll_processed' => PayrollRecord::query()
                ->where('company_id', $user->company_id)
                ->where('status', 'processed')
                ->count(),
        ];

        $provider = $company->ai_provider ?: 'openai';
        $model = $company->ai_model;
        $status = 'success';
        try {
            $reply = $this->aiGatewayService->generateChatReply(
                message: $this->buildPrompt($metrics, $periodStart, $periodEnd, $languageCode),
                languageCode: $languageCode,
                history: [],
                providerOverride: $provider,
                modelOverride: $model,
            );
            $narrative = $reply['content'];
            $provider = $reply['provider'];
            $model = $reply['model'];
        } catch (\Throwable $e) {
            $status = 'error';
            $narrative = str_starts_with($languageCode, 'ar')
                ? 'تم تجميع المؤشرات، لكن توليد الملخص النصي غير متاح مؤقتا.'
                : 'Metrics were aggregated, but narrative generation is temporarily unavailable.';
        }

        $record = ReportSummary::query()->create([
            'company_id' => $user->company_id,
            'generated_by' => $user->id,
            'report_type' => $reportType,
            'period_start' => $periodStart,
            'period_end' => $periodEnd,
            'metrics_json' => $metrics,
            'narrative' => $narrative,
            'provider' => $provider,
            'model' => $model,
        ]);

        return response()->json([
            'data' => [
                'id' => $record->id,
                'report_type' => $reportType,
                'period_start' => $periodStart,
                'period_end' => $periodEnd,
                'metrics' => $metrics,
                'narrative' => $narrative,
                'provider' => $provider,
                'model' => $model,
                'status' => $status,
            ],
        ]);
    }

    public function summarizeQueued(Request $request)
    {
        $validated = $request->validate([
            'period_start' => 'required|date',
            'period_end' => 'required|date|after_or_equal:period_start',
            'report_type' => 'nullable|string|max:64',
            'language_code' => 'nullable|string|max:8',
        ]);

        $user = $request->user();
        $task = AiTask::query()->create([
            'company_id' => $user->company_id,
            'user_id' => $user->id,
            'task_type' => 'reports_summarize',
            'status' => 'queued',
            'progress_percent' => 0,
            'queue_name' => 'ai-heavy',
            'payload' => [
                'period_start' => (string) $validated['period_start'],
                'period_end' => (string) $validated['period_end'],
                'report_type' => (string) ($validated['report_type'] ?? 'hr_overview'),
                'language_code' => (string) ($validated['language_code'] ?? 'en'),
            ],
        ]);

        ProcessAiTask::dispatch($task->id)->onQueue('ai-heavy');

        return response()->json([
            'message' => 'Report summary task queued',
            'data' => [
                'task_id' => $task->id,
                'status' => $task->status,
                'task_type' => $task->task_type,
            ],
        ], 202);
    }

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
