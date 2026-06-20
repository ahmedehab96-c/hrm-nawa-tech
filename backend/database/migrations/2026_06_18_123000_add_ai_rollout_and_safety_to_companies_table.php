<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::table('companies', function (Blueprint $table) {
            $table->unsignedTinyInteger('ai_rollout_percentage')
                ->default(100)
                ->after('ai_feature_flags');
            $table->string('ai_safety_level', 16)
                ->default('standard')
                ->after('ai_rollout_percentage');
        });
    }

    public function down(): void
    {
        Schema::table('companies', function (Blueprint $table) {
            $table->dropColumn(['ai_rollout_percentage', 'ai_safety_level']);
        });
    }
};
