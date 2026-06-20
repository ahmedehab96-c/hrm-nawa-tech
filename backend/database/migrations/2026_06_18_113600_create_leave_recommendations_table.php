<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('leave_recommendations', function (Blueprint $table) {
            $table->id();
            $table->foreignId('company_id')->constrained('companies')->cascadeOnDelete();
            $table->foreignId('leave_request_id')->constrained('leave_requests')->cascadeOnDelete();
            $table->foreignId('generated_by')->nullable()->constrained('users')->nullOnDelete();
            $table->string('recommended_action', 16); // approve | reject | review
            $table->unsignedTinyInteger('confidence_score')->default(50);
            $table->text('reason');
            $table->string('engine', 64)->default('rule-engine');
            $table->timestamps();

            $table->index(['company_id', 'leave_request_id']);
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('leave_recommendations');
    }
};
