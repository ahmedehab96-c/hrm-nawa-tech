<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('attendance_insights', function (Blueprint $table) {
            $table->id();
            $table->foreignId('company_id')->constrained('companies')->cascadeOnDelete();
            $table->foreignId('generated_by')->nullable()->constrained('users')->nullOnDelete();
            $table->date('period_start');
            $table->date('period_end');
            $table->unsignedInteger('total_records')->default(0);
            $table->unsignedInteger('present_count')->default(0);
            $table->unsignedInteger('late_count')->default(0);
            $table->unsignedInteger('absent_count')->default(0);
            $table->json('risk_employees_json')->nullable();
            $table->text('summary')->nullable();
            $table->timestamps();
        });

        Schema::create('attendance_alerts', function (Blueprint $table) {
            $table->id();
            $table->foreignId('company_id')->constrained('companies')->cascadeOnDelete();
            $table->foreignId('employee_id')->nullable()->constrained('employees')->nullOnDelete();
            $table->foreignId('generated_by')->nullable()->constrained('users')->nullOnDelete();
            $table->string('alert_type', 64);
            $table->string('severity', 16)->default('medium');
            $table->string('status', 16)->default('open');
            $table->text('message');
            $table->timestamp('generated_at');
            $table->timestamp('resolved_at')->nullable();
            $table->timestamps();

            $table->index(['company_id', 'status', 'generated_at']);
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('attendance_alerts');
        Schema::dropIfExists('attendance_insights');
    }
};
