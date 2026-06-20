<?php

namespace App\Console\Commands;

use App\Jobs\ProcessAiEscalationDigest;
use App\Models\Company;
use App\Services\AiEscalationService;
use Illuminate\Console\Command;

class RunAiEscalationDigestCommand extends Command
{
    protected $signature = 'ai:escalation-digest
        {--company_id= : Run for a specific company id}
        {--window= : Override digest window in minutes}
        {--dry-run : Compute summary without queuing notifications}
        {--sync : Run immediately instead of queueing digest job}';

    protected $description = 'Queue or run AI escalation digest for enabled companies';

    public function handle(AiEscalationService $service): int
    {
        $companyId = $this->option('company_id');
        $windowOverride = $this->option('window');
        $dryRun = (bool) $this->option('dry-run');
        $sync = (bool) $this->option('sync');

        $query = Company::query()
            ->where('ai_enabled', true)
            ->where(function ($q): void {
                $q->whereNull('ai_digest_enabled')
                    ->orWhere('ai_digest_enabled', true);
            });

        if ($companyId !== null && (string) $companyId !== '') {
            $query->where('id', (int) $companyId);
        }

        $companies = $query->get();
        if ($companies->isEmpty()) {
            $this->info('No companies matched digest criteria.');
            return self::SUCCESS;
        }

        $handled = 0;
        foreach ($companies as $company) {
            $windowMinutes = $windowOverride !== null && (string) $windowOverride !== ''
                ? max(5, (int) $windowOverride)
                : max(5, (int) ($company->ai_digest_window_minutes ?? 60));

            if ($sync || $dryRun) {
                $result = $service->queueDigestForCompany(
                    company: $company,
                    triggeredByUserId: null,
                    windowMinutes: $windowMinutes,
                    dryRun: $dryRun,
                );
                $this->line(sprintf(
                    'Company %d digest %s (window=%dm, queued=%d)',
                    (int) $company->id,
                    $dryRun ? 'dry-run' : 'executed',
                    $windowMinutes,
                    (int) ($result['queued_notifications'] ?? 0),
                ));
            } else {
                dispatch(new ProcessAiEscalationDigest(
                    companyId: (int) $company->id,
                    triggeredByUserId: null,
                    windowMinutes: $windowMinutes,
                ));
                $this->line(sprintf(
                    'Company %d digest queued (window=%dm)',
                    (int) $company->id,
                    $windowMinutes,
                ));
            }

            $handled++;
        }

        $this->info("AI escalation digest handled for {$handled} compan".($handled === 1 ? 'y' : 'ies').'.');

        return self::SUCCESS;
    }
}
