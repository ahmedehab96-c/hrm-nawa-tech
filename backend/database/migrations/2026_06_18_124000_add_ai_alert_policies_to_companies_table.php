<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::table('companies', function (Blueprint $table) {
            $table->decimal('ai_alert_error_rate_threshold', 5, 2)
                ->default(5.00)
                ->after('ai_safety_level');
            $table->unsignedInteger('ai_alert_p95_latency_ms_threshold')
                ->default(2500)
                ->after('ai_alert_error_rate_threshold');
            $table->unsignedInteger('ai_alert_queue_failure_threshold')
                ->default(3)
                ->after('ai_alert_p95_latency_ms_threshold');
        });
    }

    public function down(): void
    {
        Schema::table('companies', function (Blueprint $table) {
            $table->dropColumn([
                'ai_alert_error_rate_threshold',
                'ai_alert_p95_latency_ms_threshold',
                'ai_alert_queue_failure_threshold',
            ]);
        });
    }
};
