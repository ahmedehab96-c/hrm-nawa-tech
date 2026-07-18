<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Company;
use App\Services\Ai\AiTaskDispatcher;
use App\Services\ReportGenerationService;
use Illuminate\Http\Request;

class ReportController extends Controller
{
    public function __construct(
        private readonly ReportGenerationService $reportGeneration,
        private readonly AiTaskDispatcher $aiTaskDispatcher,
    ) {}

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

        $record = $this->reportGeneration->generate(
            company: $company,
            user: $user,
            periodStart: $validated['period_start'],
            periodEnd: $validated['period_end'],
            reportType: $validated['report_type'] ?? 'hr_overview',
            languageCode: $validated['language_code'] ?? 'en',
        );

        return response()->json([
            'data' => [
                'id' => $record->id,
                'report_type' => $record->report_type,
                'period_start' => $record->period_start?->toDateString(),
                'period_end' => $record->period_end?->toDateString(),
                'metrics' => $record->metrics_json,
                'narrative' => $record->narrative,
                'provider' => $record->provider,
                'model' => $record->model,
                'status' => 'success',
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
        $task = $this->aiTaskDispatcher->dispatch(
            companyId: (int) $user->company_id,
            userId: (int) $user->id,
            taskType: 'reports_summarize',
            payload: [
                'period_start' => (string) $validated['period_start'],
                'period_end' => (string) $validated['period_end'],
                'report_type' => (string) ($validated['report_type'] ?? 'hr_overview'),
                'language_code' => (string) ($validated['language_code'] ?? 'en'),
            ],
        );

        return response()->json([
            'message' => 'Report summary task queued',
            'data' => [
                'task_id' => $task->id,
                'status' => $task->status,
                'task_type' => $task->task_type,
            ],
        ], 202);
    }
}
