<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('job_descriptions', function (Blueprint $table) {
            $table->id();
            $table->foreignId('company_id')->constrained('companies')->cascadeOnDelete();
            $table->foreignId('job_posting_id')->nullable()->constrained('job_postings')->nullOnDelete();
            $table->foreignId('created_by')->nullable()->constrained('users')->nullOnDelete();
            $table->string('job_title', 255);
            $table->string('department', 255)->nullable();
            $table->string('location', 255)->nullable();
            $table->string('employment_type', 64)->nullable();
            $table->string('language_code', 8)->default('en');
            $table->string('tone', 32)->default('professional');
            $table->longText('content');
            $table->string('provider', 32)->nullable();
            $table->string('model', 64)->nullable();
            $table->timestamps();
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('job_descriptions');
    }
};
