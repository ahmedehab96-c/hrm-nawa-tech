<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\AttendanceRecord;
use App\Models\Employee;
use Illuminate\Http\Request;

class AttendanceController extends Controller
{
    public function index(Request $request)
    {
        $user = $request->user();
        $date = $request->query('date', now()->toDateString());

        $query = AttendanceRecord::query()
            ->where('company_id', $user->company_id)
            ->whereDate('work_date', $date)
            ->with('employee:id,name')
            ->orderBy('id');

        if ($user->role === 'employee') {
            $employee = Employee::query()
                ->where('company_id', $user->company_id)
                ->where('user_id', $user->id)
                ->first();
            if (! $employee) {
                return response()->json([]);
            }
            $query->where('employee_id', $employee->id);
        }

        $rows = $query->get();

        $data = $rows->map(function (AttendanceRecord $r) {
            return [
                'id'            => $r->id,
                'employee_id'   => $r->employee_id,
                'employee_name' => $r->employee?->name ?? '',
                'check_in'      => $r->check_in_at?->format('H:i'),
                'check_out'     => $r->check_out_at?->format('H:i'),
                'status'        => $r->status,
                'work_date'     => $r->work_date?->toDateString(),
            ];
        });

        return response()->json($data->all());
    }

    public function update(Request $request, string $id)
    {
        $user = $request->user();

        $record = AttendanceRecord::query()
            ->where('company_id', $user->company_id)
            ->find($id);

        if (! $record) {
            return response()->json(['message' => 'Record not found'], 404);
        }

        $request->validate([
            'check_in'  => 'nullable|date_format:H:i',
            'check_out' => 'nullable|date_format:H:i',
            'status'    => 'sometimes|in:present,late,absent',
        ]);

        $date = $record->work_date?->toDateString() ?? now()->toDateString();

        if ($request->has('check_in')) {
            $record->check_in_at = $request->input('check_in')
                ? "{$date} {$request->input('check_in')}:00"
                : null;
        }
        if ($request->has('check_out')) {
            $record->check_out_at = $request->input('check_out')
                ? "{$date} {$request->input('check_out')}:00"
                : null;
        }
        if ($request->has('status')) {
            $record->status = $request->input('status');
        }
        $record->save();

        return response()->json(['message' => 'Updated']);
    }

    public function store(Request $request)
    {
        $user = $request->user();

        $request->validate([
            'employee_id' => 'required|integer',
            'date'        => 'required|date_format:Y-m-d',
            'check_in'    => 'nullable|date_format:H:i',
            'check_out'   => 'nullable|date_format:H:i',
            'status'      => 'required|in:present,late,absent',
        ]);

        $employee = Employee::query()
            ->where('company_id', $user->company_id)
            ->find($request->input('employee_id'));

        if (! $employee) {
            return response()->json(['message' => 'Employee not found'], 404);
        }

        $date = $request->input('date');

        $record = AttendanceRecord::query()->updateOrCreate(
            [
                'company_id'  => $user->company_id,
                'employee_id' => $employee->id,
                'work_date'   => $date,
            ],
            [
                'check_in_at'  => $request->input('check_in')  ? "{$date} {$request->input('check_in')}:00"  : null,
                'check_out_at' => $request->input('check_out') ? "{$date} {$request->input('check_out')}:00" : null,
                'status'       => $request->input('status'),
            ]
        );

        return response()->json(['message' => 'Saved', 'id' => $record->id], 201);
    }

    public function checkIn(Request $request)
    {
        $user = $request->user();
        $employee = $this->resolveEmployeeForAction($request);
        if (! $employee || (int) $employee->company_id !== (int) $user->company_id) {
            return response()->json(['message' => 'Employee not found'], 404);
        }

        $now = now();
        $record = AttendanceRecord::query()
            ->where('company_id', $user->company_id)
            ->where('employee_id', $employee->id)
            ->whereDate('work_date', $now->toDateString())
            ->first()
            ?? AttendanceRecord::create([
                'company_id'  => $user->company_id,
                'employee_id' => $employee->id,
                'work_date'   => $now->toDateString(),
                'status'      => 'present',
            ]);

        $record->check_in_at = $now;
        $record->status = $now->format('H:i') > '09:00' ? 'late' : 'present';
        $record->save();

        return response()->json(['message' => 'Checked in', 'at' => $now->toIso8601String()]);
    }

    public function checkOut(Request $request)
    {
        $user = $request->user();
        $employee = $this->resolveEmployeeForAction($request);
        if (! $employee || (int) $employee->company_id !== (int) $user->company_id) {
            return response()->json(['message' => 'Employee not found'], 404);
        }

        $now = now();
        $record = AttendanceRecord::query()
            ->where('company_id', $user->company_id)
            ->where('employee_id', $employee->id)
            ->whereDate('work_date', $now->toDateString())
            ->first()
            ?? AttendanceRecord::create([
                'company_id'  => $user->company_id,
                'employee_id' => $employee->id,
                'work_date'   => $now->toDateString(),
                'status'      => 'present',
            ]);

        $record->check_out_at = $now;
        if (! $record->check_in_at) {
            $record->check_in_at = $now;
        }
        $record->save();

        return response()->json(['message' => 'Checked out', 'at' => $now->toIso8601String()]);
    }

    private function resolveEmployeeForAction(Request $request): ?Employee
    {
        $user = $request->user();
        if ($user->role === 'employee') {
            return Employee::query()
                ->where('company_id', $user->company_id)
                ->where('user_id', $user->id)
                ->first();
        }

        $employeeId = $request->input('employee_id');
        if (! $employeeId) {
            return null;
        }

        return Employee::query()->find($employeeId);
    }
}
