<?php

namespace Tests\Feature;

use App\Models\Employee;
use Tests\TestCase;

class EmployeeTest extends TestCase
{
    private function createEmployee(array $overrides = []): Employee
    {
        return Employee::create(array_merge([
            'company_id' => $this->company->id,
            'name'       => 'Test Employee',
            'email'      => 'emp@test.com',
        ], $overrides));
    }

    public function test_index_returns_paginated_list(): void
    {
        $h = $this->adminHeaders();
        $this->createEmployee();

        $res = $this->getJson('/api/employees', $h);

        $res->assertOk()
            ->assertJsonStructure(['data', 'meta' => ['current_page', 'last_page', 'total', 'per_page']]);

        $this->assertCount(1, $res->json('data'));
    }

    public function test_index_filters_by_company(): void
    {
        $h = $this->adminHeaders();
        // موظف من شركة أخرى
        Employee::create(['company_id' => $this->otherCompany()->id, 'name' => 'Other', 'email' => 'other@test.com']);

        $res = $this->getJson('/api/employees', $h);
        $res->assertOk();
        $this->assertCount(0, $res->json('data'));
    }

    public function test_search_filters_by_name(): void
    {
        $h = $this->adminHeaders();
        $this->createEmployee(['name' => 'Mohammed Ali',  'email' => 'mohammed@test.com']);
        $this->createEmployee(['name' => 'Sara Hassan', 'email' => 'sara@test.com']);

        $res = $this->getJson('/api/employees?search=Mohammed', $h);
        $res->assertOk();
        $this->assertCount(1, $res->json('data'));
        $this->assertEquals('Mohammed Ali', $res->json('data.0.name'));
    }

    public function test_store_creates_employee(): void
    {
        $h = $this->adminHeaders();

        $res = $this->postJson('/api/employees', [
            'name'  => 'New Hire',
            'email' => 'newhire@test.com',
        ], $h);

        $res->assertStatus(201)->assertJsonFragment(['message' => 'Created']);
        $this->assertDatabaseHas('employees', ['email' => 'newhire@test.com']);
    }

    public function test_store_requires_name_and_email(): void
    {
        $h = $this->adminHeaders();
        $this->postJson('/api/employees', [], $h)->assertStatus(422);
    }

    public function test_show_returns_employee(): void
    {
        $h = $this->adminHeaders();
        $emp = $this->createEmployee();

        $res = $this->getJson("/api/employees/{$emp->id}", $h);
        $res->assertOk()->assertJsonFragment(['email' => 'emp@test.com']);
    }

    public function test_show_returns_404_for_other_company(): void
    {
        $h = $this->adminHeaders();
        $emp = Employee::create(['company_id' => $this->otherCompany()->id, 'name' => 'X', 'email' => 'x@test.com']);

        $this->getJson("/api/employees/{$emp->id}", $h)->assertStatus(404);
    }

    public function test_update_modifies_employee(): void
    {
        $h = $this->adminHeaders();
        $emp = $this->createEmployee();

        $res = $this->putJson("/api/employees/{$emp->id}", ['name' => 'Updated Name'], $h);
        $res->assertOk();
        $this->assertDatabaseHas('employees', ['id' => $emp->id, 'name' => 'Updated Name']);
    }

    public function test_destroy_deletes_employee(): void
    {
        $h = $this->adminHeaders();
        $emp = $this->createEmployee(['email' => 'todelete@test.com']);

        $res = $this->deleteJson("/api/employees/{$emp->id}", [], $h);
        $res->assertOk();
        $this->assertDatabaseMissing('employees', ['id' => $emp->id]);
    }

    public function test_unauthenticated_request_returns_401(): void
    {
        $this->getJson('/api/employees')->assertStatus(401);
    }

    public function test_employee_role_cannot_access_index(): void
    {
        $h = $this->employeeHeaders();
        $this->getJson('/api/employees', $h)->assertStatus(403);
    }
}
