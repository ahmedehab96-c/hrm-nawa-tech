<?php

use Illuminate\Foundation\Inspiring;
use Illuminate\Support\Facades\Artisan;
use Illuminate\Support\Facades\Schedule;

Artisan::command('inspire', function () {
    $this->comment(Inspiring::quote());
})->purpose('Display an inspiring quote');

// Phase 12: periodic digest aggregation for AI escalation notifications.
Schedule::command('ai:escalation-digest')
    ->everyFifteenMinutes()
    ->withoutOverlapping()
    ->onOneServer();

Schedule::command('ai:queue-health-monitor')
    ->everyFiveMinutes()
    ->withoutOverlapping()
    ->onOneServer();
