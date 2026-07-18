<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Queue;

class HealthController extends Controller
{
    public function __invoke()
    {
        $checks = [
            'app' => true,
            'database' => $this->databaseOk(),
            'queue' => $this->queueOk(),
        ];

        $healthy = ! in_array(false, $checks, true);

        return response()->json([
            'status' => $healthy ? 'ok' : 'degraded',
            'service' => 'nawa-tech-hrm-api',
            'version' => config('app.version', '1.0.0'),
            'checks' => $checks,
            'timestamp' => now()->toIso8601String(),
        ], $healthy ? 200 : 503);
    }

    private function databaseOk(): bool
    {
        try {
            DB::connection()->getPdo();
            DB::select('select 1');

            return true;
        } catch (\Throwable) {
            return false;
        }
    }

    private function queueOk(): bool
    {
        $driver = (string) config('queue.default', 'sync');

        if ($driver === 'sync') {
            return true;
        }

        try {
            Queue::connection()->size();

            return true;
        } catch (\Throwable) {
            return false;
        }
    }
}
