<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\AppNotification;
use App\Models\Employee;
use App\Models\LeaveRequest;
use App\Services\LeaveBalanceService;
use App\Services\LeaveDecisionService;
use App\Services\LeaveRecommendationService;
use App\Support\Tenant\ResolvesEmployee;
use Illuminate\Http\Request;

class LeaveController extends Controller
{
    use ResolvesEmployee;

    public function __construct(private readonly LeaveBalanceService $leaveBalanceService) {}

    public function store(Request $request)
    {
        $request->validate([
            'type' => 'required|string|max:64',
            'from' => 'required|date',
            'to' => 'required|date|after_or_equal:from',
            'days' => 'required|numeric|min:0.5',
            'notes' => 'nullable|string|max:2000',
        ]);

        $user = $request->user();
        $employee = $this->resolveEmployeeForUser($request);
        if (! $employee || (int) $employee->company_id !== (int) $user->company_id) {
            return response()->json(['message' => 'Employee not found'], 404);
        }

        $leave = LeaveRequest::query()->create([
            'company_id' => $user->company_id,
            'employee_id' => $employee->id,
            'type' => $request->input('type'),
            'from_date' => $request->input('from'),
            'to_date' => $request->input('to'),
            'days' => (float) $request->input('days'),
            'notes' => $request->input('notes'),
            'status' => 'pending',
        ]);
        AppNotification::query()->create([
            'company_id' => $user->company_id,
            'employee_id' => $employee->id,
            'title' => 'Leave request submitted',
            'body' => "Your {$leave->type} leave request has been submitted.",
            'type' => 'leave',
        ]);

        return response()->json([
            'message' => 'Leave request created',
            'id' => $leave->id,
        ], 201);
    }

    public function requests(Request $request)
    {
        $user    = $request->user();
        $perPage = min((int) $request->query('per_page', 15), 100);
        $status  = $request->query('status'); // pending | approved | rejected

        $query = LeaveRequest::query()
            ->where('company_id', $user->company_id)
            ->with('employee:id,name');

        if ($user->role === 'employee') {
            $employee = $this->currentEmployee($user);
            if (! $employee) {
                return response()->json(['data' => [], 'meta' => ['current_page' => 1, 'last_page' => 1, 'total' => 0, 'per_page' => $perPage]]);
            }
            $query->where('employee_id', $employee->id);
        }

        if ($status) {
            $query->where('status', $status);
        }

        $paginated   = $query->orderByDesc('id')->paginate($perPage);
        $employeeIds = collect($paginated->items())->pluck('employee_id')->unique()->all();
        $balances    = $this->leaveBalanceService->balancesForEmployees((int) $user->company_id, $employeeIds);

        $items = collect($paginated->items())->map(function (LeaveRequest $r) use ($balances) {
            $typeKey        = strtolower(trim((string) $r->type));
            $balanceForType = $balances[(int) $r->employee_id][$typeKey] ?? 0.0;

            return [
                'id'            => $r->id,
                'employee_name' => $r->employee?->name ?? '',
                'type'          => $r->type,
                'from'          => $r->from_date?->toDateString(),
                'to'            => $r->to_date?->toDateString(),
                'days'          => $r->days,
                'balance'       => (string) $balanceForType,
                'status'        => $r->status,
            ];
        });

        return response()->json([
            'data' => $items->all(),
            'meta' => [
                'current_page' => $paginated->currentPage(),
                'last_page'    => $paginated->lastPage(),
                'per_page'     => $paginated->perPage(),
                'total'        => $paginated->total(),
            ],
        ]);
    }

    public function balances(Request $request)
    {
        $user = $request->user();
        $employees = Employee::query()
            ->where('company_id', $user->company_id)
            ->when(
                $user->role === 'employee',
                fn ($q) => $q->where('user_id', $user->id)
            )
            ->orderBy('id')
            ->get();

        $employeeIds = $employees->pluck('id')->all();
        $balances = $this->leaveBalanceService->balancesForEmployees((int) $user->company_id, $employeeIds);

        $data = $employees->map(function (Employee $e) use ($balances) {
            $b = $balances[(int) $e->id] ?? ['annual' => 0.0, 'sick' => 0.0, 'emergency' => 0.0];
            return [
                'employee_name' => $e->name,
                'annual' => $b['annual'],
                'annual_total' => $this->leaveBalanceService->entitlementFor('annual'),
                'sick' => $b['sick'],
                'sick_total' => $this->leaveBalanceService->entitlementFor('sick'),
                'emergency' => $b['emergency'],
                'emergency_total' => $this->leaveBalanceService->entitlementFor('emergency'),
            ];
        });

        return response()->json($data->all());
    }

    public function approve(Request $request, string $id)
    {
        $user = $request->user();
        $leave = LeaveRequest::query()
            ->where('company_id', $user->company_id)
            ->find($id);
        if (! $leave) {
            return response()->json(['message' => 'Not found'], 404);
        }
        app(LeaveDecisionService::class)->approve($leave);

        return response()->json(['message' => 'Approved', 'id' => $id]);
    }

    public function reject(Request $request, string $id)
    {
        $user = $request->user();
        $leave = LeaveRequest::query()
            ->where('company_id', $user->company_id)
            ->find($id);
        if (! $leave) {
            return response()->json(['message' => 'Not found'], 404);
        }
        app(LeaveDecisionService::class)->reject($leave);

        return response()->json(['message' => 'Rejected', 'id' => $id]);
    }

    public function recommend(Request $request, string $id)
    {
        $user = $request->user();
        $leave = LeaveRequest::query()
            ->where('company_id', $user->company_id)
            ->with('employee:id,name')
            ->find($id);

        if (! $leave) {
            return response()->json(['message' => 'Not found'], 404);
        }

        $result = app(LeaveRecommendationService::class)->recommend($leave, (int) $user->id);
        $recommendation = $result['recommendation'];
        $record = $result['record'];

        return response()->json([
            'data' => [
                'recommendation_id' => $record->id,
                'leave_request_id' => $leave->id,
                'employee_name' => $leave->employee?->name ?? '',
                'recommended_action' => $recommendation['action'],
                'confidence_score' => $recommendation['confidence'],
                'reason' => $recommendation['reason'],
                'remaining_balance' => $result['remaining_balance'],
                'leave_type' => $leave->type,
                'requested_days' => $leave->days,
            ],
        ]);
    }
}
