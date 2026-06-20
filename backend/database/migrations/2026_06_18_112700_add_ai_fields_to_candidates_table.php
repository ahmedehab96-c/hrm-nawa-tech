<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::table('candidates', function (Blueprint $table) {
            $table->longText('resume_text')->nullable()->after('notes');
            $table->text('cv_summary')->nullable()->after('resume_text');
            $table->json('skills_json')->nullable()->after('cv_summary');
            $table->decimal('years_experience', 4, 1)->nullable()->after('skills_json');
            $table->unsignedTinyInteger('ai_fit_score')->nullable()->after('years_experience');
            $table->text('ai_match_reason')->nullable()->after('ai_fit_score');
            $table->timestamp('ai_parsed_at')->nullable()->after('ai_match_reason');
        });
    }

    public function down(): void
    {
        Schema::table('candidates', function (Blueprint $table) {
            $table->dropColumn([
                'resume_text',
                'cv_summary',
                'skills_json',
                'years_experience',
                'ai_fit_score',
                'ai_match_reason',
                'ai_parsed_at',
            ]);
        });
    }
};
