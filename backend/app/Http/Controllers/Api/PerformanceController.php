<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Company;
use App\Models\Employee;
use App\Models\PerformanceReview;
use App\Services\Ai\AiTaskDispatcher;
use App\Services\PerformanceReviewAnalysisService;
use Illuminate\Http\Request;

class PerformanceController extends Controller
{
    public function __construct(private readonly AiTaskDispatcher $aiTaskDispatcher) {}

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
        $review = app(PerformanceReviewAnalysisService::class)->analyze($review, $company, $languageCode);

        return response()->json([
            'data' => [
                'review_id' => $review->id,
                'ai_summary' => $review->ai_summary,
                'provider' => $company->ai_provider ?: 'openai',
                'model' => $company->ai_model,
                'status' => 'success',
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

        $task = $this->aiTaskDispatcher->dispatch(
            companyId: (int) $user->company_id,
            userId: (int) $user->id,
            taskType: 'performance_analyze',
            payload: [
                'review_id' => $review->id,
                'language_code' => (string) ($validated['language_code'] ?? 'en'),
            ],
        );

        return response()->json([
            'message' => 'AI analysis task queued',
            'data' => [
                'task_id' => $task->id,
                'status' => $task->status,
                'task_type' => $task->task_type,
            ],
        ], 202);
    }
}
