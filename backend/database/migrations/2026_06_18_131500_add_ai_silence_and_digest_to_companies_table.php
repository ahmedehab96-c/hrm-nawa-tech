<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::table('companies', function (Blueprint $table): void {
            $table->json('ai_silence_windows')->nullable()->after('ai_slack_webhook_url');
            $table->json('ai_runbook_links')->nullable()->after('ai_silence_windows');
            $table->boolean('ai_digest_enabled')->default(true)->after('ai_runbook_links');
            $table->unsignedInteger('ai_digest_window_minutes')->default(60)->after('ai_digest_enabled');
        });
    }

    public function down(): void
    {
        Schema::table('companies', function (Blueprint $table): void {
            $table->dropColumn([
                'ai_silence_windows',
                'ai_runbook_links',
                'ai_digest_enabled',
                'ai_digest_window_minutes',
            ]);
        });
    }
};
