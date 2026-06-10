<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('candidates', function (Blueprint $table) {
            $table->id();
            $table->unsignedBigInteger('company_id');
            $table->unsignedBigInteger('job_posting_id');
            $table->string('name');
            $table->string('email')->nullable();
            $table->string('phone')->nullable();
            $table->enum('stage', ['new', 'interview', 'offer', 'hired', 'rejected'])->default('new');
            $table->text('notes')->nullable();
            $table->timestamps();

            $table->index(['company_id', 'job_posting_id']);
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('candidates');
    }
};
