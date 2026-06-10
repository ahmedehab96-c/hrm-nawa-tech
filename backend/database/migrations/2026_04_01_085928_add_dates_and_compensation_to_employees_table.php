<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    /**
     * Run the migrations.
     */
    public function up(): void
    {
        Schema::table('employees', function (Blueprint $table) {
            $table->date('birth_date')->nullable()->after('phone');
            $table->date('hire_date')->nullable()->after('position');
            $table->date('coverage_start')->nullable()->after('insurance_policy_number');
            $table->date('coverage_end')->nullable()->after('coverage_start');
            $table->decimal('base_salary', 12, 2)->default(0)->after('coverage_end');
            $table->decimal('allowances', 12, 2)->default(0)->after('base_salary');
            $table->decimal('deductions', 12, 2)->default(0)->after('allowances');
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::table('employees', function (Blueprint $table) {
            $table->dropColumn([
                'birth_date',
                'hire_date',
                'coverage_start',
                'coverage_end',
                'base_salary',
                'allowances',
                'deductions',
            ]);
        });
    }
};
