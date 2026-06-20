<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::table('companies', function (Blueprint $table) {
            $table->unsignedInteger('ai_requests_per_minute')->default(60)->after('ai_model');
            $table->unsignedInteger('ai_monthly_token_limit')->default(500000)->after('ai_requests_per_minute');
            $table->json('ai_feature_flags')->nullable()->after('ai_monthly_token_limit');
        });
    }

    public function down(): void
    {
        Schema::table('companies', function (Blueprint $table) {
            $table->dropColumn(['ai_requests_per_minute', 'ai_monthly_token_limit', 'ai_feature_flags']);
        });
    }
};
