<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('ai_prompt_versions', function (Blueprint $table) {
            $table->id();
            $table->foreignId('company_id')->constrained('companies')->cascadeOnDelete();
            $table->foreignId('created_by')->nullable()->constrained('users')->nullOnDelete();
            $table->string('feature_key', 64);
            $table->string('version_label', 64);
            $table->longText('system_prompt');
            $table->boolean('is_active')->default(false);
            $table->timestamps();

            $table->unique(['company_id', 'feature_key', 'version_label'], 'ai_prompt_versions_unique');
            $table->index(['company_id', 'feature_key', 'is_active'], 'ai_prompt_versions_lookup');
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('ai_prompt_versions');
    }
};
