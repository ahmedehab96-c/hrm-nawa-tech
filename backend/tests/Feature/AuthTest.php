<?php

namespace Tests\Feature;

use App\Models\Company;
use App\Models\User;
use Illuminate\Support\Facades\Hash;
use Tests\TestCase;

class AuthTest extends TestCase
{
    public function test_register_creates_company_and_returns_token(): void
    {
        $res = $this->postJson('/api/register', [
            'name'                  => 'Ahmed',
            'company_name'          => 'My Company',
            'email'                 => 'ahmed@test.com',
            'password'              => 'password123',
            'password_confirmation' => 'password123',
        ]);

        $res->assertStatus(201)
            ->assertJsonStructure(['token', 'user' => ['id', 'name', 'email', 'role']]);

        $this->assertDatabaseHas('users', ['email' => 'ahmed@test.com', 'role' => 'company_admin']);
        $this->assertDatabaseHas('companies', ['name' => 'My Company']);
    }

    public function test_register_rejects_duplicate_email(): void
    {
        $company = Company::create(['name' => 'Existing', 'status' => 'active']);
        User::create([
            'company_id' => $company->id,
            'name'       => 'Existing',
            'email'      => 'exists@test.com',
            'password'   => Hash::make('password'),
            'role'       => 'company_admin',
        ]);

        $res = $this->postJson('/api/register', [
            'name'                  => 'New',
            'email'                 => 'exists@test.com',
            'password'              => 'password123',
            'password_confirmation' => 'password123',
        ]);

        $res->assertStatus(422);
    }

    public function test_login_returns_token_for_valid_credentials(): void
    {
        $company = Company::create(['name' => 'C', 'status' => 'active']);
        User::create([
            'company_id' => $company->id,
            'name'       => 'Admin',
            'email'      => 'admin@test.com',
            'password'   => Hash::make('secret123'),
            'role'       => 'company_admin',
        ]);

        $res = $this->postJson('/api/login', [
            'email'    => 'admin@test.com',
            'password' => 'secret123',
        ]);

        $res->assertOk()->assertJsonStructure(['token', 'user']);
    }

    public function test_login_fails_with_wrong_password(): void
    {
        $this->setupCompany();

        $res = $this->postJson('/api/login', [
            'email'    => $this->admin->email,
            'password' => 'wrong',
        ]);

        $res->assertStatus(401);
    }

    public function test_logout_revokes_token(): void
    {
        $headers = $this->adminHeaders();

        // قبل الخروج يجب أن يوجد token في قاعدة البيانات
        $this->assertDatabaseCount('personal_access_tokens', 1);

        $this->postJson('/api/logout', [], $headers)->assertOk();

        // بعد الخروج يجب أن يُحذف الـ token
        $this->assertDatabaseCount('personal_access_tokens', 0);
    }

    public function test_forgot_password_returns_success_for_unknown_email(): void
    {
        $res = $this->postJson('/api/forgot-password', ['email' => 'nobody@test.com']);
        // يُعيد 200 حتى لو البريد غير موجود (لأسباب أمنية)
        $res->assertOk();
    }
}
