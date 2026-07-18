<?php

namespace App\Services;

use App\Models\DevicePushToken;
use App\Models\User;
use Illuminate\Support\Collection;
use Illuminate\Support\Facades\Http;
use Illuminate\Support\Facades\Log;

class FcmPushService
{
    /**
     * @param  array<string, string>  $data
     */
    public function sendToUser(User $user, string $title, string $body, array $data = []): bool
    {
        $tokens = DevicePushToken::query()
            ->where('user_id', $user->id)
            ->pluck('token');

        return $this->sendToTokens($tokens, $title, $body, $data);
    }

    /**
     * @param  Collection<int, string>|array<int, string>  $tokens
     * @param  array<string, string>  $data
     */
    public function sendToTokens(Collection|array $tokens, string $title, string $body, array $data = []): bool
    {
        $serverKey = (string) config('services.fcm.server_key', '');
        if ($serverKey === '') {
            return false;
        }

        $tokenList = collect($tokens)
            ->map(fn ($token) => trim((string) $token))
            ->filter(fn ($token) => $token !== '')
            ->unique()
            ->values()
            ->all();

        if ($tokenList === []) {
            return false;
        }

        $response = Http::timeout(10)
            ->withHeaders(['Authorization' => 'key='.$serverKey])
            ->post('https://fcm.googleapis.com/fcm/send', [
                'registration_ids' => $tokenList,
                'notification' => [
                    'title' => $title,
                    'body' => $body,
                ],
                'data' => $data,
            ]);

        if (! $response->successful()) {
            Log::warning('FCM push failed', [
                'status' => $response->status(),
                'body' => $response->body(),
            ]);

            return false;
        }

        return true;
    }
}
