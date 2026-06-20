<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Jobs\ProcessAiTask;
use App\Models\AiTask;
use App\Models\Candidate;
use App\Models\CandidateMatchScore;
use App\Models\JobPosting;
use App\Models\Company;
use App\Services\RecruitmentAiService;
use Illuminate\Http\Request;
use Illuminate\Support\Carbon;

class RecruitmentController extends Controller
{
    public function __construct(private readonly RecruitmentAiService $recruitmentAiService) {}

    // ─── Job Postings ────────────────────────────────────────────────────────

    public function index(Request $request)
    {
        $companyId = $request->user()->company_id;

        $jobs = JobPosting::query()
            ->where('company_id', $companyId)
            ->withCount('candidates')
            ->orderByDesc('created_at')
            ->get()
            ->map(fn (JobPosting $j) => $this->jobData($j, $j->candidates_count));

        return response()->json($jobs->all());
    }

    public function store(Request $request)
    {
        $request->validate([
            'title'       => 'required|string|max:255',
            'department'  => 'nullable|string|max:255',
            'location'    => 'nullable|string|max:255',
            'description' => 'nullable|string',
            'status'      => 'sometimes|in:open,closed,draft',
        ]);

        $job = JobPosting::create([
            'company_id'  => $request->user()->company_id,
            'title'       => $request->input('title'),
            'department'  => $request->input('department'),
            'location'    => $request->input('location'),
            'description' => $request->input('description'),
            'status'      => $request->input('status', 'open'),
        ]);

        return response()->json(['message' => 'Created', 'id' => $job->id], 201);
    }

    public function show(Request $request, string $id)
    {
        $job = $this->findJob($request, $id);
        if (! $job) {
            return response()->json(['message' => 'Not found'], 404);
        }

        $data = $this->jobData($job);
        $data['candidates'] = $job->candidates()
            ->orderBy('created_at')
            ->get()
            ->map(fn (Candidate $c) => $this->candidateData($c))
            ->all();

        return response()->json(['data' => $data]);
    }

    public function update(Request $request, string $id)
    {
        $job = $this->findJob($request, $id);
        if (! $job) {
            return response()->json(['message' => 'Not found'], 404);
        }

        $request->validate([
            'title'       => 'sometimes|string|max:255',
            'department'  => 'nullable|string|max:255',
            'location'    => 'nullable|string|max:255',
            'description' => 'nullable|string',
            'status'      => 'sometimes|in:open,closed,draft',
        ]);

        $job->fill($request->only(['title', 'department', 'location', 'description', 'status']));
        $job->save();

        return response()->json(['message' => 'Updated']);
    }

    public function destroy(Request $request, string $id)
    {
        $job = $this->findJob($request, $id);
        if (! $job) {
            return response()->json(['message' => 'Not found'], 404);
        }

        $job->candidates()->delete();
        $job->delete();

        return response()->json(['message' => 'Deleted']);
    }

    // ─── Candidates ───────────────────────────────────────────────────────────

    public function addCandidate(Request $request, string $jobId)
    {
        $job = $this->findJob($request, $jobId);
        if (! $job) {
            return response()->json(['message' => 'Job not found'], 404);
        }

        $request->validate([
            'name'  => 'required|string|max:255',
            'email' => 'nullable|email|max:255',
            'phone' => 'nullable|string|max:64',
            'notes' => 'nullable|string',
            'resume_text' => 'nullable|string|max:20000',
        ]);

        $candidate = Candidate::create([
            'company_id'     => $request->user()->company_id,
            'job_posting_id' => $job->id,
            'name'           => $request->input('name'),
            'email'          => $request->input('email'),
            'phone'          => $request->input('phone'),
            'stage'          => 'new',
            'notes'          => $request->input('notes'),
            'resume_text'    => $request->input('resume_text'),
        ]);

        return response()->json(['message' => 'Candidate added', 'id' => $candidate->id], 201);
    }

    public function parseCandidateCv(Request $request, string $jobId, string $candidateId)
    {
        $candidate = $this->findCandidate($request, $jobId, $candidateId);
        if (! $candidate) {
            return response()->json(['message' => 'Not found'], 404);
        }

        $request->validate([
            'cv_text' => 'required|string|max:20000',
            'language_code' => 'nullable|string|max:8',
        ]);

        $user = $request->user();
        $company = Company::query()->find($user->company_id);
        if (! $company) {
            return response()->json(['message' => 'Company not found'], 404);
        }

        $languageCode = (string) ($request->input('language_code') ?? 'en');
        $cvText = trim((string) $request->input('cv_text'));

        $parsed = $this->recruitmentAiService->parseCv(
            cvText: $cvText,
            languageCode: $languageCode,
            provider: $company->ai_provider ?: 'openai',
            model: $company->ai_model,
        );

        $candidate->resume_text = $cvText;
        $candidate->cv_summary = $parsed['summary'] !== '' ? $parsed['summary'] : null;
        $candidate->skills_json = $parsed['skills'];
        $candidate->years_experience = $parsed['years_experience'] > 0 ? $parsed['years_experience'] : null;
        $candidate->ai_parsed_at = Carbon::now();
        $candidate->save();

        return response()->json([
            'message' => 'CV parsed',
            'data' => $this->candidateData($candidate),
        ]);
    }

    public function parseCandidateCvQueued(Request $request, string $jobId, string $candidateId)
    {
        $candidate = $this->findCandidate($request, $jobId, $candidateId);
        if (! $candidate) {
            return response()->json(['message' => 'Not found'], 404);
        }

        $validated = $request->validate([
            'cv_text' => 'required|string|max:20000',
            'language_code' => 'nullable|string|max:8',
        ]);

        $task = AiTask::query()->create([
            'company_id' => $request->user()->company_id,
            'user_id' => $request->user()->id,
            'task_type' => 'recruitment_parse_cv',
            'status' => 'queued',
            'progress_percent' => 0,
            'queue_name' => 'ai-heavy',
            'payload' => [
                'candidate_id' => $candidate->id,
                'cv_text' => (string) $validated['cv_text'],
                'language_code' => (string) ($validated['language_code'] ?? 'en'),
            ],
        ]);

        ProcessAiTask::dispatch($task->id)->onQueue('ai-heavy');

        return response()->json([
            'message' => 'CV parsing task queued',
            'data' => [
                'task_id' => $task->id,
                'status' => $task->status,
                'task_type' => $task->task_type,
            ],
        ], 202);
    }

    public function matchCandidates(Request $request, string $id)
    {
        $job = $this->findJob($request, $id);
        if (! $job) {
            return response()->json(['message' => 'Not found'], 404);
        }

        $request->validate([
            'language_code' => 'nullable|string|max:8',
        ]);

        $user = $request->user();
        $company = Company::query()->find($user->company_id);
        if (! $company) {
            return response()->json(['message' => 'Company not found'], 404);
        }

        $candidates = $job->candidates()->orderBy('id')->get();
        if ($candidates->isEmpty()) {
            return response()->json(['data' => []]);
        }

        $languageCode = (string) ($request->input('language_code') ?? 'en');
        $scores = $this->recruitmentAiService->scoreCandidates(
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
                'company_id' => $company->id,
                'job_posting_id' => $job->id,
                'candidate_id' => $candidate->id,
                'created_by' => $user->id,
                'score' => $item['score'],
                'reason' => $item['reason'],
            ]);
        }

        $refreshed = $job->candidates()
            ->orderByDesc('ai_fit_score')
            ->orderBy('id')
            ->get()
            ->map(fn (Candidate $c) => $this->candidateData($c))
            ->values()
            ->all();

        return response()->json(['data' => $refreshed]);
    }

    public function matchCandidatesQueued(Request $request, string $id)
    {
        $job = $this->findJob($request, $id);
        if (! $job) {
            return response()->json(['message' => 'Not found'], 404);
        }

        $validated = $request->validate([
            'language_code' => 'nullable|string|max:8',
        ]);

        $task = AiTask::query()->create([
            'company_id' => $request->user()->company_id,
            'user_id' => $request->user()->id,
            'task_type' => 'recruitment_match_candidates',
            'status' => 'queued',
            'progress_percent' => 0,
            'queue_name' => 'ai-heavy',
            'payload' => [
                'job_id' => $job->id,
                'language_code' => (string) ($validated['language_code'] ?? 'en'),
            ],
        ]);

        ProcessAiTask::dispatch($task->id)->onQueue('ai-heavy');

        return response()->json([
            'message' => 'Candidate matching task queued',
            'data' => [
                'task_id' => $task->id,
                'status' => $task->status,
                'task_type' => $task->task_type,
            ],
        ], 202);
    }

    public function updateCandidateStage(Request $request, string $jobId, string $candidateId)
    {
        $candidate = $this->findCandidate($request, $jobId, $candidateId);
        if (! $candidate) {
            return response()->json(['message' => 'Not found'], 404);
        }

        $request->validate([
            'stage' => 'required|in:new,interview,offer,hired,rejected',
        ]);

        $candidate->stage = $request->input('stage');
        $candidate->save();

        return response()->json(['message' => 'Stage updated']);
    }

    public function deleteCandidate(Request $request, string $jobId, string $candidateId)
    {
        $candidate = $this->findCandidate($request, $jobId, $candidateId);
        if (! $candidate) {
            return response()->json(['message' => 'Not found'], 404);
        }

        $candidate->delete();

        return response()->json(['message' => 'Deleted']);
    }

    // ─── Helpers ──────────────────────────────────────────────────────────────

    private function findJob(Request $request, string $id): ?JobPosting
    {
        return JobPosting::query()
            ->where('company_id', $request->user()->company_id)
            ->find($id);
    }

    private function findCandidate(Request $request, string $jobId, string $candidateId): ?Candidate
    {
        return Candidate::query()
            ->where('company_id', $request->user()->company_id)
            ->where('job_posting_id', $jobId)
            ->find($candidateId);
    }

    private function jobData(JobPosting $job, ?int $candidatesCount = null): array
    {
        return [
            'id'               => $job->id,
            'title'            => $job->title,
            'department'       => $job->department,
            'location'         => $job->location,
            'description'      => $job->description,
            'status'           => $job->status,
            'candidates_count' => $candidatesCount ?? $job->candidates()->count(),
            'created_at'       => $job->created_at?->toDateString(),
        ];
    }

    private function candidateData(Candidate $c): array
    {
        return [
            'id'    => $c->id,
            'name'  => $c->name,
            'email' => $c->email,
            'phone' => $c->phone,
            'stage' => $c->stage,
            'notes' => $c->notes,
            'cv_summary' => $c->cv_summary,
            'skills' => $c->skills_json ?? [],
            'years_experience' => $c->years_experience,
            'ai_fit_score' => $c->ai_fit_score,
            'ai_match_reason' => $c->ai_match_reason,
        ];
    }
}
