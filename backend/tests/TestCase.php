<?php

namespace Tests;

use App\Models\Company;
use App\Models\User;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Illuminate\Foundation\Testing\TestCase as BaseTestCase;

abstract class TestCase extends BaseTestCase
{
    use RefreshDatabase;

    protected Company $company;
    protected User $admin;

    /** إنشاء شركة + أدمن وإعادة token المصادقة */
    protected function setupCompany(): string
    {
        $this->company = Company::create(['name' => 'Test Company', 'status' => 'active']);

        $this->admin = User::factory()->create([
            'company_id' => $this->company->id,
            'role'       => 'company_admin',
        ]);

        return $this->admin->createToken('test')->plainTextToken;
    }

    protected function adminHeaders(): array
    {
        $token = $this->setupCompany();
        return ['Authorization' => "Bearer {$token}"];
    }

    protected function employeeHeaders(): array
    {
        $this->setupCompany();
        $emp = User::factory()->create([
            'company_id' => $this->company->id,
            'role'       => 'employee',
        ]);
        return ['Authorization' => 'Bearer ' . $emp->createToken('test')->plainTextToken];
    }

    /** إنشاء شركة ثانية مستقلة لاختبار عزل البيانات */
    protected function otherCompany(): Company
    {
        return Company::create(['name' => 'Other Company', 'status' => 'active']);
    }
}
