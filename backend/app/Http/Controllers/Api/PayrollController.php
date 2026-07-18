<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Employee;
use App\Models\PayrollRecord;
use App\Services\PayrollGenerationService;
use Illuminate\Http\Request;
use Illuminate\Http\Response;

class PayrollController extends Controller
{
    public function index(Request $request)
    {
        $user    = $request->user();
        $month   = $request->query('month', now()->format('Y-m'));
        $perPage = min((int) $request->query('per_page', 20), 100);

        $query = PayrollRecord::query()
            ->where('company_id', $user->company_id)
            ->where('month', $month)
            ->with('employee:id,name')
            ->orderBy('id');

        if ($user->role === 'employee') {
            $query->whereHas('employee', fn ($q) => $q->where('user_id', $user->id));
        }

        $paginated = $query->paginate($perPage);

        $items = collect($paginated->items())->map(function (PayrollRecord $r) {
            return [
                'employee_id'   => $r->employee_id,
                'employee_name' => $r->employee?->name ?? '',
                'base_salary'   => $r->base_salary,
                'allowances'    => $r->allowances,
                'deductions'    => $r->deductions,
                'net_salary'    => $r->net_salary,
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

    public function generate(Request $request)
    {
        $user = $request->user();
        $validated = $request->validate([
            'month' => ['required', 'regex:/^\d{4}-\d{2}$/'],
        ]);
        $month = $validated['month'];
        $count = app(PayrollGenerationService::class)->generate((int) $user->company_id, $month);

        return response()->json([
            'message' => 'Payroll generated',
            'month' => $month,
            'count' => $count,
        ]);
    }

    public function payslipHtml(Request $request, string $employeeId): Response
    {
        $user    = $request->user();
        $month   = $request->query('month', now()->format('Y-m'));

        $employee = Employee::query()
            ->where('company_id', $user->company_id)
            ->find($employeeId);

        if (! $employee) {
            abort(404);
        }

        $record = PayrollRecord::query()
            ->where('company_id', $user->company_id)
            ->where('employee_id', $employeeId)
            ->where('month', $month)
            ->first();

        $data = [
            'employee' => $employee,
            'record'   => $record,
            'month'    => $month,
            'company'  => $user->company ?? (object) ['name' => 'HRM'],
        ];

        $html = view('payroll.payslip', $data)->render();

        return response($html, 200)
            ->header('Content-Type', 'text/html; charset=utf-8');
    }
}
