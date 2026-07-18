<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\DevicePushToken;
use Illuminate\Http\Request;
use Illuminate\Support\Carbon;

class DeviceTokenController extends Controller
{
    public function store(Request $request)
    {
        $data = $request->validate([
            'token' => 'required|string|max:512',
            'platform' => 'nullable|string|in:ios,android,unknown',
        ]);

        DevicePushToken::query()->updateOrCreate(
            [
                'user_id' => $request->user()->id,
                'token' => $data['token'],
            ],
            [
                'platform' => $data['platform'] ?? 'unknown',
                'last_used_at' => Carbon::now(),
            ],
        );

        return response()->json(['message' => 'Device token saved.']);
    }

    public function destroy(Request $request)
    {
        $data = $request->validate([
            'token' => 'required|string|max:512',
        ]);

        DevicePushToken::query()
            ->where('user_id', $request->user()->id)
            ->where('token', $data['token'])
            ->delete();

        return response()->json(['message' => 'Device token removed.']);
    }
}
