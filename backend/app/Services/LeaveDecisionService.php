<?php

namespace App\Services;

use App\Models\AppNotification;
use App\Models\Employee;
use App\Models\LeaveRequest;
use App\Models\User;
use App\Notifications\LeaveApprovedNotification;
use App\Notifications\LeaveRejectedNotification;

class LeaveDecisionService
{
    public function __construct(private readonly FcmPushService $fcmPushService) {}

    public function approve(LeaveRequest $leave): LeaveRequest
    {
        $leave->status = 'approved';
        $leave->save();

        AppNotification::query()->create([
            'company_id' => $leave->company_id,
            'employee_id' => $leave->employee_id,
            'title' => 'Leave approved',
            'body' => 'Your leave request was approved.',
            'type' => 'leave',
        ]);

        $this->notifyEmployeeByEmail($leave, approved: true);
        $this->pushEmployeeNotification($leave, 'Leave approved', 'Your leave request was approved.', 'leave');

        return $leave;
    }

    public function reject(LeaveRequest $leave): LeaveRequest
    {
        $leave->status = 'rejected';
        $leave->save();

        AppNotification::query()->create([
            'company_id' => $leave->company_id,
            'employee_id' => $leave->employee_id,
            'title' => 'Leave rejected',
            'body' => 'Your leave request was rejected.',
            'type' => 'leave',
        ]);

        $this->notifyEmployeeByEmail($leave, approved: false);
        $this->pushEmployeeNotification($leave, 'Leave rejected', 'Your leave request was rejected.', 'leave');

        return $leave;
    }

    private function notifyEmployeeByEmail(LeaveRequest $leave, bool $approved): void
    {
        $employee = Employee::query()->find($leave->employee_id);
        if ($employee === null || ! filled($employee->email)) {
            return;
        }

        $user = User::query()
            ->where('company_id', $leave->company_id)
            ->where('email', $employee->email)
            ->where('role', 'employee')
            ->first();

        if ($user === null) {
            return;
        }

        $user->notify($approved
            ? new LeaveApprovedNotification($leave)
            : new LeaveRejectedNotification($leave));
    }

    private function pushEmployeeNotification(
        LeaveRequest $leave,
        string $title,
        string $body,
        string $type,
    ): void {
        $employee = Employee::query()->find($leave->employee_id);
        if ($employee === null || ! filled($employee->email)) {
            return;
        }

        $user = User::query()
            ->where('company_id', $leave->company_id)
            ->where('email', $employee->email)
            ->where('role', 'employee')
            ->first();

        if ($user === null) {
            return;
        }

        $this->fcmPushService->sendToUser($user, $title, $body, [
            'type' => $type,
            'leave_request_id' => (string) $leave->id,
        ]);
    }
}
