<?php

namespace Tests\Feature;

use App\Jobs\ProcessAiTask;
use App\Models\AttendanceRecord;
use App\Models\Employee;
use App\Models\LeaveRequest;
use App\Models\PayrollRecord;
use App\Models\User;
use Illuminate\Support\Facades\Queue;
use Tests\TestCase;

class PerformanceReportTest extends TestCase
{
    private function createEmployee(): Employee
    {
        $user = User::factory()->create([
            'company_id' => $this->company->id,
            'role' => 'employee',
        ]);

        return Employee::create([
            'company_id' => $this->company->id,
            'user_id' => $user->id,
            'name' => $user->name,
            'email' => $user->email,
            'department' => 'Engineering',
            'position' => 'Developer',
        ]);
    }

    public function test_performance_review_upsert_and_list(): void
    {
        $h = $this->adminHeaders();
        $employee = $this->createEmployee();

        $res = $this->postJson('/api/performance/reviews', [
            'employee_id' => $employee->id,
            'period_label' => '2026-Q2',
            'rating' => 4,
            'goals_summary' => 'Delivered sprint goals',
            'strengths' => 'Ownership',
            'improvement_areas' => 'Delegation',
        ], $h);
        $res->assertStatus(201);

        $list = $this->getJson('/api/performance/reviews?period=2026-Q2', $h);
        $list->assertOk()->assertJsonStructure(['data']);
        $this->assertCount(1, $list->json('data'));
    }

    public function test_performance_analyze_endpoint(): void
    {
        $h = $this->adminHeaders();
        $employee = $this->createEmployee();
        $this->postJson('/api/performance/reviews', [
            'employee_id' => $employee->id,
            'period_label' => '2026-Q2',
            'rating' => 4,
            'goals_summary' => 'Delivered sprint goals',
        ], $h);

        $reviewId = (int) \DB::table('performance_reviews')->value('id');
        $res = $this->postJson("/api/performance/reviews/{$reviewId}/analyze", [
            'language_code' => 'en',
        ], $h);
        $res->assertOk()->assertJsonStructure(['data' => ['ai_summary', 'status']]);
    }

    public function test_performance_analyze_queue_endpoint(): void
    {
        Queue::fake();
        $h = $this->adminHeaders();
        $employee = $this->createEmployee();
        $this->postJson('/api/performance/reviews', [
            'employee_id' => $employee->id,
            'period_label' => '2026-Q2',
            'rating' => 4,
        ], $h)->assertStatus(201);

        $reviewId = (int) \DB::table('performance_reviews')->value('id');
        $res = $this->postJson("/api/performance/reviews/{$reviewId}/analyze/queue", [
            'language_code' => 'en',
        ], $h);

        $res->assertStatus(202)->assertJsonStructure(['data' => ['task_id', 'status', 'task_type']]);
        $this->assertDatabaseHas('ai_tasks', [
            'company_id' => $this->company->id,
            'task_type' => 'performance_analyze',
            'status' => 'queued',
        ]);
        Queue::assertPushed(ProcessAiTask::class);
    }

    public function test_report_summary_endpoint(): void
    {
        $h = $this->adminHeaders();
        $employee = $this->createEmployee();
        AttendanceRecord::create([
            'company_id' => $this->company->id,
            'employee_id' => $employee->id,
            'work_date' => now()->toDateString(),
            'status' => 'present',
        ]);
        LeaveRequest::create([
            'company_id' => $this->company->id,
            'employee_id' => $employee->id,
            'type' => 'annual',
            'from_date' => now()->toDateString(),
            'to_date' => now()->toDateString(),
            'days' => 1,
            'status' => 'approved',
        ]);
        PayrollRecord::create([
            'company_id' => $this->company->id,
            'employee_id' => $employee->id,
            'month' => now()->format('Y-m'),
            'base_salary' => 1000,
            'allowances' => 100,
            'deductions' => 20,
            'net_salary' => 1080,
            'status' => 'processed',
        ]);

        $res = $this->postJson('/api/reports/summaries', [
            'period_start' => now()->subDays(30)->toDateString(),
            'period_end' => now()->toDateString(),
            'report_type' => 'hr_overview',
            'language_code' => 'en',
        ], $h);

        $res->assertOk()->assertJsonStructure([
            'data' => ['metrics', 'narrative', 'status'],
        ]);
    }

    public function test_report_summary_queue_endpoint(): void
    {
        Queue::fake();
        $h = $this->adminHeaders();

        $res = $this->postJson('/api/reports/summaries/queue', [
            'period_start' => now()->subDays(30)->toDateString(),
            'period_end' => now()->toDateString(),
            'report_type' => 'hr_overview',
            'language_code' => 'en',
        ], $h);

        $res->assertStatus(202)->assertJsonStructure(['data' => ['task_id', 'status', 'task_type']]);
        $this->assertDatabaseHas('ai_tasks', [
            'company_id' => $this->company->id,
            'task_type' => 'reports_summarize',
            'status' => 'queued',
        ]);
        Queue::assertPushed(ProcessAiTask::class);
    }
}
