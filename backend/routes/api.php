<?php

use App\Http\Controllers\Api\HealthController;
use App\Http\Controllers\Api\PlatformController;
use App\Http\Controllers\Api\AttendanceController;
use App\Http\Controllers\Api\Ai\ChatController as AiChatController;
use App\Http\Controllers\Api\Ai\ContentController as AiContentController;
use App\Http\Controllers\Api\Ai\IncidentController as AiIncidentController;
use App\Http\Controllers\Api\Ai\PromptController as AiPromptController;
use App\Http\Controllers\Api\Ai\TaskController as AiTaskController;
use App\Http\Controllers\Api\Ai\UsageController as AiUsageController;
use App\Http\Controllers\Api\AuthController;
use App\Http\Controllers\Api\CompanyController;
use App\Http\Controllers\Api\DeviceTokenController;
use App\Http\Controllers\Api\EmployeeController;
use App\Http\Controllers\Api\LeaveController;
use App\Http\Controllers\Api\NotificationController;
use App\Http\Controllers\Api\PayrollController;
use App\Http\Controllers\Api\PerformanceController;
use App\Http\Controllers\Api\ReportController;
use App\Http\Controllers\Api\RecruitmentController;
use Illuminate\Support\Facades\Route;

Route::get('/health', HealthController::class)->middleware('throttle:60,1');

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
Route::middleware('auth:sanctum')->get('/auth/me', [AuthController::class, 'me']);
Route::middleware(['auth:sanctum', 'throttle:6,1'])->post(
    '/email/verification-notification',
    [AuthController::class, 'resendVerification']
);

// مسار `/employees/me` قبل `{id}` حتى لا يُفسَّر `me` كمعرّف رقمي في مجموعة الأدمن.
Route::middleware(['auth:sanctum', 'verified.api', 'trial', 'role:employee'])->group(function () {
    Route::get('/employees/me', [EmployeeController::class, 'me']);
    Route::post('/device-tokens', [DeviceTokenController::class, 'store']);
    Route::delete('/device-tokens', [DeviceTokenController::class, 'destroy']);
});

// مسارات الإدارة (لوحة الويب) — company_admin + أدوار HR حسب الصلاحيات (متوافقة مع Filament).
// Pivot roles/permissions are the source of truth (see app/Models/User::hasAnyPermission).
// The role gate is the coarse admin filter; each cluster below adds the fine-grained
// permission gate matching the corresponding Filament resource permission.
Route::middleware(['auth:sanctum', 'verified.api', 'trial', 'role:company_admin,hr_manager,hr,recruiter'])->group(function () {
    // Employees — employees.manage
    Route::middleware('permission:employees.manage')->group(function () {
        Route::get('/employees', [EmployeeController::class, 'index']);
        Route::get('/employees/{id}', [EmployeeController::class, 'show'])->whereNumber('id');
        Route::post('/employees', [EmployeeController::class, 'store']);
        Route::put('/employees/{id}', [EmployeeController::class, 'update'])->whereNumber('id');
        Route::delete('/employees/{id}', [EmployeeController::class, 'destroy'])->whereNumber('id');
        Route::post('/employees/{id}/app-access', [EmployeeController::class, 'setAppAccess'])->whereNumber('id');
    });

    // Company settings + billing — settings.manage (company_admin only in the matrix)
    Route::middleware('permission:settings.manage')->group(function () {
        Route::get('/company', [CompanyController::class, 'show']);
        Route::put('/company', [CompanyController::class, 'update']);
        Route::post('/billing/checkout', [PlatformController::class, 'companyCheckout']);
    });

    // Attendance admin writes — attendance.manage
    Route::middleware('permission:attendance.manage')->group(function () {
        Route::post('/attendance', [AttendanceController::class, 'store']);
        Route::put('/attendance/{id}', [AttendanceController::class, 'update'])->whereNumber('id');
    });

    // Recruitment — recruitment.manage (AI sub-routes keep their own ai.* permission gate)
    Route::middleware('permission:recruitment.manage')->group(function () {
        Route::get('/jobs', [RecruitmentController::class, 'index']);
        Route::post('/jobs', [RecruitmentController::class, 'store']);
        Route::get('/jobs/{id}', [RecruitmentController::class, 'show'])->whereNumber('id');
        Route::put('/jobs/{id}', [RecruitmentController::class, 'update'])->whereNumber('id');
        Route::delete('/jobs/{id}', [RecruitmentController::class, 'destroy'])->whereNumber('id');
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
    });

    // Leave decisions — leave.approve
    Route::middleware('permission:leave.approve')->group(function () {
        Route::post('/leave-requests/{id}/approve', [LeaveController::class, 'approve']);
        Route::post('/leave-requests/{id}/reject', [LeaveController::class, 'reject']);
        Route::middleware(['ai.enabled', 'ai.rollout', 'ai.quota:leave_recommendation', 'permission:leave.ai.recommend'])->post('/leave-requests/{id}/recommendation', [LeaveController::class, 'recommend']);
    });

    // Payroll — payroll.manage
    Route::middleware('permission:payroll.manage')->group(function () {
        Route::post('/payroll/generate', [PayrollController::class, 'generate']);
    });

    // Performance — performance.manage
    Route::middleware('permission:performance.manage')->group(function () {
        Route::get('/performance/reviews', [PerformanceController::class, 'index']);
        Route::post('/performance/reviews', [PerformanceController::class, 'upsert']);
        Route::middleware(['ai.enabled', 'ai.rollout', 'ai.quota:performance_analyze', 'permission:performance.ai.analyze'])->post('/performance/reviews/{id}/analyze', [PerformanceController::class, 'analyze']);
        Route::middleware(['ai.enabled', 'ai.rollout', 'ai.quota:performance_analyze', 'permission:performance.ai.analyze'])->post('/performance/reviews/{id}/analyze/queue', [PerformanceController::class, 'analyzeQueued']);
    });

    // Reports and narrative summaries — reports.ai.summarize (already permission-gated per route)
    Route::middleware(['ai.enabled', 'ai.rollout', 'ai.quota:reports_summary', 'permission:reports.ai.summarize'])->post('/reports/summaries', [ReportController::class, 'summarize']);
    Route::middleware(['ai.enabled', 'ai.rollout', 'ai.quota:reports_summary', 'permission:reports.ai.summarize'])->post('/reports/summaries/queue', [ReportController::class, 'summarizeQueued']);
});

// مسارات مشتركة (أدمن + HR + موظف) مع فلترة حسب الشركة/المستخدم داخل الكنترولر
Route::middleware(['auth:sanctum', 'verified.api', 'trial', 'role:company_admin,hr_manager,hr,employee'])->group(function () {
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
});

// AI endpoints — structure split under Api\Ai\*; enablement stays on ai.enabled/rollout/quota.
// Includes recruiter so recruitment AI chat/job-description permissions remain reachable.
Route::middleware(['auth:sanctum', 'verified.api', 'trial', 'role:company_admin,hr_manager,hr,recruiter,employee'])->group(function () {
    Route::middleware(['ai.enabled', 'ai.rollout', 'ai.quota:assistant_chat', 'permission:ai.chat'])->group(function () {
        Route::post('/ai/chat', [AiChatController::class, 'chat']);
    });
    Route::middleware(['ai.enabled', 'ai.rollout', 'ai.quota:job_description', 'permission:ai.job_description.generate'])->group(function () {
        Route::post('/ai/job-descriptions/generate', [AiContentController::class, 'generateJobDescription']);
    });
    Route::middleware(['ai.enabled', 'ai.rollout', 'ai.quota:communication', 'permission:ai.communication.generate'])->group(function () {
        Route::post('/ai/communications/generate', [AiContentController::class, 'generateCommunication']);
    });
    Route::middleware(['ai.enabled', 'permission:ai.usage.view'])->get('/ai/usage', [AiUsageController::class, 'usage']);
    Route::middleware(['ai.enabled', 'permission:ai.usage.view'])->get('/ai/observability', [AiUsageController::class, 'observability']);
    Route::middleware(['ai.enabled', 'permission:ai.usage.view'])->get('/ai/slo', [AiUsageController::class, 'sloReport']);
    Route::middleware(['ai.enabled', 'permission:ai.usage.view'])->get('/ai/cost-anomalies', [AiUsageController::class, 'costAnomalies']);
    Route::middleware(['ai.enabled', 'permission:ai.incident.manage'])->post('/ai/escalation/dispatch', [AiIncidentController::class, 'dispatchEscalation']);
    Route::middleware(['ai.enabled', 'permission:ai.incident.manage'])->get('/ai/escalation/notifications', [AiIncidentController::class, 'escalationNotifications']);
    Route::middleware(['ai.enabled', 'permission:ai.incident.manage'])->get('/ai/escalation/runbooks', [AiIncidentController::class, 'escalationRunbooks']);
    Route::middleware(['ai.enabled', 'permission:ai.incident.manage'])->post('/ai/escalation/digest', [AiIncidentController::class, 'runEscalationDigest']);
    Route::middleware(['ai.enabled', 'permission:ai.incident.manage'])->get('/ai/queue-health-events', [AiIncidentController::class, 'queueHealthEvents']);
    Route::middleware(['ai.enabled', 'permission:ai.incident.manage'])->get('/ai/audit', [AiIncidentController::class, 'auditTrail']);
    Route::middleware(['ai.enabled', 'permission:ai.usage.view'])->get('/ai/canary', [AiUsageController::class, 'canary']);
    Route::middleware(['ai.enabled', 'permission:ai.incident.manage'])->get('/ai/incidents/playbooks', [AiIncidentController::class, 'incidentPlaybooks']);
    Route::middleware(['ai.enabled', 'permission:ai.incident.manage'])->post('/ai/remediation/apply', [AiIncidentController::class, 'applyRemediation']);
    Route::middleware(['ai.enabled', 'permission:ai.incident.manage'])->post('/ai/remediation/auto', [AiIncidentController::class, 'autoRemediate']);
    Route::middleware(['ai.enabled', 'permission:ai.prompt.manage'])->get('/ai/prompts', [AiPromptController::class, 'listPromptVersions']);
    Route::middleware(['ai.enabled', 'permission:ai.prompt.manage'])->post('/ai/prompts', [AiPromptController::class, 'createPromptVersion']);
    Route::middleware(['ai.enabled', 'permission:ai.prompt.manage'])->post('/ai/prompts/{id}/activate', [AiPromptController::class, 'activatePromptVersion'])->whereNumber('id');
    Route::middleware(['ai.enabled'])->get('/ai/tasks/{id}', [AiTaskController::class, 'taskStatus'])->whereNumber('id');
});

// Platform console — super_admin only (no company trial gate)
Route::middleware(['auth:sanctum', 'verified.api', 'role:super_admin'])->prefix('platform')->group(function () {
    Route::get('/overview', [PlatformController::class, 'overview']);
    Route::get('/companies', [PlatformController::class, 'companies']);
    Route::get('/companies/{id}', [PlatformController::class, 'showCompany'])->whereNumber('id');
    Route::put('/companies/{id}', [PlatformController::class, 'updateCompany'])->whereNumber('id');
    Route::post('/companies/{id}/checkout', [PlatformController::class, 'createCheckout'])->whereNumber('id');
});
