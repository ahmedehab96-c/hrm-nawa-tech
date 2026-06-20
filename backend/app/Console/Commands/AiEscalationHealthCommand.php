<?php

namespace App\Console\Commands;

use App\Models\Company;
use Illuminate\Console\Command;

class AiEscalationHealthCommand extends Command
{
    protected $signature = 'ai:escalation-health {--company_id= : Check a specific company id}';

    protected $description = 'Validate AI escalation and digest readiness per company';

    public function handle(): int
    {
        $companyId = $this->option('company_id');
        $query = Company::query();
        if ($companyId !== null && (string) $companyId !== '') {
            $query->where('id', (int) $companyId);
        }
        $companies = $query->orderBy('id')->get();
        if ($companies->isEmpty()) {
            $this->warn('No companies found for health check.');
            return self::SUCCESS;
        }

        $hasError = false;
        foreach ($companies as $company) {
            $channels = is_array($company->ai_alert_channels) ? array_values($company->ai_alert_channels) : ['in_app'];
            $runbooks = is_array($company->ai_runbook_links) ? $company->ai_runbook_links : [];
            $silenceWindows = is_array($company->ai_silence_windows) ? $company->ai_silence_windows : [];
            $issues = [];
            $aiEnabled = (bool) ($company->ai_enabled ?? false);

            $header = sprintf(
                'Company #%d (%s)',
                (int) $company->id,
                (string) ($company->name ?? 'n/a'),
            );

            if (! $aiEnabled) {
                $this->warn($header.' ⚠ skipped (AI disabled)');
                continue;
            }

            if (in_array('email', $channels, true) && trim((string) ($company->ai_alert_email_from ?? '')) === '') {
                $issues[] = 'email channel enabled without ai_alert_email_from';
            }
            if (in_array('slack', $channels, true) && trim((string) ($company->ai_slack_webhook_url ?? '')) === '') {
                $issues[] = 'slack channel enabled without ai_slack_webhook_url';
            }

            if (! array_key_exists('default', $runbooks)) {
                $issues[] = 'runbook links missing default key';
            }

            foreach ($silenceWindows as $idx => $window) {
                if (! is_array($window)) {
                    $issues[] = "silence window #{$idx} is not an object";
                    continue;
                }
                if (! is_string($window['start'] ?? null) || preg_match('/^([01]\d|2[0-3]):([0-5]\d)$/', (string) $window['start']) !== 1) {
                    $issues[] = "silence window #{$idx} has invalid start";
                }
                if (! is_string($window['end'] ?? null) || preg_match('/^([01]\d|2[0-3]):([0-5]\d)$/', (string) $window['end']) !== 1) {
                    $issues[] = "silence window #{$idx} has invalid end";
                }
                if (! is_array($window['days'] ?? null)) {
                    $issues[] = "silence window #{$idx} has invalid days";
                }
            }

            $digestEnabled = (bool) ($company->ai_digest_enabled ?? true);
            $digestWindow = (int) ($company->ai_digest_window_minutes ?? 60);
            if ($digestEnabled && $digestWindow < 5) {
                $issues[] = 'ai_digest_window_minutes must be >= 5 when digest is enabled';
            }

            if (empty($issues)) {
                $this->info($header.' ✅ healthy');
            } else {
                $hasError = true;
                $this->error($header.' ❌ issues:');
                foreach ($issues as $issue) {
                    $this->line("  - {$issue}");
                }
            }
        }

        return $hasError ? self::FAILURE : self::SUCCESS;
    }
}
