<?php

namespace App\Services;

use App\Models\LeaveRequest;
use Illuminate\Support\Facades\DB;

/**
 * Single source of truth for leave entitlements and remaining balances.
 * Previously this logic was duplicated in LeaveController and
 * LeaveRecommendationService.
 */
class LeaveBalanceService
{
    /** @var array<string, int> */
    private const ENTITLEMENTS = [
        'annual' => 21,
        'sick' => 10,
        'emergency' => 5,
    ];

    /**
     * @return array<string, int>
     */
    public function entitlements(): array
    {
        return self::ENTITLEMENTS;
    }

    public function entitlementFor(string $type): float
    {
        return (float) (self::ENTITLEMENTS[strtolower(trim($type))] ?? 0);
    }

    /**
     * Remaining balances per employee and type.
     *
     * @param  list<int>  $employeeIds
     * @return array<int, array<string, float>> [employee_id => [annual, sick, emergency]]
     */
    public function balancesForEmployees(int $companyId, array $employeeIds): array
    {
        $employeeIds = array_values(array_unique(array_filter($employeeIds)));
        if ($employeeIds === []) {
            return [];
        }

        $approved = LeaveRequest::query()
            ->where('company_id', $companyId)
            ->whereIn('employee_id', $employeeIds)
            ->where('status', 'approved')
            ->select([
                'employee_id',
                DB::raw('LOWER(type) as type_key'),
                DB::raw('SUM(days) as total_days'),
            ])
            ->groupBy(['employee_id', DB::raw('LOWER(type)')])
            ->get();

        $usedMap = [];
        foreach ($approved as $row) {
            $eid = (int) $row->employee_id;
            $typeKey = (string) $row->type_key;
            $usedMap[$eid][$typeKey] = (float) $row->total_days;
        }

        $balances = [];
        foreach ($employeeIds as $eid) {
            $eid = (int) $eid;
            $balances[$eid] = [
                'annual' => max(0.0, (float) self::ENTITLEMENTS['annual'] - ($usedMap[$eid]['annual'] ?? 0.0)),
                'sick' => max(0.0, (float) self::ENTITLEMENTS['sick'] - ($usedMap[$eid]['sick'] ?? 0.0)),
                'emergency' => max(0.0, (float) self::ENTITLEMENTS['emergency'] - ($usedMap[$eid]['emergency'] ?? 0.0)),
            ];
        }

        return $balances;
    }

    public function remainingBalanceForType(int $companyId, int $employeeId, string $type): float
    {
        $balances = $this->balancesForEmployees($companyId, [$employeeId]);
        $typeKey = strtolower(trim($type));

        return (float) ($balances[$employeeId][$typeKey] ?? 0.0);
    }
}
