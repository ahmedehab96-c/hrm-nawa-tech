<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::table('companies', function (Blueprint $table): void {
            $table->decimal('ai_slo_target_success_rate', 5, 2)->default(99.5)->after('ai_alert_queue_failure_threshold');
            $table->decimal('ai_burn_rate_alert_threshold', 6, 2)->default(2.0)->after('ai_slo_target_success_rate');
            $table->decimal('ai_cost_anomaly_multiplier', 4, 2)->default(2.0)->after('ai_burn_rate_alert_threshold');
            $table->json('ai_alert_channels')->nullable()->after('ai_cost_anomaly_multiplier');
            $table->json('ai_escalation_matrix')->nullable()->after('ai_alert_channels');
        });
    }

    public function down(): void
    {
        Schema::table('companies', function (Blueprint $table): void {
            $table->dropColumn([
                'ai_slo_target_success_rate',
                'ai_burn_rate_alert_threshold',
                'ai_cost_anomaly_multiplier',
                'ai_alert_channels',
                'ai_escalation_matrix',
            ]);
        });
    }
};
