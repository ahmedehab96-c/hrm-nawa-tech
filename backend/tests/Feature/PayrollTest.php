<?php

namespace Tests\Feature;

use App\Models\Employee;
use App\Models\PayrollRecord;
use Tests\TestCase;

class PayrollTest extends TestCase
{
    private function createEmployee(array $overrides = []): Employee
    {
        return Employee::create(array_merge([
            'company_id'  => $this->company->id,
            'name'        => 'Worker',
            'email'       => 'worker@test.com',
            'base_salary' => 5000,
            'allowances'  => 500,
            'deductions'  => 100,
            'is_active'   => true,
        ], $overrides));
    }

    public function test_generate_payroll_creates_records(): void
    {
        $h = $this->adminHeaders();
        $this->createEmployee();
        $this->createEmployee(['name' => 'Worker2', 'email' => 'w2@test.com']);

        $res = $this->postJson('/api/payroll/generate', ['month' => '2025-03'], $h);

        $res->assertOk()->assertJsonFragment(['month' => '2025-03', 'count' => 2]);
        $this->assertDatabaseHas('payroll_records', [
            'company_id'  => $this->company->id,
            'month'       => '2025-03',
            'net_salary'  => 5400, // 5000 + 500 - 100
        ]);
    }

    public function test_generate_payroll_is_idempotent(): void
    {
        $h = $this->adminHeaders();
        $this->createEmployee();

        $this->postJson('/api/payroll/generate', ['month' => '2025-03'], $h)->assertOk();
        $this->postJson('/api/payroll/generate', ['month' => '2025-03'], $h)->assertOk();

        $count = PayrollRecord::where('company_id', $this->company->id)
            ->where('month', '2025-03')
            ->count();
        $this->assertEquals(1, $count);
    }

    public function test_payroll_index_returns_paginated_results(): void
    {
        $h = $this->adminHeaders();
        $emp = $this->createEmployee();
        PayrollRecord::create([
            'company_id'  => $this->company->id,
            'employee_id' => $emp->id,
            'month'       => '2025-03',
            'base_salary' => 5000,
            'allowances'  => 500,
            'deductions'  => 100,
            'net_salary'  => 5400,
            'status'      => 'processed',
        ]);

        $res = $this->getJson('/api/payroll?month=2025-03', $h);
        $res->assertOk()
            ->assertJsonStructure(['data', 'meta']);
        $this->assertCount(1, $res->json('data'));
    }

    public function test_payroll_month_filter_works(): void
    {
        $h = $this->adminHeaders();
        $emp = $this->createEmployee();
        PayrollRecord::create([
            'company_id' => $this->company->id, 'employee_id' => $emp->id,
            'month' => '2025-02', 'base_salary' => 5000, 'allowances' => 0,
            'deductions' => 0, 'net_salary' => 5000, 'status' => 'processed',
        ]);

        $res = $this->getJson('/api/payroll?month=2025-03', $h);
        $this->assertCount(0, $res->json('data'));
    }

    public function test_generate_requires_valid_month_format(): void
    {
        $h = $this->adminHeaders();
        $this->postJson('/api/payroll/generate', ['month' => '03-2025'], $h)->assertStatus(422);
    }
}
