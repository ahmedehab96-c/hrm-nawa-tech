<?php

namespace Tests\Feature;

use App\Models\Company;
use App\Models\DevicePushToken;
use App\Models\User;
use App\Services\FcmPushService;
use Illuminate\Support\Facades\Config;
use Illuminate\Support\Facades\Http;
use Illuminate\Support\Facades\URL;
use Tests\TestCase;

class PushAndVerificationTest extends TestCase
{
    public function test_employee_can_register_device_token(): void
    {
        $company = Company::query()->create(['name' => 'Co', 'status' => 'active']);
        $employee = User::factory()->create([
            'company_id' => $company->id,
            'role' => 'employee',
            'email_verified_at' => now(),
        ]);
        $token = $employee->createToken('test')->plainTextToken;

        $res = $this->postJson('/api/device-tokens', [
            'token' => 'fcm-token-123',
            'platform' => 'android',
        ], ['Authorization' => "Bearer {$token}"]);

        $res->assertOk();
        $this->assertDatabaseHas('device_push_tokens', [
            'user_id' => $employee->id,
            'token' => 'fcm-token-123',
            'platform' => 'android',
        ]);
    }

    public function test_employee_can_remove_device_token(): void
    {
        $company = Company::query()->create(['name' => 'Co', 'status' => 'active']);
        $employee = User::factory()->create([
            'company_id' => $company->id,
            'role' => 'employee',
            'email_verified_at' => now(),
        ]);
        DevicePushToken::query()->create([
            'user_id' => $employee->id,
            'token' => 'fcm-token-123',
            'platform' => 'ios',
        ]);
        $token = $employee->createToken('test')->plainTextToken;

        $this->deleteJson('/api/device-tokens', [
            'token' => 'fcm-token-123',
        ], ['Authorization' => "Bearer {$token}"])->assertOk();

        $this->assertDatabaseMissing('device_push_tokens', [
            'user_id' => $employee->id,
            'token' => 'fcm-token-123',
        ]);
    }

    public function test_fcm_push_noops_without_server_key(): void
    {
        Config::set('services.fcm.server_key', '');

        $company = Company::query()->create(['name' => 'Co', 'status' => 'active']);
        $employee = User::factory()->create([
            'company_id' => $company->id,
            'role' => 'employee',
        ]);
        DevicePushToken::query()->create([
            'user_id' => $employee->id,
            'token' => 'fcm-token-123',
            'platform' => 'android',
        ]);

        Http::fake();

        $sent = app(FcmPushService::class)->sendToUser($employee, 'Title', 'Body');

        $this->assertFalse($sent);
        Http::assertNothingSent();
    }

    public function test_fcm_push_sends_when_configured(): void
    {
        Config::set('services.fcm.server_key', 'test-server-key');

        $company = Company::query()->create(['name' => 'Co', 'status' => 'active']);
        $employee = User::factory()->create([
            'company_id' => $company->id,
            'role' => 'employee',
        ]);
        DevicePushToken::query()->create([
            'user_id' => $employee->id,
            'token' => 'fcm-token-123',
            'platform' => 'android',
        ]);

        Http::fake([
            'fcm.googleapis.com/*' => Http::response(['success' => 1], 200),
        ]);

        $sent = app(FcmPushService::class)->sendToUser($employee, 'Leave approved', 'Done', [
            'type' => 'leave',
        ]);

        $this->assertTrue($sent);
        Http::assertSentCount(1);
    }

    public function test_signed_email_verification_link_verifies_user(): void
    {
        $this->setupCompany();
        $this->admin->forceFill(['email_verified_at' => null])->save();

        $url = URL::temporarySignedRoute(
            'verification.verify',
            now()->addHour(),
            [
                'id' => $this->admin->id,
                'hash' => sha1($this->admin->getEmailForVerification()),
            ],
        );

        $path = parse_url($url, PHP_URL_PATH);
        $query = [];
        parse_str(parse_url($url, PHP_URL_QUERY) ?? '', $query);

        $res = $this->getJson($path.'?'.http_build_query($query));

        $res->assertOk()->assertJsonFragment(['email_verified' => true]);
        $this->assertTrue($this->admin->fresh()->hasVerifiedEmail());
    }
}
