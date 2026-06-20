<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Jobs\ProcessAiTask;
use App\Models\AiTask;
use App\Models\Company;
use App\Models\Employee;
use App\Models\PerformanceReview;
use App\Services\AiGatewayService;
use Illuminate\Http\Request;

class PerformanceController extends Controller
{
    public function __construct(private readonly AiGatewayService $aiGatewayService) {}

    public function index(Request $request)
    {
        $user = $request->user();
        $period = $request->query('period');

        $query = PerformanceReview::query()
            ->where('company_id', $user->company_id)
            ->with('employee:id,name,department,position')
            ->orderByDesc('id');

        if ($period) {
            $query->where('period_label', $period);
        }

        $items = $query->limit(100)->get()->map(function (PerformanceReview $review) {
            return [
                'id' => $review->id,
                'employee_id' => $review->employee_id,
                'employee_name' => $review->employee?->name ?? '',
                'department' => $review->employee?->department,
                'position' => $review->employee?->position,
                'period_label' => $review->period_label,
                'rating' => $review->rating,
                'goals_summary' => $review->goals_summary,
                'strengths' => $review->strengths,
                'improvement_areas' => $review->improvement_areas,
                'manager_comment' => $review->manager_comment,
                'ai_summary' => $review->ai_summary,
                'reviewed_at' => $review->reviewed_at?->toIso8601String(),
            ];
        })->values()->all();

        return response()->json(['data' => $items]);
    }

    public function upsert(Request $request)
    {
        $validated = $request->validate([
            'employee_id' => 'required|integer',
            'period_label' => 'required|string|max:32',
            'rating' => 'nullable|integer|min:1|max:5',
            'goals_summary' => 'nullable|string|max:4000',
            'strengths' => 'nullable|string|max:4000',
            'improvement_areas' => 'nullable|string|max:4000',
            'manager_comment' => 'nullable|string|max:4000',
        ]);

        $user = $request->user();
        $employee = Employee::query()
            ->where('company_id', $user->company_id)
            ->find($validated['employee_id']);
        if (! $employee) {
            return response()->json(['message' => 'Employee not found'], 404);
        }

        $review = PerformanceReview::query()->updateOrCreate(
            [
                'company_id' => $user->company_id,
                'employee_id' => $employee->id,
                'period_label' => $validated['period_label'],
            ],
            [
                'reviewer_user_id' => $user->id,
                'rating' => $validated['rating'] ?? null,
                'goals_summary' => $validated['goals_summary'] ?? null,
                'strengths' => $validated['strengths'] ?? null,
                'improvement_areas' => $validated['improvement_areas'] ?? null,
                'manager_comment' => $validated['manager_comment'] ?? null,
                'reviewed_at' => now(),
            ]
        );

        return response()->json(['message' => 'Performance review saved', 'id' => $review->id], 201);
    }

    public function analyze(Request $request, string $id)
    {
        $user = $request->user();
        $review = PerformanceReview::query()
            ->where('company_id', $user->company_id)
            ->with('employee:id,name,department,position')
            ->find($id);
        if (! $review) {
            return response()->json(['message' => 'Not found'], 404);
        }

        $company = Company::query()->find($user->company_id);
        if (! $company) {
            return response()->json(['message' => 'Company not found'], 404);
        }

        $languageCode = (string) ($request->input('language_code') ?? 'en');
        $prompt = $this->buildPrompt($review, $languageCode);
        $status = 'success';
        $provider = $company->ai_provider ?: 'openai';
        $model = $company->ai_model;

        try {
            $reply = $this->aiGatewayService->generateChatReply(
                message: $prompt,
                languageCode: $languageCode,
                history: [],
                providerOverride: $provider,
                modelOverride: $model,
            );
            $summary = $reply['content'];
            $provider = $reply['provider'];
            $model = $reply['model'];
        } catch (\Throwable $e) {
            $status = 'error';
            $summary = str_starts_with($languageCode, 'ar')
                ? 'تحليل الأداء غير متاح مؤقتا. راجع البيانات اليدوية وأعد المحاولة.'
                : 'Performance analysis is temporarily unavailable. Please review manually and try again.';
        }

        $review->ai_summary = $summary;
        $review->save();

        return response()->json([
            'data' => [
                'review_id' => $review->id,
                'ai_summary' => $summary,
                'provider' => $provider,
                'model' => $model,
                'status' => $status,
            ],
        ]);
    }

    public function analyzeQueued(Request $request, string $id)
    {
        $user = $request->user();
        $review = PerformanceReview::query()
            ->where('company_id', $user->company_id)
            ->find($id);
        if (! $review) {
            return response()->json(['message' => 'Not found'], 404);
        }

        $validated = $request->validate([
            'language_code' => 'nullable|string|max:8',
        ]);

        $task = AiTask::query()->create([
            'company_id' => $user->company_id,
            'user_id' => $user->id,
            'task_type' => 'performance_analyze',
            'status' => 'queued',
            'progress_percent' => 0,
            'queue_name' => 'ai-heavy',
            'payload' => [
                'review_id' => $review->id,
                'language_code' => (string) ($validated['language_code'] ?? 'en'),
            ],
        ]);

        ProcessAiTask::dispatch($task->id)->onQueue('ai-heavy');

        return response()->json([
            'message' => 'AI analysis task queued',
            'data' => [
                'task_id' => $task->id,
                'status' => $task->status,
                'task_type' => $task->task_type,
            ],
        ], 202);
    }

    private function buildPrompt(PerformanceReview $review, string $languageCode): string
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
}
