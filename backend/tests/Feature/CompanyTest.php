<?php

namespace Tests\Feature;

use Tests\TestCase;

class CompanyTest extends TestCase
{
    public function test_admin_can_get_company_settings(): void
    {
        $h = $this->adminHeaders();

        $res = $this->getJson('/api/company', $h);
        $res->assertOk()
            ->assertJsonStructure(['id', 'name', 'status']);
        $this->assertEquals('Test Company', $res->json('name'));
    }

    public function test_admin_can_update_company_info(): void
    {
        $h = $this->adminHeaders();

        $res = $this->putJson('/api/company', [
            'name'      => 'Updated Company',
            'email'     => 'info@updated.com',
            'phone'     => '+966501234567',
            'address'   => 'Riyadh, KSA',
            'wifi_ssid' => 'Office_Network',
        ], $h);

        $res->assertOk()->assertJsonFragment(['message' => 'Settings saved']);
        $this->assertDatabaseHas('companies', [
            'id'        => $this->company->id,
            'name'      => 'Updated Company',
            'wifi_ssid' => 'Office_Network',
        ]);
    }

    public function test_employee_cannot_access_company_settings(): void
    {
        $h = $this->employeeHeaders();
        $this->getJson('/api/company', $h)->assertStatus(403);
    }

    public function test_unauthenticated_cannot_access_company_settings(): void
    {
        $this->getJson('/api/company')->assertStatus(401);
    }

    public function test_email_validation_on_update(): void
    {
        $h = $this->adminHeaders();
        $res = $this->putJson('/api/company', ['email' => 'not-an-email'], $h);
        $res->assertStatus(422);
    }
}
