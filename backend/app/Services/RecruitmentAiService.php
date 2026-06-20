<?php

namespace App\Services;

use App\Models\Candidate;
use App\Models\JobPosting;
use Illuminate\Support\Collection;

class RecruitmentAiService
{
    public function __construct(private readonly AiGatewayService $aiGatewayService) {}

    /**
     * @return array{
     *   summary:string,
     *   skills:array<int,string>,
     *   years_experience:float,
     *   raw_text:string
     * }
     */
    public function parseCv(
        string $cvText,
        string $languageCode,
        ?string $provider = null,
        ?string $model = null,
    ): array {
        $prompt = $this->parsePrompt($cvText, $languageCode);
        $reply = $this->aiGatewayService->generateChatReply(
            message: $prompt,
            languageCode: $languageCode,
            history: [],
            providerOverride: $provider,
            modelOverride: $model,
        );

        $raw = $reply['content'];
        $json = $this->extractJson($raw);
        $skills = $json['skills'] ?? [];
        if (! is_array($skills)) {
            $skills = [];
        }

        $skills = collect($skills)
            ->map(fn ($s) => trim((string) $s))
            ->filter(fn ($s) => $s !== '')
            ->take(20)
            ->values()
            ->all();

        return [
            'summary' => trim((string) ($json['summary'] ?? '')),
            'skills' => $skills,
            'years_experience' => (float) ($json['years_experience'] ?? 0),
            'raw_text' => $raw,
        ];
    }

    /**
     * @param  Collection<int, Candidate>  $candidates
     * @return array<int, array{
     *   candidate_id:int,
     *   score:int,
     *   reason:string
     * }>
     */
    public function scoreCandidates(
        JobPosting $job,
        Collection $candidates,
        string $languageCode,
        ?string $provider = null,
        ?string $model = null,
    ): array {
        $rows = $candidates->map(function (Candidate $candidate) {
            return [
                'candidate_id' => $candidate->id,
                'name' => $candidate->name,
                'summary' => (string) ($candidate->cv_summary ?? ''),
                'skills' => array_values($candidate->skills_json ?? []),
                'years_experience' => (float) ($candidate->years_experience ?? 0),
            ];
        })->values()->all();

        $prompt = $this->scorePrompt($job, $rows, $languageCode);
        $reply = $this->aiGatewayService->generateChatReply(
            message: $prompt,
            languageCode: $languageCode,
            history: [],
            providerOverride: $provider,
            modelOverride: $model,
        );

        $json = $this->extractJson($reply['content']);
        $scores = $json['scores'] ?? [];
        if (! is_array($scores)) {
            return [];
        }

        return collect($scores)
            ->map(function ($item) {
                $candidateId = (int) ($item['candidate_id'] ?? 0);
                $score = (int) ($item['score'] ?? 0);
                $score = max(0, min(100, $score));
                $reason = trim((string) ($item['reason'] ?? ''));
                return [
                    'candidate_id' => $candidateId,
                    'score' => $score,
                    'reason' => $reason,
                ];
            })
            ->filter(fn ($item) => $item['candidate_id'] > 0)
            ->values()
            ->all();
    }

    private function parsePrompt(string $cvText, string $languageCode): string
    {
        $ar = str_starts_with($languageCode, 'ar');
        if ($ar) {
            return "حلل نص السيرة الذاتية التالي وأعد الناتج JSON فقط بدون أي شرح.\n"
                ."المطلوب JSON بالشكل:\n"
                ."{\"summary\":\"...\",\"skills\":[\"...\"],\"years_experience\":0}\n"
                ."نص السيرة:\n{$cvText}";
        }

        return "Parse this CV text and return JSON only, no extra text.\n"
            ."Required format:\n"
            ."{\"summary\":\"...\",\"skills\":[\"...\"],\"years_experience\":0}\n"
            ."CV text:\n{$cvText}";
    }

    /**
     * @param  array<int, array<string,mixed>>  $rows
     */
    private function scorePrompt(JobPosting $job, array $rows, string $languageCode): string
    {
        $payload = json_encode($rows, JSON_UNESCAPED_UNICODE | JSON_UNESCAPED_SLASHES);
        $jobDesc = (string) ($job->description ?? '');
        $ar = str_starts_with($languageCode, 'ar');

        if ($ar) {
            return "قيّم المرشحين حسب ملاءمتهم للوظيفة وأعد JSON فقط.\n"
                ."الوظيفة: {$job->title}\n"
                ."القسم: ".($job->department ?? '-')."\n"
                ."الوصف: {$jobDesc}\n"
                ."المرشحون JSON: {$payload}\n"
                ."أعد بالشكل: {\"scores\":[{\"candidate_id\":1,\"score\":0,\"reason\":\"...\"}]}\n"
                ."الدرجة من 0 إلى 100.";
        }

        return "Score candidates for job fit and return JSON only.\n"
            ."Job title: {$job->title}\n"
            ."Department: ".($job->department ?? '-')."\n"
            ."Description: {$jobDesc}\n"
            ."Candidates JSON: {$payload}\n"
            ."Return format: {\"scores\":[{\"candidate_id\":1,\"score\":0,\"reason\":\"...\"}]}\n"
            ."Score range is 0 to 100.";
    }

    /**
     * @return array<string,mixed>
     */
    private function extractJson(string $text): array
    {
        $trim = trim($text);

        // remove fenced markdown if present
        if (preg_match('/```(?:json)?\s*(\{.*\})\s*```/s', $trim, $m) === 1) {
            $trim = $m[1];
        }

        $decoded = json_decode($trim, true);
        if (is_array($decoded)) {
            return $decoded;
        }

        // best-effort extraction
        if (preg_match('/\{.*\}/s', $trim, $m) === 1) {
            $decoded = json_decode($m[0], true);
            if (is_array($decoded)) {
                return $decoded;
            }
        }

        return [];
    }
}
