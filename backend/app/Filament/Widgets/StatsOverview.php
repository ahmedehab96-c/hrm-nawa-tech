<?php

namespace App\Filament\Widgets;

use App\Models\AiUsageLog;
use App\Models\AttendanceRecord;
use App\Models\Employee;
use App\Models\LeaveRequest;
use App\Support\AdminTrans;
use Filament\Widgets\StatsOverviewWidget;
use Filament\Widgets\StatsOverviewWidget\Stat;

class StatsOverview extends StatsOverviewWidget
{
    protected static ?int $sort = 1;

    public static function canView(): bool
    {
        $user = auth()->user();

        return $user !== null
            && ! $user->hasRole('super_admin')
            && $user->company_id !== null;
    }

    protected function getStats(): array
    {
        $companyId = $this->companyId();

        $employees = Employee::query()
            ->when($companyId, fn ($q) => $q->where('company_id', $companyId))
            ->where('is_active', true)
            ->count();

        $pendingLeave = LeaveRequest::query()
            ->when($companyId, fn ($q) => $q->where('company_id', $companyId))
            ->where('status', 'pending')
            ->count();

        $todayAttendance = AttendanceRecord::query()
            ->when($companyId, fn ($q) => $q->where('company_id', $companyId))
            ->whereDate('work_date', today())
            ->count();

        $aiErrorsToday = AiUsageLog::query()
            ->when($companyId, fn ($q) => $q->where('company_id', $companyId))
            ->whereDate('created_at', today())
            ->where('status', 'error')
            ->count();

        return [
            Stat::make(AdminTrans::widget('active_employees'), (string) $employees)
                ->description(AdminTrans::widget('currently_active'))
                ->icon('heroicon-o-users'),
            Stat::make(AdminTrans::widget('pending_leave'), (string) $pendingLeave)
                ->description(AdminTrans::widget('awaiting_approval'))
                ->icon('heroicon-o-calendar-days'),
            Stat::make(AdminTrans::widget('attendance_today'), (string) $todayAttendance)
                ->description(today()->toFormattedDateString())
                ->icon('heroicon-o-clock'),
            Stat::make(AdminTrans::widget('ai_errors_today'), (string) $aiErrorsToday)
                ->description(AdminTrans::widget('from_usage_logs'))
                ->icon('heroicon-o-exclamation-triangle'),
        ];
    }

    protected function companyId(): ?int
    {
        $user = auth()->user();
        if ($user === null || $user->hasRole('super_admin')) {
            return null;
        }

        return $user->company_id !== null ? (int) $user->company_id : null;
    }
}
