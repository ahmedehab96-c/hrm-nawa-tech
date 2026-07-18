<?php

namespace Tests\Feature;

use App\Filament\Pages\AiCommandCenter;
use App\Filament\Pages\CompanySettings;
use App\Filament\Pages\ReportsOverview;
use App\Filament\Resources\Employees\EmployeeResource;
use App\Filament\Resources\JobPostings\JobPostingResource;
use App\Filament\Resources\LeaveRequests\LeaveRequestResource;
use App\Filament\Resources\PayrollRecords\PayrollRecordResource;
use App\Models\Company;
use App\Models\User;
use Tests\TestCase;

class FilamentRoleAccessTest extends TestCase
{
    public function test_recruiter_can_only_access_recruitment_resources(): void
    {
        $company = Company::create(['name' => 'Recruiter Company', 'status' => 'active']);
        $recruiter = User::factory()->create([
            'company_id' => $company->id,
            'role' => 'recruiter',
        ]);

        $this->actingAs($recruiter);

        $this->assertTrue(JobPostingResource::canAccess());
        $this->assertFalse(EmployeeResource::canAccess());
        $this->assertFalse(LeaveRequestResource::canAccess());
        $this->assertFalse(PayrollRecordResource::canAccess());
        $this->assertFalse(CompanySettings::canAccess());
        $this->assertFalse(ReportsOverview::canAccess());
        $this->assertFalse(AiCommandCenter::canAccess());
    }

    public function test_company_admin_keeps_access_to_company_resources(): void
    {
        $company = Company::create(['name' => 'Admin Company', 'status' => 'active']);
        $admin = User::factory()->create([
            'company_id' => $company->id,
            'role' => 'company_admin',
        ]);

        $this->actingAs($admin);

        $this->assertTrue(EmployeeResource::canAccess());
        $this->assertTrue(LeaveRequestResource::canAccess());
        $this->assertTrue(PayrollRecordResource::canAccess());
        $this->assertTrue(CompanySettings::canAccess());
        $this->assertTrue(ReportsOverview::canAccess());
        $this->assertTrue(AiCommandCenter::canAccess());
    }
}
