<?php

namespace Database\Seeders;

use App\Models\Company;
use App\Models\Employee;
use App\Models\AttendanceRecord;
use App\Models\LeaveRequest;
use App\Models\PayrollRecord;
use App\Models\User;
use Illuminate\Support\Facades\Hash;
use Illuminate\Database\Console\Seeds\WithoutModelEvents;
use Illuminate\Database\Seeder;
use Illuminate\Support\Carbon;

class DatabaseSeeder extends Seeder
{
    use WithoutModelEvents;

    /**
     * Seed the application's database.
     */
    public function run(): void
    {
        // Seed شركة + أدمن + 10 موظفين مربوطين بقاعدة البيانات
        // بحيث يمكن عرضهم ثم حذفهم/تعديلهم لاحقًا من واجهة الأدمن.

        $company = Company::query()->firstOrCreate(
            ['name' => 'Demo Company'],
            ['status' => 'active']
        );

        $adminEmail = 'admin@demo.com';
        $admin = User::query()->updateOrCreate(
            ['email' => $adminEmail],
            [
                'company_id' => $company->id,
                'name' => 'Demo Admin',
                'role' => 'company_admin',
                'password' => Hash::make('Admin12345!'),
            ]
        );

        $employeePassword = 'Employee12345!';

        $rows = [
            [
                'name' => 'Mohamed Ahmed',
                'email' => 'emp01@demo.com',
                'department' => 'Sales',
                'position' => 'Sales coordinator',
                'phone' => '+966501000001',
                'birth_date' => '1990-01-15',
                'hire_date' => '2024-01-01',
                'coverage_start' => '2024-01-01',
                'coverage_end' => '2024-12-31',
                'insurance_type' => 'health',
                'insurance_policy_number' => 'POL-2026-001',
                'base_salary' => 6000,
                'allowances' => 800,
                'deductions' => 200,
            ],
            [
                'name' => 'Sara Ali',
                'email' => 'emp02@demo.com',
                'department' => 'Finance',
                'position' => 'Accountant',
                'phone' => '+966501000002',
                'birth_date' => '1992-03-08',
                'hire_date' => '2024-02-01',
                'coverage_start' => '2024-01-01',
                'coverage_end' => '2024-12-31',
                'insurance_type' => 'health',
                'insurance_policy_number' => 'POL-2026-002',
                'base_salary' => 5200,
                'allowances' => 600,
                'deductions' => 180,
            ],
            [
                'name' => 'Khalid Hassan',
                'email' => 'emp03@demo.com',
                'department' => 'IT',
                'position' => 'Developer',
                'phone' => '+966501000003',
                'birth_date' => '1991-07-22',
                'hire_date' => '2023-11-01',
                'coverage_start' => '2024-01-01',
                'coverage_end' => '2024-12-31',
                'insurance_type' => 'health',
                'insurance_policy_number' => 'POL-2026-003',
                'base_salary' => 7200,
                'allowances' => 1000,
                'deductions' => 250,
            ],
            [
                'name' => 'Noor Mohammed',
                'email' => 'emp04@demo.com',
                'department' => 'HR',
                'position' => 'HR specialist',
                'phone' => '+966501000004',
                'birth_date' => '1993-05-14',
                'hire_date' => '2024-03-01',
                'coverage_start' => '2024-01-01',
                'coverage_end' => '2024-12-31',
                'insurance_type' => 'health',
                'insurance_policy_number' => 'POL-2026-004',
                'base_salary' => 4800,
                'allowances' => 400,
                'deductions' => 120,
            ],
            [
                'name' => 'Ahmed Manager',
                'email' => 'emp05@demo.com',
                'department' => 'Operations',
                'position' => 'Operations manager',
                'phone' => '+966501000005',
                'birth_date' => '1989-09-30',
                'hire_date' => '2022-10-01',
                'coverage_start' => '2024-01-01',
                'coverage_end' => '2024-12-31',
                'insurance_type' => 'health',
                'insurance_policy_number' => 'POL-2026-005',
                'base_salary' => 9000,
                'allowances' => 1500,
                'deductions' => 500,
            ],
            [
                'name' => 'Hussein Ali',
                'email' => 'emp06@demo.com',
                'department' => 'Support',
                'position' => 'Customer support',
                'phone' => '+966501000006',
                'birth_date' => '1994-02-18',
                'hire_date' => '2024-04-01',
                'coverage_start' => '2024-01-01',
                'coverage_end' => '2024-12-31',
                'insurance_type' => 'health',
                'insurance_policy_number' => 'POL-2026-006',
                'base_salary' => 4200,
                'allowances' => 300,
                'deductions' => 90,
            ],
            [
                'name' => 'Fatima Hassan',
                'email' => 'emp07@demo.com',
                'department' => 'Marketing',
                'position' => 'Marketing specialist',
                'phone' => '+966501000007',
                'birth_date' => '1995-08-09',
                'hire_date' => '2024-05-01',
                'coverage_start' => '2024-01-01',
                'coverage_end' => '2024-12-31',
                'insurance_type' => 'health',
                'insurance_policy_number' => 'POL-2026-007',
                'base_salary' => 5000,
                'allowances' => 550,
                'deductions' => 150,
            ],
            [
                'name' => 'Omar Saleh',
                'email' => 'emp08@demo.com',
                'department' => 'Engineering',
                'position' => 'Backend engineer',
                'phone' => '+966501000008',
                'birth_date' => '1990-12-01',
                'hire_date' => '2023-12-01',
                'coverage_start' => '2024-01-01',
                'coverage_end' => '2024-12-31',
                'insurance_type' => 'health',
                'insurance_policy_number' => 'POL-2026-008',
                'base_salary' => 8000,
                'allowances' => 900,
                'deductions' => 300,
            ],
            [
                'name' => 'Rania Ahmed',
                'email' => 'emp09@demo.com',
                'department' => 'Design',
                'position' => 'UI/UX designer',
                'phone' => '+966501000009',
                'birth_date' => '1992-06-25',
                'hire_date' => '2024-06-01',
                'coverage_start' => '2024-01-01',
                'coverage_end' => '2024-12-31',
                'insurance_type' => 'health',
                'insurance_policy_number' => 'POL-2026-009',
                'base_salary' => 5600,
                'allowances' => 650,
                'deductions' => 200,
            ],
            [
                'name' => 'Yousef Noor',
                'email' => 'emp10@demo.com',
                'department' => 'QA',
                'position' => 'QA engineer',
                'phone' => '+966501000010',
                'birth_date' => '1991-11-11',
                'hire_date' => '2024-07-01',
                'coverage_start' => '2024-01-01',
                'coverage_end' => '2024-12-31',
                'insurance_type' => 'health',
                'insurance_policy_number' => 'POL-2026-010',
                'base_salary' => 6100,
                'allowances' => 700,
                'deductions' => 220,
            ],
        ];

        foreach ($rows as $row) {
            $appUser = User::query()->updateOrCreate(
                ['email' => $row['email']],
                [
                    'company_id' => $company->id,
                    'name' => $row['name'],
                    'role' => 'employee',
                    'password' => Hash::make($employeePassword),
                ]
            );

            $employee = Employee::query()->updateOrCreate(
                [
                    'company_id' => $company->id,
                    'email' => $row['email'],
                ],
                [
                    'user_id' => $appUser->id,
                    'name' => $row['name'],
                    'phone' => $row['phone'],
                    'department' => $row['department'],
                    'position' => $row['position'],
                    'is_active' => true,
                    'birth_date' => $row['birth_date'],
                    'hire_date' => $row['hire_date'],
                    'coverage_start' => $row['coverage_start'],
                    'coverage_end' => $row['coverage_end'],
                    'insurance_type' => $row['insurance_type'],
                    'insurance_policy_number' => $row['insurance_policy_number'],
                    'base_salary' => $row['base_salary'],
                    'allowances' => $row['allowances'],
                    'deductions' => $row['deductions'],
                ]
            );

            // تأكيد ربط user_id مع app user
            if ((int) $employee->user_id !== (int) $appUser->id) {
                $employee->user_id = $appUser->id;
                $employee->save();
            }
        }

        // ==== Seed data for marketing demo (leave + attendance + payroll) ====
        // الهدف: صفحات الإجازات والحضور والرواتب تظهر مليانة عند أول تشغيل.
        $employees = Employee::query()->where('company_id', $company->id)->get();
        if ($employees->isNotEmpty()) {
            $now = Carbon::now();

            // Attendance last 7 days
            foreach ($employees as $idx => $employee) {
                for ($d = 0; $d < 7; $d++) {
                    $workDate = $now->copy()->subDays(6 - $d)->toDateString();

                    $isAbsent = (($idx + $d) % 9) === 0;
                    $isLate = !$isAbsent && (($idx + $d) % 3) === 0;

                    $checkInAt = $isAbsent ? null : $now->copy()->subDays(6 - $d)->setTime(8, $isLate ? 20 : 0);
                    $checkOutAt = $isAbsent ? null : $now->copy()->subDays(6 - $d)->setTime(17, 0);
                    $status = $isAbsent ? 'absent' : ($isLate ? 'late' : 'present');

                    AttendanceRecord::query()->updateOrCreate(
                        [
                            'company_id' => $company->id,
                            'employee_id' => $employee->id,
                            'work_date' => $workDate,
                        ],
                        [
                            'check_in_at' => $checkInAt,
                            'check_out_at' => $checkOutAt,
                            'status' => $status,
                        ]
                    );
                }

                // Leave requests (fixed demo dates) to drive real balances
                $annualFrom = Carbon::createFromDate(2026, 3, 5)->addDays($idx);
                $annualTo = $annualFrom->copy()->addDays(1);
                LeaveRequest::query()->updateOrCreate(
                    [
                        'company_id' => $company->id,
                        'employee_id' => $employee->id,
                        'type' => 'annual',
                        'from_date' => $annualFrom->toDateString(),
                        'to_date' => $annualTo->toDateString(),
                    ],
                    [
                        'days' => 2,
                        'notes' => 'Demo annual leave',
                        'status' => 'approved',
                    ]
                );

                $sickFrom = Carbon::createFromDate(2026, 3, 15)->addDays($idx % 5);
                LeaveRequest::query()->updateOrCreate(
                    [
                        'company_id' => $company->id,
                        'employee_id' => $employee->id,
                        'type' => 'sick',
                        'from_date' => $sickFrom->toDateString(),
                        'to_date' => $sickFrom->toDateString(),
                    ],
                    [
                        'days' => 1,
                        'notes' => 'Demo sick leave',
                        'status' => 'pending',
                    ]
                );

                $emergencyFrom = Carbon::createFromDate(2026, 3, 25)->addDays($idx % 3);
                LeaveRequest::query()->updateOrCreate(
                    [
                        'company_id' => $company->id,
                        'employee_id' => $employee->id,
                        'type' => 'emergency',
                        'from_date' => $emergencyFrom->toDateString(),
                        'to_date' => $emergencyFrom->toDateString(),
                    ],
                    [
                        'days' => 1,
                        'notes' => 'Demo emergency leave',
                        'status' => 'rejected',
                    ]
                );
            }

            // Payroll: generate demo records for current + previous month
            $months = [$now->copy()->format('Y-m'), $now->copy()->subMonth()->format('Y-m')];
            foreach ($employees as $employee) {
                foreach ($months as $month) {
                    $base = (float) ($employee->base_salary ?? 0);
                    $allowances = (float) ($employee->allowances ?? 0);
                    $deductions = (float) ($employee->deductions ?? 0);
                    $net = $base + $allowances - $deductions;

                    PayrollRecord::query()->updateOrCreate(
                        [
                            'company_id' => $company->id,
                            'employee_id' => $employee->id,
                            'month' => $month,
                        ],
                        [
                            'base_salary' => $base,
                            'allowances' => $allowances,
                            'deductions' => $deductions,
                            'net_salary' => $net,
                            'status' => 'processed',
                        ]
                    );
                }
            }
        }
    }
}
