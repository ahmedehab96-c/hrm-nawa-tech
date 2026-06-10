<?php

namespace Tests\Feature;

use App\Models\Candidate;
use App\Models\JobPosting;
use Tests\TestCase;

class RecruitmentTest extends TestCase
{
    private function makeJob(array $extra = []): JobPosting
    {
        return JobPosting::create(array_merge([
            'company_id' => $this->company->id,
            'title'      => 'Flutter Developer',
            'status'     => 'open',
        ], $extra));
    }

    public function test_list_jobs_returns_paginated_result(): void
    {
        $h = $this->adminHeaders();
        $this->makeJob();
        $this->makeJob(['title' => 'Accountant']);

        $res = $this->getJson('/api/jobs', $h);
        $res->assertOk();
        $this->assertCount(2, $res->json());
    }

    public function test_create_job(): void
    {
        $h = $this->adminHeaders();
        $res = $this->postJson('/api/jobs', [
            'title'      => 'HR Manager',
            'department' => 'HR',
            'status'     => 'open',
        ], $h);

        $res->assertStatus(201)->assertJsonFragment(['message' => 'Created']);
        $this->assertDatabaseHas('job_postings', ['title' => 'HR Manager']);
    }

    public function test_show_job_with_candidates(): void
    {
        $h = $this->adminHeaders();
        $job = $this->makeJob();
        Candidate::create([
            'company_id'     => $this->company->id,
            'job_posting_id' => $job->id,
            'name'           => 'Ahmed',
            'stage'          => 'new',
        ]);

        $res = $this->getJson("/api/jobs/{$job->id}", $h);
        $res->assertOk()
            ->assertJsonStructure(['data' => ['id', 'title', 'candidates']]);
        $this->assertCount(1, $res->json('data.candidates'));
    }

    public function test_update_job(): void
    {
        $h = $this->adminHeaders();
        $job = $this->makeJob();

        $this->putJson("/api/jobs/{$job->id}", ['status' => 'closed'], $h)->assertOk();
        $this->assertDatabaseHas('job_postings', ['id' => $job->id, 'status' => 'closed']);
    }

    public function test_delete_job_removes_candidates(): void
    {
        $h = $this->adminHeaders();
        $job = $this->makeJob();
        Candidate::create([
            'company_id'     => $this->company->id,
            'job_posting_id' => $job->id,
            'name'           => 'Sara',
            'stage'          => 'new',
        ]);

        $this->deleteJson("/api/jobs/{$job->id}", [], $h)->assertOk();
        $this->assertDatabaseMissing('job_postings', ['id' => $job->id]);
        $this->assertDatabaseMissing('candidates', ['job_posting_id' => $job->id]);
    }

    public function test_add_candidate_to_job(): void
    {
        $h = $this->adminHeaders();
        $job = $this->makeJob();

        $res = $this->postJson("/api/jobs/{$job->id}/candidates", [
            'name'  => 'Khaled',
            'email' => 'khaled@test.com',
        ], $h);

        $res->assertStatus(201);
        $this->assertDatabaseHas('candidates', ['name' => 'Khaled', 'stage' => 'new']);
    }

    public function test_update_candidate_stage(): void
    {
        $h = $this->adminHeaders();
        $job = $this->makeJob();
        $candidate = Candidate::create([
            'company_id'     => $this->company->id,
            'job_posting_id' => $job->id,
            'name'           => 'Nour',
            'stage'          => 'new',
        ]);

        $this->putJson("/api/jobs/{$job->id}/candidates/{$candidate->id}", [
            'stage' => 'interview',
        ], $h)->assertOk();

        $this->assertDatabaseHas('candidates', ['id' => $candidate->id, 'stage' => 'interview']);
    }

    public function test_delete_candidate(): void
    {
        $h = $this->adminHeaders();
        $job = $this->makeJob();
        $candidate = Candidate::create([
            'company_id'     => $this->company->id,
            'job_posting_id' => $job->id,
            'name'           => 'Omar',
            'stage'          => 'new',
        ]);

        $this->deleteJson("/api/jobs/{$job->id}/candidates/{$candidate->id}", [], $h)->assertOk();
        $this->assertDatabaseMissing('candidates', ['id' => $candidate->id]);
    }

    public function test_jobs_scoped_to_company(): void
    {
        $h = $this->adminHeaders();
        JobPosting::create(['company_id' => $this->otherCompany()->id, 'title' => 'Other', 'status' => 'open']);

        $res = $this->getJson('/api/jobs', $h);
        $this->assertCount(0, $res->json());
    }
}
