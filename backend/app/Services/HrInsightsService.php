<?php

namespace App\Services;

use App\Models\AttendanceRecord;
use App\Models\LeaveRequest;
use Illuminate\Support\Collection;

class HrInsightsService
{
    /**
     * @return array{
     *   period_start:string,
     *   period_end:string,
     *   total_records:int,
     *   present_count:int,
     *   late_count:int,
     *   absent_count:int,
     *   late_rate:float,
     *   absence_rate:float,
     *   risk_employees:array<int,array{id:int,name:string,late_count:int,absent_count:int}>
     * }
     */
    public function buildAttendanceInsights(int $companyId, int $days): array
    {
        $days = max(7, min(90, $days));
        $end = now()->startOfDay();
        $start = $end->copy()->subDays($days - 1);

        $records = AttendanceRecord::query()
            ->where('company_id', $companyId)
            ->whereBetween('work_date', [$start->toDateString(), $end->toDateString()])
            ->with('employee:id,name')
            ->get();

        $total = $records->count();
        $present = $records->where('status', 'present')->count();
        $late = $records->where('status', 'late')->count();
        $absent = $records->where('status', 'absent')->count();

        $byEmployee = $records->groupBy('employee_id');
        $riskEmployees = $byEmployee
            ->map(function (Collection $rows, $employeeId) {
                $lateCount = $rows->where('status', 'late')->count();
                $absentCount = $rows->where('status', 'absent')->count();
                $employeeName = (string) optional($rows->first()?->employee)->name;
                return [
                    'id' => (int) $employeeId,
                    'name' => $employeeName,
                    'late_count' => $lateCount,
                    'absent_count' => $absentCount,
                ];
            })
            ->filter(fn ($row) => $row['late_count'] >= 3 || $row['absent_count'] >= 2)
            ->sortByDesc(fn ($row) => ($row['absent_count'] * 2) + $row['late_count'])
            ->values()
            ->take(10)
            ->all();

        $lateRate = $total > 0 ? round(($late / $total) * 100, 2) : 0.0;
        $absenceRate = $total > 0 ? round(($absent / $total) * 100, 2) : 0.0;

        return [
            'period_start' => $start->toDateString(),
            'period_end' => $end->toDateString(),
            'total_records' => $total,
            'present_count' => $present,
            'late_count' => $late,
            'absent_count' => $absent,
            'late_rate' => $lateRate,
            'absence_rate' => $absenceRate,
            'risk_employees' => $riskEmployees,
        ];
    }

    /**
     * @return array{action:string,confidence:int,reason:string}
     */
    public function buildLeaveRecommendation(
        LeaveRequest $leave,
        float $remainingBalanceForType,
    ): array {
        $days = (float) $leave->days;
        $type = strtolower((string) $leave->type);

        $action = 'approve';
        $confidence = 70;
        $reason = 'Requested days fit employee balance.';

        if ($remainingBalanceForType <= 0.0) {
            $action = 'reject';
            $confidence = 92;
            $reason = 'No balance left for this leave type.';
        } elseif ($days > $remainingBalanceForType) {
            $action = 'review';
            $confidence = 80;
            $reason = 'Requested days exceed remaining balance and need manager review.';
        } elseif ($type === 'emergency' && $days > 2) {
            $action = 'review';
            $confidence = 68;
            $reason = 'Emergency leave duration is above common threshold.';
        } elseif ($type === 'sick' && $days >= 3) {
            $action = 'review';
            $confidence = 66;
            $reason = 'Extended sick leave should be validated by HR policy.';
        }

        return [
            'action' => $action,
            'confidence' => $confidence,
            'reason' => $reason,
        ];
    }
}
