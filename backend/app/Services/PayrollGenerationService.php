<?php

namespace App\Services;

use App\Models\Employee;
use App\Models\PayrollRecord;
use InvalidArgumentException;

class PayrollGenerationService
{
    public function generate(int $companyId, string $month): int
    {
        if (! preg_match('/^\d{4}-\d{2}$/', $month)) {
            throw new InvalidArgumentException('Month must be in YYYY-MM format.');
        }

        $employees = Employee::query()
            ->where('company_id', $companyId)
            ->where('is_active', true)
            ->orderBy('id')
            ->get();

        $count = 0;
        foreach ($employees as $employee) {
            $base = (float) ($employee->base_salary ?? 0);
            $allowances = (float) ($employee->allowances ?? 0);
            $deductions = (float) ($employee->deductions ?? 0);
            $net = $base + $allowances - $deductions;

            PayrollRecord::query()->updateOrCreate(
                [
                    'company_id' => $companyId,
                    'employee_id' => $employee->id,
                    'month' => $month,
                ],
                [
                    'base_salary' => $base,
                    'allowances' => $allowances,
                    'deductions' => $deductions,
                    'net_salary' => $net,
                    'status' => 'processed',
                ],
            );
            $count++;
        }

        return $count;
    }
}
