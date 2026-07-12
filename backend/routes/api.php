<?php

use App\Http\Controllers\Api\PlatformController;
use App\Http\Controllers\Api\AttendanceController;
use App\Http\Controllers\Api\AiController;
use App\Http\Controllers\Api\AuthController;
use App\Http\Controllers\Api\CompanyController;
use App\Http\Controllers\Api\EmployeeController;
use App\Http\Controllers\Api\LeaveController;
use App\Http\Controllers\Api\NotificationController;
use App\Http\Controllers\Api\PayrollController;
use App\Http\Controllers\Api\PerformanceController;
use App\Http\Controllers\Api\ReportController;
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

// Signed email verification (no auth — opened from email link)
Route::get('/email/verify/{id}/{hash}', [AuthController::class, 'verifyEmail'])
    ->middleware(['signed', 'throttle:10,1'])
    ->name('verification.verify');

// Logout — يُبطل الـ token الحالي
Route::middleware('auth:sanctum')->post('/logout', [AuthController::class, 'logout']);
Route::middleware(['auth:sanctum', 'throttle:6,1'])->post(
    '/email/verification-notification',
    [AuthController::class, 'resendVerification']
);

// مسار `/employees/me` قبل `{id}` حتى لا يُفسَّر `me` كمعرّف رقمي في مجموعة الأدمن.
Route::middleware(['auth:sanctum', 'verified.api', 'trial', 'role:employee'])->group(function () {
    Route::get('/employees/me', [EmployeeController::class, 'me']);
});

// مسارات الإدارة (لوحة الويب) — تتطلب user.role = company_admin
Route::middleware(['auth:sanctum', 'verified.api', 'trial', 'role:company_admin'])->group(function () {
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
    Route::middleware(['ai.enabled', 'ai.rollout', 'ai.quota:recruitment_parse', 'permission:recruitment.ai.parse'])->post(
        '/jobs/{jobId}/candidates/{candidateId}/parse-cv',
        [RecruitmentController::class, 'parseCandidateCv']
    )->whereNumber(['jobId', 'candidateId']);
    Route::middleware(['ai.enabled', 'ai.rollout', 'ai.quota:recruitment_parse', 'permission:recruitment.ai.parse'])->post(
        '/jobs/{jobId}/candidates/{candidateId}/parse-cv/queue',
        [RecruitmentController::class, 'parseCandidateCvQueued']
    )->whereNumber(['jobId', 'candidateId']);
    Route::middleware(['ai.enabled', 'ai.rollout', 'ai.quota:recruitment_match', 'permission:recruitment.ai.match'])->post(
        '/jobs/{id}/match-candidates',
        [RecruitmentController::class, 'matchCandidates']
    )->whereNumber('id');
    Route::middleware(['ai.enabled', 'ai.rollout', 'ai.quota:recruitment_match', 'permission:recruitment.ai.match'])->post(
        '/jobs/{id}/match-candidates/queue',
        [RecruitmentController::class, 'matchCandidatesQueued']
    )->whereNumber('id');
    Route::post('/leave-requests/{id}/approve', [LeaveController::class, 'approve']);
    Route::post('/leave-requests/{id}/reject', [LeaveController::class, 'reject']);
    Route::middleware(['ai.enabled', 'ai.rollout', 'ai.quota:leave_recommendation', 'permission:leave.ai.recommend'])->post('/leave-requests/{id}/recommendation', [LeaveController::class, 'recommend']);
    Route::post('/payroll/generate', [PayrollController::class, 'generate']);

    // Performance analysis
    Route::get('/performance/reviews', [PerformanceController::class, 'index']);
    Route::post('/performance/reviews', [PerformanceController::class, 'upsert']);
    Route::middleware(['ai.enabled', 'ai.rollout', 'ai.quota:performance_analyze', 'permission:performance.ai.analyze'])->post('/performance/reviews/{id}/analyze', [PerformanceController::class, 'analyze']);
    Route::middleware(['ai.enabled', 'ai.rollout', 'ai.quota:performance_analyze', 'permission:performance.ai.analyze'])->post('/performance/reviews/{id}/analyze/queue', [PerformanceController::class, 'analyzeQueued']);

    // Reports and narrative summaries
    Route::middleware(['ai.enabled', 'ai.rollout', 'ai.quota:reports_summary', 'permission:reports.ai.summarize'])->post('/reports/summaries', [ReportController::class, 'summarize']);
    Route::middleware(['ai.enabled', 'ai.rollout', 'ai.quota:reports_summary', 'permission:reports.ai.summarize'])->post('/reports/summaries/queue', [ReportController::class, 'summarizeQueued']);

    // Company self-serve billing scaffold (Stripe/Moyasar later)
    Route::post('/billing/checkout', [PlatformController::class, 'companyCheckout']);
});

// مسارات مشتركة (أدمن + موظف) مع فلترة حسب الشركة/المستخدم داخل الكنترولر
Route::middleware(['auth:sanctum', 'verified.api', 'trial', 'role:company_admin,employee'])->group(function () {
    Route::get('/attendance', [AttendanceController::class, 'index']);
    Route::post('/attendance/check-in', [AttendanceController::class, 'checkIn']);
    Route::post('/attendance/check-out', [AttendanceController::class, 'checkOut']);
    Route::middleware(['ai.enabled', 'ai.rollout', 'ai.quota:attendance_insights', 'permission:attendance.ai.insights'])->get('/attendance/insights', [AttendanceController::class, 'insights']);
    Route::middleware(['ai.enabled', 'ai.rollout', 'ai.quota:attendance_alerts', 'permission:attendance.ai.alerts'])->post('/attendance/alerts/run', [AttendanceController::class, 'runAlerts']);

    Route::get('/leave-requests', [LeaveController::class, 'requests']);
    Route::post('/leave-requests', [LeaveController::class, 'store']);
    Route::get('/leave-balances', [LeaveController::class, 'balances']);

    Route::get('/payroll', [PayrollController::class, 'index']);
    Route::get('/payroll/{employeeId}/payslip', [PayrollController::class, 'payslipHtml'])->whereNumber('employeeId');

    Route::get('/notifications', [NotificationController::class, 'index']);
    Route::patch('/notifications/{id}/read', [NotificationController::class, 'markRead'])->whereNumber('id');
    Route::post('/notifications/read-all', [NotificationController::class, 'markAllRead']);
    Route::delete('/notifications/{id}', [NotificationController::class, 'destroy'])->whereNumber('id');

    // AI Assistant (Phase 0 foundation)
    Route::middleware(['ai.enabled', 'ai.rollout', 'ai.quota:assistant_chat', 'permission:ai.chat'])->group(function () {
        Route::post('/ai/chat', [AiController::class, 'chat']);
    });
    Route::middleware(['ai.enabled', 'ai.rollout', 'ai.quota:job_description', 'permission:ai.job_description.generate'])->group(function () {
        Route::post('/ai/job-descriptions/generate', [AiController::class, 'generateJobDescription']);
    });
    Route::middleware(['ai.enabled', 'ai.rollout', 'ai.quota:communication', 'permission:ai.communication.generate'])->group(function () {
        Route::post('/ai/communications/generate', [AiController::class, 'generateCommunication']);
    });
    Route::middleware(['ai.enabled', 'permission:ai.usage.view'])->get('/ai/usage', [AiController::class, 'usage']);
    Route::middleware(['ai.enabled', 'permission:ai.usage.view'])->get('/ai/observability', [AiController::class, 'observability']);
    Route::middleware(['ai.enabled', 'permission:ai.usage.view'])->get('/ai/slo', [AiController::class, 'sloReport']);
    Route::middleware(['ai.enabled', 'permission:ai.usage.view'])->get('/ai/cost-anomalies', [AiController::class, 'costAnomalies']);
    Route::middleware(['ai.enabled', 'permission:ai.incident.manage'])->post('/ai/escalation/dispatch', [AiController::class, 'dispatchEscalation']);
    Route::middleware(['ai.enabled', 'permission:ai.incident.manage'])->get('/ai/escalation/notifications', [AiController::class, 'escalationNotifications']);
    Route::middleware(['ai.enabled', 'permission:ai.incident.manage'])->get('/ai/escalation/runbooks', [AiController::class, 'escalationRunbooks']);
    Route::middleware(['ai.enabled', 'permission:ai.incident.manage'])->post('/ai/escalation/digest', [AiController::class, 'runEscalationDigest']);
    Route::middleware(['ai.enabled', 'permission:ai.incident.manage'])->get('/ai/queue-health-events', [AiController::class, 'queueHealthEvents']);
    Route::middleware(['ai.enabled', 'permission:ai.incident.manage'])->get('/ai/audit', [AiController::class, 'auditTrail']);
    Route::middleware(['ai.enabled', 'permission:ai.usage.view'])->get('/ai/canary', [AiController::class, 'canary']);
    Route::middleware(['ai.enabled', 'permission:ai.incident.manage'])->get('/ai/incidents/playbooks', [AiController::class, 'incidentPlaybooks']);
    Route::middleware(['ai.enabled', 'permission:ai.incident.manage'])->post('/ai/remediation/apply', [AiController::class, 'applyRemediation']);
    Route::middleware(['ai.enabled', 'permission:ai.incident.manage'])->post('/ai/remediation/auto', [AiController::class, 'autoRemediate']);
    Route::middleware(['ai.enabled', 'permission:ai.prompt.manage'])->get('/ai/prompts', [AiController::class, 'listPromptVersions']);
    Route::middleware(['ai.enabled', 'permission:ai.prompt.manage'])->post('/ai/prompts', [AiController::class, 'createPromptVersion']);
    Route::middleware(['ai.enabled', 'permission:ai.prompt.manage'])->post('/ai/prompts/{id}/activate', [AiController::class, 'activatePromptVersion'])->whereNumber('id');
    Route::middleware(['ai.enabled'])->get('/ai/tasks/{id}', [AiController::class, 'taskStatus'])->whereNumber('id');
});

// Platform console — super_admin only (no company trial gate)
Route::middleware(['auth:sanctum', 'verified.api', 'role:super_admin'])->prefix('platform')->group(function () {
    Route::get('/overview', [PlatformController::class, 'overview']);
    Route::get('/companies', [PlatformController::class, 'companies']);
    Route::get('/companies/{id}', [PlatformController::class, 'showCompany'])->whereNumber('id');
    Route::put('/companies/{id}', [PlatformController::class, 'updateCompany'])->whereNumber('id');
    Route::post('/companies/{id}/checkout', [PlatformController::class, 'createCheckout'])->whereNumber('id');
});
