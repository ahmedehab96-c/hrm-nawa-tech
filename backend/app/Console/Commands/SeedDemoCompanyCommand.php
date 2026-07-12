<?php

namespace App\Console\Commands;

use App\Models\Company;
use App\Services\DemoCompanySeeder;
use Illuminate\Console\Command;

class SeedDemoCompanyCommand extends Command
{
    protected $signature = 'demo:seed-company {companyId : The company id}';

    protected $description = 'Seed 2 demo employees for a company (deletable later from admin UI)';

    public function handle(): int
    {
        $id = (int) $this->argument('companyId');
        $company = Company::query()->find($id);
        if (! $company) {
            $this->error("Company {$id} not found.");

            return self::FAILURE;
        }

        $created = DemoCompanySeeder::seedTrialEmployees($company);
        $this->info('Demo employees ready (password: Employee12345!):');
        foreach ($created as $row) {
            $this->line("  - {$row['name']} <{$row['email']}>");
        }

        return self::SUCCESS;
    }
}
