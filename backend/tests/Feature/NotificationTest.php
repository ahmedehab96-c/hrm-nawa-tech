<?php

namespace Tests\Feature;

use App\Models\AppNotification;
use App\Models\Employee;
use Tests\TestCase;

class NotificationTest extends TestCase
{
    private function makeNotification(array $extra = []): AppNotification
    {
        return AppNotification::create(array_merge([
            'company_id' => $this->company->id,
            'title'      => 'Test',
            'body'       => 'Test body',
            'type'       => 'leave',
        ], $extra));
    }

    public function test_admin_lists_all_company_notifications(): void
    {
        $h = $this->adminHeaders();
        $this->makeNotification();
        $this->makeNotification(['title' => 'Second']);

        $res = $this->getJson('/api/notifications', $h);
        $res->assertOk();
        $this->assertCount(2, $res->json());
    }

    public function test_notifications_scoped_to_company(): void
    {
        $h = $this->adminHeaders();
        AppNotification::create(['company_id' => $this->otherCompany()->id, 'title' => 'Other', 'body' => 'X', 'type' => 'leave']);

        $res = $this->getJson('/api/notifications', $h);
        $res->assertOk();
        $this->assertCount(0, $res->json());
    }

    public function test_mark_single_notification_as_read(): void
    {
        $h = $this->adminHeaders();
        $n = $this->makeNotification();

        $this->assertNull($n->read_at);

        $this->patchJson("/api/notifications/{$n->id}/read", [], $h)->assertOk();

        $n->refresh();
        $this->assertNotNull($n->read_at);
    }

    public function test_mark_all_read(): void
    {
        $h = $this->adminHeaders();
        $this->makeNotification();
        $this->makeNotification();

        $this->postJson('/api/notifications/read-all', [], $h)->assertOk();

        $unread = AppNotification::where('company_id', $this->company->id)
            ->whereNull('read_at')->count();
        $this->assertEquals(0, $unread);
    }

    public function test_delete_notification(): void
    {
        $h = $this->adminHeaders();
        $n = $this->makeNotification();

        $this->deleteJson("/api/notifications/{$n->id}", [], $h)->assertOk();
        $this->assertDatabaseMissing('app_notifications', ['id' => $n->id]);
    }

    public function test_cannot_access_other_company_notification(): void
    {
        $h = $this->adminHeaders();
        $other = AppNotification::create(['company_id' => $this->otherCompany()->id, 'title' => 'X', 'body' => 'Y', 'type' => 'leave']);

        $this->patchJson("/api/notifications/{$other->id}/read", [], $h)->assertStatus(404);
    }
}
