<?php

namespace App\Services;

use App\Models\AttendanceRecord;
use App\Models\Employee;
use App\Models\LeaveRequest;
use App\Models\PayrollRecord;

class HrMetricsService
{
    /**
     * @return array<string, int>
     */
    public function aggregate(int $companyId, string $periodStart, string $periodEnd): array
    {
        return [
            'employees_total' => Employee::query()->where('company_id', $companyId)->count(),
            'employees_active' => Employee::query()
                ->where('company_id', $companyId)
                ->where('is_active', true)
                ->count(),
            'attendance_present' => AttendanceRecord::query()
                ->where('company_id', $companyId)
                ->whereBetween('work_date', [$periodStart, $periodEnd])
                ->where('status', 'present')
                ->count(),
            'attendance_late' => AttendanceRecord::query()
                ->where('company_id', $companyId)
                ->whereBetween('work_date', [$periodStart, $periodEnd])
                ->where('status', 'late')
                ->count(),
            'attendance_absent' => AttendanceRecord::query()
                ->where('company_id', $companyId)
                ->whereBetween('work_date', [$periodStart, $periodEnd])
                ->where('status', 'absent')
                ->count(),
            'leave_pending' => LeaveRequest::query()
                ->where('company_id', $companyId)
                ->where('status', 'pending')
                ->count(),
            'leave_approved_in_period' => LeaveRequest::query()
                ->where('company_id', $companyId)
                ->where('status', 'approved')
                ->whereBetween('from_date', [$periodStart, $periodEnd])
                ->count(),
            'payroll_processed' => PayrollRecord::query()
                ->where('company_id', $companyId)
                ->where('status', 'processed')
                ->count(),
        ];
    }
}
