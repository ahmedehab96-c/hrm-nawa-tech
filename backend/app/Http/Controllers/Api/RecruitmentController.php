<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Candidate;
use App\Models\JobPosting;
use Illuminate\Http\Request;

class RecruitmentController extends Controller
{
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
        ]);

        $candidate = Candidate::create([
            'company_id'     => $request->user()->company_id,
            'job_posting_id' => $job->id,
            'name'           => $request->input('name'),
            'email'          => $request->input('email'),
            'phone'          => $request->input('phone'),
            'stage'          => 'new',
            'notes'          => $request->input('notes'),
        ]);

        return response()->json(['message' => 'Candidate added', 'id' => $candidate->id], 201);
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
        ];
    }
}
