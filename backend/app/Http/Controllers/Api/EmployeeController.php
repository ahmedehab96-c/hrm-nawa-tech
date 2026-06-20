<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Employee;
use App\Models\Role;
use App\Models\User;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Hash;

class EmployeeController extends Controller
{
    private static function appLoginEnabledForEmail(string $email, int $companyId): bool
    {
        return User::query()
            ->where('company_id', $companyId)
            ->where('email', $email)
            ->where('role', 'employee')
            ->exists();
    }

    public function index(Request $request)
    {
        $user       = $request->user();
        $perPage    = min((int) $request->query('per_page', 20), 100);
        // تنظيف مدخلات البحث لمنع LIKE injection (% و _)
        $rawSearch  = $request->query('search', '');
        $search     = strlen((string) $rawSearch) > 0
            ? str_replace(['%', '_', '\\'], ['\\%', '\\_', '\\\\'], (string) $rawSearch)
            : null;
        $department = $request->query('department');

        $query = Employee::query()
            ->where('company_id', $user->company_id)
            ->orderBy('name');

        if ($search) {
            $like = '%' . $search . '%';
            $query->where(function ($q) use ($like) {
                $q->where('name', 'like', $like)
                  ->orWhere('email', 'like', $like)
                  ->orWhere('position', 'like', $like);
            });
        }

        if ($department) {
            $query->where('department', $department);
        }

        $paginated = $query->paginate($perPage);

        $items = collect($paginated->items())->map(function (Employee $e) use ($user) {
            return [
                'id'                      => $e->id,
                'name'                    => $e->name,
                'email'                   => $e->email,
                'department'              => $e->department,
                'position'                => $e->position,
                'is_active'               => (bool) $e->is_active,
                'phone'                   => $e->phone,
                'birth_date'              => $e->birth_date?->toDateString(),
                'hire_date'               => $e->hire_date?->toDateString(),
                'insurance_type'          => $e->insurance_type,
                'insurance_policy_number' => $e->insurance_policy_number,
                'coverage_start'          => $e->coverage_start?->toDateString(),
                'coverage_end'            => $e->coverage_end?->toDateString(),
                'base_salary'             => $e->base_salary,
                'allowances'              => $e->allowances,
                'deductions'              => $e->deductions,
                'app_login_enabled'       => self::appLoginEnabledForEmail($e->email, (int) $user->company_id),
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

    public function show(Request $request, string $id)
    {
        $user = $request->user();

        $e = Employee::query()
            ->where('company_id', $user->company_id)
            ->find($id);
        if (! $e) {
            return response()->json(['message' => 'Not found'], 404);
        }

        $data = [
            'id' => $e->id,
            'name' => $e->name,
            'email' => $e->email,
            'department' => $e->department,
            'position' => $e->position,
            'is_active' => (bool) $e->is_active,
            'phone' => $e->phone,
            'birth_date' => $e->birth_date?->toDateString(),
            'hire_date' => $e->hire_date?->toDateString(),
            'insurance_type' => $e->insurance_type,
            'insurance_policy_number' => $e->insurance_policy_number,
            'coverage_start' => $e->coverage_start?->toDateString(),
            'coverage_end' => $e->coverage_end?->toDateString(),
            'base_salary' => $e->base_salary,
            'allowances' => $e->allowances,
            'deductions' => $e->deductions,
            'app_login_enabled' => self::appLoginEnabledForEmail($e->email, (int) $user->company_id),
        ];

        return response()->json(['data' => $data]);
    }

    public function store(Request $request)
    {
        $request->validate([
            'name' => 'required|string|max:255',
            'email' => 'required|email',
            'phone' => 'nullable|string|max:64',
            'birth_date' => 'nullable|date',
            'department' => 'nullable|string|max:255',
            'position' => 'nullable|string|max:255',
            'hire_date' => 'nullable|date',
            'is_active' => 'sometimes|boolean',
            'coverage_start' => 'nullable|date',
            'coverage_end' => 'nullable|date|after_or_equal:coverage_start',
            'base_salary' => 'nullable|numeric|min:0',
            'allowances' => 'nullable|numeric|min:0',
            'deductions' => 'nullable|numeric|min:0',
            'enable_app_login' => 'sometimes|boolean',
            'password' => 'required_if:enable_app_login,true|nullable|string|min:8|confirmed',
        ]);

        $user = $request->user();

        $employee = Employee::query()->create([
            'company_id' => $user->company_id,
            'name' => $request->input('name'),
            'email' => $request->input('email'),
            'phone' => $request->input('phone'),
            'birth_date' => $request->input('birth_date'),
            'department' => $request->input('department'),
            'position' => $request->input('position'),
            'hire_date' => $request->input('hire_date'),
            'is_active' => $request->boolean('is_active', true),
            'insurance_type' => $request->input('insurance_type'),
            'insurance_policy_number' => $request->input('insurance_policy_number'),
            'coverage_start' => $request->input('coverage_start'),
            'coverage_end' => $request->input('coverage_end'),
            'base_salary' => $request->input('base_salary', 0),
            'allowances' => $request->input('allowances', 0),
            'deductions' => $request->input('deductions', 0),
        ]);

        if ($request->boolean('enable_app_login')) {
            $appUser = User::create([
                'company_id' => $user->company_id,
                'name' => $employee->name,
                'email' => $employee->email,
                'password' => Hash::make($request->input('password')),
                'role' => 'employee',
            ]);
            $this->syncEmployeeRole($appUser);
            $employee->user_id = $appUser->id;
            $employee->save();
        }

        return response()->json(['message' => 'Created', 'id' => $employee->id], 201);
    }

    public function update(Request $request, string $id)
    {
        $user = $request->user();

        $employee = Employee::query()
            ->where('company_id', $user->company_id)
            ->find($id);
        if (! $employee) {
            return response()->json(['message' => 'Not found'], 404);
        }

        $request->validate([
            'name' => 'sometimes|string|max:255',
            'email' => 'sometimes|email',
            'phone' => 'nullable|string|max:64',
            'birth_date' => 'nullable|date',
            'department' => 'nullable|string|max:255',
            'position' => 'nullable|string|max:255',
            'hire_date' => 'nullable|date',
            'is_active' => 'sometimes|boolean',
            'coverage_start' => 'nullable|date',
            'coverage_end' => 'nullable|date|after_or_equal:coverage_start',
            'base_salary' => 'nullable|numeric|min:0',
            'allowances' => 'nullable|numeric|min:0',
            'deductions' => 'nullable|numeric|min:0',
            'insurance_policy_number' => 'nullable|string|max:255',
        ]);

        $employee->fill($request->only([
            'name',
            'email',
            'phone',
            'birth_date',
            'department',
            'position',
            'hire_date',
            'coverage_start',
            'coverage_end',
            'base_salary',
            'allowances',
            'deductions',
            'insurance_policy_number',
        ]));
        if ($request->has('is_active')) {
            $employee->is_active = $request->boolean('is_active');
        }
        $employee->save();

        return response()->json(['message' => 'Updated']);
    }

    public function destroy(Request $request, string $id)
    {
        $user = $request->user();

        $employee = Employee::query()
            ->where('company_id', $user->company_id)
            ->find($id);
        if (! $employee) {
            return response()->json(['message' => 'Not found'], 404);
        }

        // حماية: لا تسمح للأدمن بحذف سجله المرتبط بحسابه أو نفس بريده
        if (
            ($employee->user_id !== null && (int) $employee->user_id === (int) $user->id) ||
            (strtolower((string) $employee->email) === strtolower((string) $user->email))
        ) {
            return response()->json(['message' => 'Cannot delete current admin user'], 409);
        }

        User::query()
            ->where('company_id', $user->company_id)
            ->where('email', $employee->email)
            ->where('role', 'employee')
            ->delete();

        $employee->delete();

        return response()->json(['message' => 'Deleted']);
    }

    /**
     * تمكين/تعطيل دخول تطبيق الموظف أو تغيير كلمة المرور (يُنفَّذ من حساب أدمن عبر Sanctum).
     */
    public function setAppAccess(Request $request, string $id)
    {
        $request->validate([
            'enabled' => 'required|boolean',
            'password' => 'required_if:enabled,true|string|min:8|confirmed',
        ]);

        $user = $request->user();

        $emp = Employee::query()
            ->where('company_id', $user->company_id)
            ->find($id);
        if (! $emp) {
            return response()->json(['message' => 'Employee not found'], 404);
        }

        $email = $emp->email;

        if (! $request->boolean('enabled')) {
            User::query()
                ->where('company_id', $user->company_id)
                ->where('email', $email)
                ->where('role', 'employee')
                ->delete();
            $emp->user_id = null;
            $emp->save();

            return response()->json(['message' => 'App login disabled']);
        }

        $appUser = User::updateOrCreate(
            [
                'company_id' => $user->company_id,
                'email' => $email,
            ],
            [
                'name' => $emp->name,
                'password' => Hash::make($request->input('password')),
                'role' => 'employee',
            ]
        );
        $this->syncEmployeeRole($appUser);
        $emp->user_id = $appUser->id;
        $emp->save();

        return response()->json(['message' => 'App login updated']);
    }

    /// ملف الموظف الحالي — GET `/employees/me` (لـ user.role = employee)
    public function me(Request $request)
    {
        $user = $request->user();

        $employee = Employee::query()
            ->where('company_id', $user->company_id)
            ->where('user_id', $user->id)
            ->first();

        if (! $employee) {
            return response()->json(['message' => 'Employee not found'], 404);
        }

        $data = [
            'id' => $employee->id,
            'name' => $employee->name,
            'email' => $employee->email,
            'department' => $employee->department,
            'position' => $employee->position,
            'is_active' => (bool) $employee->is_active,
            'phone' => $employee->phone,
            'birth_date' => $employee->birth_date?->toDateString(),
            'hire_date' => $employee->hire_date?->toDateString(),
            'insurance_type' => $employee->insurance_type,
            'insurance_policy_number' => $employee->insurance_policy_number,
            'coverage_start' => $employee->coverage_start?->toDateString(),
            'coverage_end' => $employee->coverage_end?->toDateString(),
            'base_salary' => $employee->base_salary,
            'allowances' => $employee->allowances,
            'deductions' => $employee->deductions,
            'app_login_enabled' => self::appLoginEnabledForEmail(
                $employee->email,
                (int) $user->company_id,
            ),
        ];

        return response()->json(['data' => $data]);
    }

    private function syncEmployeeRole(User $user): void
    {
        $role = Role::query()->where('name', 'employee')->first();
        if (! $role) {
            return;
        }
        $user->roles()->syncWithoutDetaching([$role->id]);
    }
}
