<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('report_summaries', function (Blueprint $table) {
            $table->id();
            $table->foreignId('company_id')->constrained('companies')->cascadeOnDelete();
            $table->foreignId('generated_by')->nullable()->constrained('users')->nullOnDelete();
            $table->string('report_type', 64)->default('hr_overview');
            $table->date('period_start');
            $table->date('period_end');
            $table->json('metrics_json')->nullable();
            $table->text('narrative');
            $table->string('provider', 32)->nullable();
            $table->string('model', 64)->nullable();
            $table->timestamps();

            $table->index(['company_id', 'report_type', 'period_start', 'period_end']);
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('report_summaries');
    }
};
