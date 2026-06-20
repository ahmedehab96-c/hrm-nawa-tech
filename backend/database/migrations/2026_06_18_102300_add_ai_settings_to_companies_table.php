<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::table('companies', function (Blueprint $table) {
            $table->string('ai_plan', 32)->default('enterprise')->after('status');
            $table->boolean('ai_enabled')->default(true)->after('ai_plan');
            $table->string('ai_provider', 32)->default('openai')->after('ai_enabled');
            $table->string('ai_model', 64)->nullable()->after('ai_provider');
        });
    }

    public function down(): void
    {
        Schema::table('companies', function (Blueprint $table) {
            $table->dropColumn(['ai_plan', 'ai_enabled', 'ai_provider', 'ai_model']);
        });
    }
};
