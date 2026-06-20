<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::table('companies', function (Blueprint $table): void {
            $table->string('ai_alert_email_from', 255)->nullable()->after('ai_escalation_matrix');
            $table->text('ai_slack_webhook_url')->nullable()->after('ai_alert_email_from');
        });
    }

    public function down(): void
    {
        Schema::table('companies', function (Blueprint $table): void {
            $table->dropColumn([
                'ai_alert_email_from',
                'ai_slack_webhook_url',
            ]);
        });
    }
};
