<?php

namespace App\Jobs;

use App\Models\Company;
use App\Services\AiEscalationService;
use Illuminate\Contracts\Queue\ShouldQueue;
use Illuminate\Foundation\Queue\Queueable;

class ProcessAiEscalationDigest implements ShouldQueue
{
    use Queueable;

    public int $tries = 3;

    public array $backoff = [60, 180, 600];

    public function __construct(
        public readonly int $companyId,
        public readonly ?int $triggeredByUserId = null,
        public readonly int $windowMinutes = 60,
    ) {
        $this->onQueue('ai-alerts');
    }

    public function handle(AiEscalationService $service): void
    {
        $company = Company::query()->find($this->companyId);
        if (! $company) {
            return;
        }
        $service->queueDigestForCompany(
            company: $company,
            triggeredByUserId: $this->triggeredByUserId,
            windowMinutes: $this->windowMinutes,
            dryRun: false,
        );
    }
}
