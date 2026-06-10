<?php

use App\Http\Controllers\Api\AttendanceController;
use App\Http\Controllers\Api\AuthController;
use App\Http\Controllers\Api\CompanyController;
use App\Http\Controllers\Api\EmployeeController;
use App\Http\Controllers\Api\LeaveController;
use App\Http\Controllers\Api\NotificationController;
use App\Http\Controllers\Api\PayrollController;
use App\Http\Controllers\Api\RecruitmentController;
use Illuminate\Support\Facades\Route;

// Auth — حدود صارمة لمنع brute-force
Route::middleware('throttle:10,1')->group(function () {
    Route::post('/login', [AuthController::class, 'login']);
});
Route::middleware('throttle:5,1')->group(function () {
    Route::post('/register', [AuthController::class, 'register']);
    Route::post('/forgot-password', [AuthController::class, 'forgotPassword']);
    Route::post('/reset-password', [AuthController::class, 'resetPassword']);
});

// Logout — يُبطل الـ token الحالي
Route::middleware('auth:sanctum')->post('/logout', [AuthController::class, 'logout']);

// مسار `/employees/me` قبل `{id}` حتى لا يُفسَّر `me` كمعرّف رقمي في مجموعة الأدمن.
Route::middleware(['auth:sanctum', 'role:employee'])->group(function () {
    Route::get('/employees/me', [EmployeeController::class, 'me']);
});

// مسارات الإدارة (لوحة الويب) — تتطلب user.role = company_admin
Route::middleware(['auth:sanctum', 'role:company_admin'])->group(function () {
    Route::get('/employees', [EmployeeController::class, 'index']);
    Route::get('/employees/{id}', [EmployeeController::class, 'show'])->whereNumber('id');
    Route::post('/employees', [EmployeeController::class, 'store']);
    Route::put('/employees/{id}', [EmployeeController::class, 'update'])->whereNumber('id');
    Route::delete('/employees/{id}', [EmployeeController::class, 'destroy'])->whereNumber('id');
    Route::post('/employees/{id}/app-access', [EmployeeController::class, 'setAppAccess'])->whereNumber('id');

    Route::get('/company', [CompanyController::class, 'show']);
    Route::put('/company', [CompanyController::class, 'update']);

    Route::post('/attendance', [AttendanceController::class, 'store']);
    Route::put('/attendance/{id}', [AttendanceController::class, 'update'])->whereNumber('id');

    // Recruitment — jobs
    Route::get('/jobs', [RecruitmentController::class, 'index']);
    Route::post('/jobs', [RecruitmentController::class, 'store']);
    Route::get('/jobs/{id}', [RecruitmentController::class, 'show'])->whereNumber('id');
    Route::put('/jobs/{id}', [RecruitmentController::class, 'update'])->whereNumber('id');
    Route::delete('/jobs/{id}', [RecruitmentController::class, 'destroy'])->whereNumber('id');
    // Recruitment — candidates
    Route::post('/jobs/{jobId}/candidates', [RecruitmentController::class, 'addCandidate'])->whereNumber('jobId');
    Route::put('/jobs/{jobId}/candidates/{candidateId}', [RecruitmentController::class, 'updateCandidateStage'])->whereNumber(['jobId', 'candidateId']);
    Route::delete('/jobs/{jobId}/candidates/{candidateId}', [RecruitmentController::class, 'deleteCandidate'])->whereNumber(['jobId', 'candidateId']);
    Route::post('/leave-requests/{id}/approve', [LeaveController::class, 'approve']);
    Route::post('/leave-requests/{id}/reject', [LeaveController::class, 'reject']);
    Route::post('/payroll/generate', [PayrollController::class, 'generate']);
});

// مسارات مشتركة (أدمن + موظف) مع فلترة حسب الشركة/المستخدم داخل الكنترولر
Route::middleware(['auth:sanctum', 'role:company_admin,employee'])->group(function () {
    Route::get('/attendance', [AttendanceController::class, 'index']);
    Route::post('/attendance/check-in', [AttendanceController::class, 'checkIn']);
    Route::post('/attendance/check-out', [AttendanceController::class, 'checkOut']);

    Route::get('/leave-requests', [LeaveController::class, 'requests']);
    Route::post('/leave-requests', [LeaveController::class, 'store']);
    Route::get('/leave-balances', [LeaveController::class, 'balances']);

    Route::get('/payroll', [PayrollController::class, 'index']);
    Route::get('/payroll/{employeeId}/payslip', [PayrollController::class, 'payslipHtml'])->whereNumber('employeeId');

    Route::get('/notifications', [NotificationController::class, 'index']);
    Route::patch('/notifications/{id}/read', [NotificationController::class, 'markRead'])->whereNumber('id');
    Route::post('/notifications/read-all', [NotificationController::class, 'markAllRead']);
    Route::delete('/notifications/{id}', [NotificationController::class, 'destroy'])->whereNumber('id');
});
