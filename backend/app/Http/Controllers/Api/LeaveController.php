<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\AppNotification;
use App\Models\Employee;
use App\Models\LeaveRequest;
use App\Models\LeaveRecommendation;
use App\Services\HrInsightsService;
use Illuminate\Support\Facades\DB;
use Illuminate\Http\Request;

class LeaveController extends Controller
{
    public function __construct(private readonly HrInsightsService $hrInsightsService) {}

    private array $entitlements = [
        'annual' => 21,
        'sick' => 10,
        'emergency' => 5,
    ];

    /**
     * Returns remaining balances per employee and type.
     * Output: [employee_id => [annual=>float, sick=>float, emergency=>float]]
     */
    private function getBalancesForEmployees(int $companyId, array $employeeIds): array
    {
        $employeeIds = array_values(array_unique(array_filter($employeeIds)));
        if (empty($employeeIds)) return [];

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
            $balances[(int) $eid] = [
                'annual' => max(0.0, (float) ($this->entitlements['annual'] ?? 0) - ($usedMap[$eid]['annual'] ?? 0.0)),
                'sick' => max(0.0, (float) ($this->entitlements['sick'] ?? 0) - ($usedMap[$eid]['sick'] ?? 0.0)),
                'emergency' => max(0.0, (float) ($this->entitlements['emergency'] ?? 0) - ($usedMap[$eid]['emergency'] ?? 0.0)),
            ];
        }

        return $balances;
    }

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
        $employee = $this->resolveEmployeeForRequest($request);
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
            $employee = Employee::query()
                ->where('company_id', $user->company_id)
                ->where('user_id', $user->id)
                ->first();
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
        $balances    = $this->getBalancesForEmployees((int) $user->company_id, $employeeIds);

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
        $balances = $this->getBalancesForEmployees((int) $user->company_id, $employeeIds);

        $data = $employees->map(function (Employee $e) use ($balances) {
            $b = $balances[(int) $e->id] ?? ['annual' => 0.0, 'sick' => 0.0, 'emergency' => 0.0];
            return [
                'employee_name' => $e->name,
                'annual' => $b['annual'],
                'annual_total' => (float) ($this->entitlements['annual'] ?? 0),
                'sick' => $b['sick'],
                'sick_total' => (float) ($this->entitlements['sick'] ?? 0),
                'emergency' => $b['emergency'],
                'emergency_total' => (float) ($this->entitlements['emergency'] ?? 0),
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
        $leave->status = 'approved';
        $leave->save();
        AppNotification::query()->create([
            'company_id' => $user->company_id,
            'employee_id' => $leave->employee_id,
            'title' => 'Leave approved',
            'body' => 'Your leave request was approved.',
            'type' => 'leave',
        ]);

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
        $leave->status = 'rejected';
        $leave->save();
        AppNotification::query()->create([
            'company_id' => $user->company_id,
            'employee_id' => $leave->employee_id,
            'title' => 'Leave rejected',
            'body' => 'Your leave request was rejected.',
            'type' => 'leave',
        ]);

        return response()->json(['message' => 'Rejected', 'id' => $id]);
    }

    private function resolveEmployeeForRequest(Request $request): ?Employee
    {
        $user = $request->user();
        if ($user->role === 'employee') {
            return Employee::query()
                ->where('company_id', $user->company_id)
                ->where('user_id', $user->id)
                ->first();
        }

        $employeeId = $request->input('employee_id');
        if ($employeeId) {
            return Employee::query()->find($employeeId);
        }

        return Employee::query()
            ->where('company_id', $user->company_id)
            ->where('email', $user->email)
            ->first();
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

        $balances = $this->getBalancesForEmployees(
            (int) $user->company_id,
            [(int) $leave->employee_id],
        );
        $typeKey = strtolower(trim((string) $leave->type));
        $remaining = (float) ($balances[(int) $leave->employee_id][$typeKey] ?? 0.0);

        $recommendation = $this->hrInsightsService->buildLeaveRecommendation(
            leave: $leave,
            remainingBalanceForType: $remaining,
        );

        $record = LeaveRecommendation::query()->create([
            'company_id' => $user->company_id,
            'leave_request_id' => $leave->id,
            'generated_by' => $user->id,
            'recommended_action' => $recommendation['action'],
            'confidence_score' => $recommendation['confidence'],
            'reason' => $recommendation['reason'],
            'engine' => 'rule-engine-v1',
        ]);

        return response()->json([
            'data' => [
                'recommendation_id' => $record->id,
                'leave_request_id' => $leave->id,
                'employee_name' => $leave->employee?->name ?? '',
                'recommended_action' => $recommendation['action'],
                'confidence_score' => $recommendation['confidence'],
                'reason' => $recommendation['reason'],
                'remaining_balance' => $remaining,
                'leave_type' => $leave->type,
                'requested_days' => $leave->days,
            ],
        ]);
    }
}
