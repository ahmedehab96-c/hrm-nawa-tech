<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('ai_audit_events', function (Blueprint $table) {
            $table->id();
            $table->foreignId('company_id')->constrained('companies')->cascadeOnDelete();
            $table->foreignId('user_id')->nullable()->constrained('users')->nullOnDelete();
            $table->string('event_type', 64);
            $table->string('severity', 16)->default('info');
            $table->string('endpoint', 128)->nullable();
            $table->json('context')->nullable();
            $table->timestamp('event_at');
            $table->timestamps();

            $table->index(['company_id', 'event_type', 'event_at'], 'ai_audit_events_company_event_idx');
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('ai_audit_events');
    }
};
