<?php

namespace App\Services;

use App\Models\Candidate;
use App\Models\CandidateMatchScore;
use App\Models\Company;
use App\Models\JobPosting;
use App\Models\User;

class RecruitmentMatchService
{
    public function __construct(private readonly RecruitmentAiService $recruitmentAiService) {}

    public function matchCandidates(JobPosting $job, User $user, string $languageCode = 'en'): int
    {
        $company = Company::query()->find($user->company_id);
        if ($company === null) {
            return 0;
        }

        $candidates = $job->candidates()->orderBy('id')->get();
        if ($candidates->isEmpty()) {
            return 0;
        }

        $scores = $this->recruitmentAiService->scoreCandidates(
            job: $job,
            candidates: $candidates,
            languageCode: $languageCode,
            provider: $company->ai_provider ?: 'openai',
            model: $company->ai_model,
        );

        $updated = 0;
        foreach ($scores as $item) {
            /** @var Candidate|null $candidate */
            $candidate = $candidates->firstWhere('id', $item['candidate_id']);
            if ($candidate === null) {
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
            $updated++;
        }

        return $updated;
    }
}
