// Static AR/EN strings — replaces flutter gen-l10n AppLocalizations.

import 'package:flutter/widgets.dart';

abstract class AppStrings {
  AppStrings([this.locale = 'ar']);

  final String locale;

  static AppStrings of(BuildContext context) {
    final code = Localizations.localeOf(context).languageCode;
    return lookupAppStrings(Locale(code));
  }

  static const List<Locale> supportedLocales = [
    Locale('ar'),
    Locale('en'),
  ];

  static const LocalizationsDelegate<AppStrings> delegate = _AppStringsDelegate();
  String get appName;
  String get appTagline;
  String get login;
  String get registerCompany;
  String get email;
  String get password;
  String get companyName;
  String get forgotPassword;
  String get dashboard;
  String get employeesCount;
  String get todayAttendance;
  String get present;
  String get absent;
  String get late;
  String get pendingLeaves;
  String get payrollStatus;
  String get processed;
  String get pending;
  String get employees;
  String get addEmployee;
  String get editEmployee;
  String get employeeProfile;
  String get personalInfo;
  String get jobInfo;
  String get salaryInfo;
  String get insuranceInfo;
  String get status;
  String get active;
  String get inactive;
  String get attendance;
  String get dailyAttendance;
  String get editAttendance;
  String get checkIn;
  String get checkOut;
  String get exportExcel;
  String get exportPdf;
  String get leave;
  String get leaveRequests;
  String get approve;
  String get reject;
  String get leaveBalance;
  String get requestLeave;
  String get payroll;
  String get monthlyPayroll;
  String get salaryBreakdown;
  String get generatePayslip;
  String get payslip;
  String get payslipEmployeeSection;
  String get payslipEarningsSection;
  String get payslipDeductionsSection;
  String get recruitment;
  String get jobListings;
  String get candidates;
  String get convertToEmployee;
  String get recruitmentStageNew;
  String get recruitmentStageInterview;
  String get recruitmentStageOffer;
  String get recruitmentStageHired;
  String get recruitmentJobTitleFlutterDeveloper;
  String get recruitmentJobTitleAccountant;
  String get recruitmentDepartmentTechnical;
  String get recruitmentDepartmentFinance;
  String get recruitmentJobStatusOpen;
  String get recruitmentApplicantFileExample;
  String get recruitmentApplicantNameSample;
  String get recruitmentApplicantRoleSample;
  String get recruitmentApplicantEmailSample;
  String recruitmentApplicantsCount(int count);
  String recruitmentApplicantIndexed(int index);
  String get recruitmentJobDetailsTitle;
  String get recruitmentLocationLabel;
  String get recruitmentLocationValue;
  String get recruitmentApplicantsLabel;
  String get recruitmentDescriptionLabel;
  String get recruitmentJobDescriptionSample;
  String get settings;
  String get companyInfo;
  String get rolesPermissions;
  String get subscriptionBilling;
  String get save;
  String get cancel;
  String get search;
  String get filter;
  String get export;
  String get date;
  String get name;
  String get department;
  String get position;
  String get actions;
  String get view;
  String get edit;
  String get delete;
  String get appearance;
  String get darkMode;
  String get darkModeOn;
  String get darkModeOff;
  String get lightMode;
  String get language;
  String get languageTitle;
  String get arabic;
  String get english;
  String get serverBindingTitle;
  String get serverBindingDescription;
  String get baseUrlLabel;
  String get baseUrlHint;
  String get useServer;
  String get serverEnabled;
  String get serverDisabled;
  String get serverSettingsSaved;
  String get companySavedLocal;
  String get planUpgradeLater;
  String get planUpgradeStarter;
  String get planUpgradeGrowth;
  String get billingNotConfigured;
  String get platformConsoleTitle;
  String get platformOverview;
  String get platformCompanies;
  String get platformUsers;
  String get platformTrialsActive;
  String get platformTrialsExpired;
  String get platformSearchCompanies;
  String get platformNoCompanies;
  String get platformActivateCompany;
  String get platformSuspendCompany;
  String get platformExtendTrial;
  String get platformSetStarter;
  String get platformSetGrowth;
  String get employeeNavHome;
  String get employeeNavAttendance;
  String get employeeNavLeave;
  String get employeeNavPayroll;
  String get employeeNavNotifications;
  String get employeeNavProfile;
  String get myNotifications;
  String get retryAction;
  String get dashboardPartialLoadError;
  String get payslipNotFound;
  String get noNotifications;
  String get refreshTooltip;
  String get payslipDownloadLater;
  String get rolePermissionsServer;
  String jobEditServer(String jobId);
  String get convertEmployeeHint;
  String get sessionExpired;
  String get apiHttpsRequired;
  String get invalidApiUrl;
  String get apiUrlRequired;
  String get notificationsTitle;
  String get employeeNotificationsTitle;
  String get phone;
  String get address;
  String get wifiAttendanceTitle;
  String get wifiAttendanceBody;
  String get wifiSsidLabel;
  String get wifiSsidHint;
  String get wifiSettingsSaved;
  String get dataFromServer;
  String get dataLocalDemo;
  String get subscriptionPlanName;
  String get subscriptionPlanPrice;
  String get upgradePlan;
  String get paymentPortalLater;
  String get roleAdminTitle;
  String get roleAdminSubtitle;
  String get roleHrTitle;
  String get roleHrSubtitle;
  String get roleEmployeeTitle;
  String get roleEmployeeSubtitle;
  String get featureEmployees;
  String get featureAttendance;
  String get featureLeave;
  String get featurePayroll;
  String get featureRecruitment;
  String get dashboardOverview;
  String get ofSeats;
  String get needsReview;
  String get payrollDone;
  String get payrollMonthSample;
  String get viewAll;
  String get leaveType;
  String get leaveApproved;
  String get leaveRejected;
  String get adminProfileMenu;
  String get logout;
  String get sampleAdminName;
  String get sampleAdminRole;
  String get refreshAction;
  String get attendanceEditGrid;
  String attendanceEditEmployee(String name);
  String exportPrepared(String format);
  String get formatExcel;
  String get formatPdf;
  String get payrollGenerateDemo;
  String get colEmployee;
  String get colBaseSalary;
  String get colAllowances;
  String get colDeductions;
  String get colNetSalary;
  String get colStatus;
  String get colCheckIn;
  String get colCheckOut;
  String get colWorkHours;
  String get breakdownBase;
  String get breakdownAllowances;
  String get breakdownDeductions;
  String get breakdownNet;
  String get filterAllDepartments;
  String filterDepartmentButton(String name);
  String get monthFebruary2025;
  String get monthJanuary2025;
  String get formSavedSuccess;
  String get fieldRequired;
  String get fullName;
  String get birthDate;
  String get hireDate;
  String get bankAccount;
  String get insuranceType;
  String get insuranceHealthOpt;
  String get insuranceSocialOpt;
  String get insuranceOtherOpt;
  String get policyNumber;
  String get insuranceCompany;
  String get coverageStart;
  String get coverageEnd;
  String get payslipMonthField;
  String get download;
  String get addJob;
  String get recruitmentPaidBanner;
  String get loginBrandingTitle;
  String get loginBrandingSubtitle;
  String get loginFormSubtitle;
  String get enterEmail;
  String get enterPassword;
  String get forgotPasswordTitle;
  String get forgotPasswordBody;
  String get sendResetLink;
  String get backToLogin;
  String get resetLinkSent;
  String get resetLinkSentBody;
  String get resetPasswordTitle;
  String resetPasswordBody(String email);
  String get newPassword;
  String get confirmNewPassword;
  String get saveNewPassword;
  String get passwordResetSuccess;
  String get passwordResetSuccessBody;
  String get resetLinkInvalid;
  String get resetLinkInvalidBody;
  String get passwordMinLength;
  String get passwordsDoNotMatch;
  String get addCompanyTitle;
  String get demoCompanyLabel;
  String get companyAddedSuccess;
  String get jobTitleField;
  String get jobLocationField;
  String get jobDescriptionField;
  String get jobAddedSuccess;
  String get payslipDownloading;
  String get registerSubtitle;
  String get enterCompanyName;
  String get haveAccountLogin;
  String get leaveAdminSubtitle;
  String get filterAll;
  String get filterPendingShort;
  String get filterApprovedShort;
  String get filterRejectedShort;
  String get leaveColFrom;
  String get leaveColTo;
  String get leaveColDays;
  String get leaveColBalanceLeft;
  String get leaveBalancePerEmployee;
  String get annualShort;
  String get sickShort;
  String get emergencyShort;
  String get wifiChecking;
  String get wifiOnCompany;
  String get wifiOffCompany;
  String networkLabel(String name);
  String get recheckWifi;
  String get attendanceTodayTitle;
  String get checkInTimeSample;
  String get checkInRecorded;
  String get greetingHello;
  String greetingWithName(String name);
  String get homeDateSample;
  String get wifiCheckingHome;
  String get wifiNotOnCompanyHome;
  String get attendanceOnlyWifiHint;
  String get quickActionsTitle;
  String get attendanceLogLabel;
  String get profileQuickLabel;
  String get notificationsTooltip;
  String get employeeAppSubtitle;
  String get leaveNotes;
  String get documentsSection;
  String get employmentContract;
  String get payslipJanuaryDoc;
  String get companyLabelRow;
  String get roleLabelRow;
  String get baseSalaryLabel;
  String get roleDetailTitle;
  String get permissionsTitle;
  String get editPermissionsButton;
  String get aiAssistantWelcome;
  String get apiBaseUrlMissing;
  String get apiErrorServer;
  String apiErrorConnection(String details);
  String get apiInvalidResponse;
  String get apiNoTokenReceived;
  String apiReadResponseFailed(String details);
  String apiErrorEmployeesList(String details);
  String apiErrorEmployeeDetail(String details);
  String apiErrorAttendance(String details);
  String apiErrorLeaveRequests(String details);
  String apiErrorLeaveBalances(String details);
  String apiErrorPayroll(String details);
  String apiErrorNotifications(String details);
  String get demoUserName;
  String get leaveApproveSuccess;
  String get leaveRejectSuccess;
  String get registerSuccessServer;
  String get aiPanelTitle;
  String get aiTyping;
  String get aiInputHint;
  String get planStarter;
  String get planStarterDesc;
  String get planGrowth;
  String get planGrowthDesc;
  String get planEnterprise;
  String get planEnterpriseDesc;
  String get saasPlanSection;
  String get trialExpiredBanner;
  String get emailUnverifiedBanner;
  String get verifyEmailTitle;
  String get verifyEmailBody;
  String get resendVerificationLink;
  String get verificationLinkSent;
  String get verifyContinueButton;
  String get verifyingEmail;
  String get verifyEmailSuccess;
  String get verifyEmailFailed;
  String trialEndsOn(String date);
  String trialDaysLeft(int days);
  String get saasRecruitmentLocked;
  String get employeeLimitReached;
  String get loginUseWebForAdmin;
  String get loginUseMobileForEmployee;
  String get employeeLoginCredentialsHint;
  String get employeeAppLoginTab;
  String get enableEmployeeAppLogin;
  String get employeeAppLoginSectionHint;
  String get employeeAppPassword;
  String get employeeAppPasswordConfirm;
  String get appAccessPasswordMismatch;
  String get appAccessSaved;
  String get clearAction;
  String get cannotDeleteOwnAccount;
  String get leaveStatusPending;
  String get leaveStatusApproved;
  String get leaveStatusRejected;
  String get markAllRead;
  String get noJobsYet;
  String get addCandidate;
  String get candidateName;
  String get candidateEmail;
  String get candidatePhone;
  String get candidateNotes;
  String get candidateAdded;
  String get candidateStageUpdated;
  String get jobDeleted;
  String get jobUpdated;
  String get jobCreated;
  String get jobStatusOpen;
  String get jobStatusClosed;
  String get jobStatusDraft;
  String get candidateStageName;
  String get candidateStageRejected;
  String get editJob;
  String get performance;
  String get reports;
  String get performanceTitle;
  String get performanceNewReview;
  String get periodLabel;
  String get ratingLabel;
  String get goalsSummary;
  String get strengths;
  String get improvementAreas;
  String get managerComment;
  String get saveReview;
  String get reviewSaved;
  String get aiSummaryCol;
  String get noAnalysisYet;
  String get analyzing;
  String get queueAiAnalysis;
  String get analyzeAi;
  String get analysisQueued;
  String get aiAnalysisGenerated;
  String get aiAnalysisCompleted;
  String get asyncMode;
  String get processing;
  String get taskFailed;
  String get reportsTitle;
  String get fromDate;
  String get toDate;
  String get generateSummary;
  String get reportQueued;
  String get executiveNarrative;
  String get loadDataFailed;
  String get welcomeHowItWorks;
  String get welcomeStep1Title;
  String get welcomeStep1Desc;
  String get welcomeStep2Title;
  String get welcomeStep2Desc;
  String get welcomeStep3Title;
  String get welcomeStep3Desc;
  String get generateWithAi;
  String get aiBriefingTitle;
  String get aiBriefingSubtitle;
  String get generateBriefing;
  String get openAiAssistant;
  String get tryAiAssistant;
  String get aiJobGenerated;
  String get askAiAboutHr;
}

class AppStringsAr extends AppStrings {
  AppStringsAr([super.locale = "ar"]);

  @override
  String get appName => "Nawa Tech HRM";
  @override
  String get appTagline => "راحة الإدارة تبدأ من هنا";
  @override
  String get login => "تسجيل الدخول";
  @override
  String get registerCompany => "تسجيل شركة جديدة";
  @override
  String get email => "البريد الإلكتروني";
  @override
  String get password => "كلمة المرور";
  @override
  String get companyName => "اسم الشركة";
  @override
  String get forgotPassword => "نسيت كلمة المرور؟";
  @override
  String get dashboard => "لوحة التحكم";
  @override
  String get employeesCount => "عدد الموظفين";
  @override
  String get todayAttendance => "الحضور اليوم";
  @override
  String get present => "حاضر";
  @override
  String get absent => "غائب";
  @override
  String get late => "متأخر";
  @override
  String get pendingLeaves => "طلبات الإجازات المعلقة";
  @override
  String get payrollStatus => "حالة الرواتب";
  @override
  String get processed => "تم المعالجة";
  @override
  String get pending => "قيد الانتظار";
  @override
  String get employees => "الموظفين";
  @override
  String get addEmployee => "إضافة موظف";
  @override
  String get editEmployee => "تعديل بيانات الموظف";
  @override
  String get employeeProfile => "ملف الموظف";
  @override
  String get personalInfo => "المعلومات الشخصية";
  @override
  String get jobInfo => "معلومات الوظيفة";
  @override
  String get salaryInfo => "معلومات الراتب";
  @override
  String get insuranceInfo => "التأمين";
  @override
  String get status => "الحالة";
  @override
  String get active => "نشط";
  @override
  String get inactive => "غير نشط";
  @override
  String get attendance => "الحضور";
  @override
  String get dailyAttendance => "الحضور اليومي";
  @override
  String get editAttendance => "تعديل الحضور";
  @override
  String get checkIn => "تسجيل الدخول";
  @override
  String get checkOut => "تسجيل الخروج";
  @override
  String get exportExcel => "تصدير Excel";
  @override
  String get exportPdf => "تصدير PDF";
  @override
  String get leave => "الإجازات";
  @override
  String get leaveRequests => "طلبات الإجازات";
  @override
  String get approve => "موافقة";
  @override
  String get reject => "رفض";
  @override
  String get leaveBalance => "رصيد الإجازات";
  @override
  String get requestLeave => "طلب إجازة";
  @override
  String get payroll => "الرواتب";
  @override
  String get monthlyPayroll => "الرواتب الشهرية";
  @override
  String get salaryBreakdown => "تفصيل الراتب";
  @override
  String get generatePayslip => "إنشاء قسيمة راتب";
  @override
  String get payslip => "قسيمة الراتب";
  @override
  String get payslipEmployeeSection => "الموظف";
  @override
  String get payslipEarningsSection => "المستحقات";
  @override
  String get payslipDeductionsSection => "الخصومات";
  @override
  String get recruitment => "التوظيف";
  @override
  String get jobListings => "الوظائف المتاحة";
  @override
  String get candidates => "المتقدمين";
  @override
  String get convertToEmployee => "تحويل لموظف";
  @override
  String get recruitmentStageNew => "جديد";
  @override
  String get recruitmentStageInterview => "مقابلة";
  @override
  String get recruitmentStageOffer => "عرض عمل";
  @override
  String get recruitmentStageHired => "تم التعيين";
  @override
  String get recruitmentJobTitleFlutterDeveloper => "مطور Flutter";
  @override
  String get recruitmentJobTitleAccountant => "محاسب";
  @override
  String get recruitmentDepartmentTechnical => "التقنية";
  @override
  String get recruitmentDepartmentFinance => "المالية";
  @override
  String get recruitmentJobStatusOpen => "مفتوح";
  @override
  String get recruitmentApplicantFileExample => "ملف المتقدم - مثال";
  @override
  String get recruitmentApplicantNameSample => "أحمد المتقدم";
  @override
  String get recruitmentApplicantRoleSample => "مطور Flutter";
  @override
  String get recruitmentApplicantEmailSample => "ahmed@email.com";
  @override
  String recruitmentApplicantsCount(int count) => "{count} متقدم".replaceAll('{count}', count.toString());
  @override
  String recruitmentApplicantIndexed(int index) => "متقدم {index}".replaceAll('{index}', index.toString());
  @override
  String get recruitmentJobDetailsTitle => "تفاصيل الوظيفة";
  @override
  String get recruitmentLocationLabel => "الموقع";
  @override
  String get recruitmentLocationValue => "الرياض";
  @override
  String get recruitmentApplicantsLabel => "المتقدمين";
  @override
  String get recruitmentDescriptionLabel => "الوصف";
  @override
  String get recruitmentJobDescriptionSample => "نبحث عن مطور Flutter متحمس للانضمام لفريقنا. يشترط الخبرة في تطوير تطبيقات متعددة المنصات والتمكن من Dart و Flutter.";
  @override
  String get settings => "الإعدادات";
  @override
  String get companyInfo => "معلومات الشركة";
  @override
  String get rolesPermissions => "الأدوار والصلاحيات";
  @override
  String get subscriptionBilling => "الاشتراك والفوترة";
  @override
  String get save => "حفظ";
  @override
  String get cancel => "إلغاء";
  @override
  String get search => "بحث";
  @override
  String get filter => "تصفية";
  @override
  String get export => "تصدير";
  @override
  String get date => "التاريخ";
  @override
  String get name => "الاسم";
  @override
  String get department => "القسم";
  @override
  String get position => "المنصب";
  @override
  String get actions => "إجراءات";
  @override
  String get view => "عرض";
  @override
  String get edit => "تعديل";
  @override
  String get delete => "حذف";
  @override
  String get appearance => "المظهر";
  @override
  String get darkMode => "الوضع الليلي";
  @override
  String get darkModeOn => "مفعّل";
  @override
  String get darkModeOff => "معطّل";
  @override
  String get lightMode => "الوضع النهاري";
  @override
  String get language => "اللغة";
  @override
  String get languageTitle => "لغة التطبيق";
  @override
  String get arabic => "العربية";
  @override
  String get english => "الإنجليزية";
  @override
  String get serverBindingTitle => "ربط الخادم (Laravel API)";
  @override
  String get serverBindingDescription => "لتفعيل الربط مع خادم Laravel أدخل عنوان الـ API (مثال: https://your-domain.com/api) وفعّل \"استخدام الخادم\"";
  @override
  String get baseUrlLabel => "عنوان الخادم (Base URL)";
  @override
  String get baseUrlHint => "https://hrm-nawa-api.onrender.com/api";
  @override
  String get useServer => "استخدام الخادم";
  @override
  String get serverEnabled => "تم تفعيل الربط بالخادم";
  @override
  String get serverDisabled => "الاعتماد على البيانات التجريبية";
  @override
  String get serverSettingsSaved => "تم حفظ إعدادات الخادم";
  @override
  String get companySavedLocal => "تم حفظ معلومات الشركة (محلياً للتجربة)";
  @override
  String get planUpgradeLater => "ترقية الخطة ستكون متاحة عبر بوابة الدفع لاحقاً.";
  @override
  String get planUpgradeStarter => "طلب ترقية Starter";
  @override
  String get planUpgradeGrowth => "طلب ترقية Growth";
  @override
  String get billingNotConfigured => "بوابة الدفع غير مفعّلة بعد — تواصل مع الدعم أو المنصة.";
  @override
  String get platformConsoleTitle => "لوحة المنصة";
  @override
  String get platformOverview => "نظرة عامة";
  @override
  String get platformCompanies => "الشركات";
  @override
  String get platformUsers => "المستخدمون";
  @override
  String get platformTrialsActive => "تجارب نشطة";
  @override
  String get platformTrialsExpired => "تجارب منتهية";
  @override
  String get platformSearchCompanies => "بحث بالاسم أو البريد";
  @override
  String get platformNoCompanies => "لا توجد شركات.";
  @override
  String get platformActivateCompany => "تفعيل";
  @override
  String get platformSuspendCompany => "تعليق";
  @override
  String get platformExtendTrial => "تمديد التجربة +14";
  @override
  String get platformSetStarter => "تفعيل Starter";
  @override
  String get platformSetGrowth => "تفعيل Growth";
  @override
  String get employeeNavHome => "الرئيسية";
  @override
  String get employeeNavAttendance => "الحضور";
  @override
  String get employeeNavLeave => "الإجازات";
  @override
  String get employeeNavPayroll => "الرواتب";
  @override
  String get employeeNavNotifications => "إشعارات";
  @override
  String get employeeNavProfile => "الملف";
  @override
  String get myNotifications => "إشعاراتي";
  @override
  String get retryAction => "إعادة المحاولة";
  @override
  String get dashboardPartialLoadError => "تعذّر تحميل بعض بيانات لوحة التحكم. تحقق من إعدادات الـ API ثم أعد المحاولة.";
  @override
  String get payslipNotFound => "لا توجد قسيمة راتب لهذا الشهر.";
  @override
  String get noNotifications => "لا توجد إشعارات";
  @override
  String get refreshTooltip => "تحديث";
  @override
  String get payslipDownloadLater => "تنزيل قسيمة PDF يُربَط بالخادم — التجربة: تم التخطيط";
  @override
  String get rolePermissionsServer => "تعديل الصلاحيات يُحفظ عبر الخادم في الإصدار الكامل";
  @override
  String jobEditServer(String jobId) => "تعديل الوظيفة {jobId} — يُحفظ عبر الخادم عند التفعيل".replaceAll('{jobId}', jobId.toString());
  @override
  String get convertEmployeeHint => "سيتم إضافة المرشح كموظف — أكمل النموذج.";
  @override
  String get sessionExpired => "انتهت الجلسة. يرجى تسجيل الدخول مجدداً.";
  @override
  String get apiHttpsRequired => "استخدم https:// لعنوان الـ API في الإنتاج (يُسمح بـ localhost).";
  @override
  String get invalidApiUrl => "أدخل عنوان API صالحاً (مثال: https://example.com/api).";
  @override
  String get apiUrlRequired => "أدخل عنوان الخادم قبل تفعيل وضع الـ API.";
  @override
  String get notificationsTitle => "الإشعارات";
  @override
  String get employeeNotificationsTitle => "إشعاراتي";
  @override
  String get phone => "رقم الهاتف";
  @override
  String get address => "العنوان";
  @override
  String get wifiAttendanceTitle => "الحضور عبر الواي فاي";
  @override
  String get wifiAttendanceBody => "يتم تسجيل الحضور فقط عند اتصال الموظف بشبكة الواي فاي الخاصة بالشركة";
  @override
  String get wifiSsidLabel => "اسم شبكة الواي فاي (SSID)";
  @override
  String get wifiSsidHint => "مثال: Company_Office";
  @override
  String get wifiSettingsSaved => "تم حفظ إعدادات شبكة الحضور";
  @override
  String get dataFromServer => "البيانات من Laravel";
  @override
  String get dataLocalDemo => "البيانات التجريبية محلياً";
  @override
  String get subscriptionPlanName => "الخطة الاحترافية";
  @override
  String get subscriptionPlanPrice => "50 موظف • 1,200 ريال/شهر";
  @override
  String get upgradePlan => "ترقية الخطة";
  @override
  String get paymentPortalLater => "صفحة الدفع والترقية تُربَط ببوابة الاشتراك عند الإطلاق";
  @override
  String get roleAdminTitle => "مدير النظام";
  @override
  String get roleAdminSubtitle => "صلاحيات كاملة";
  @override
  String get roleHrTitle => "مدير الموارد البشرية";
  @override
  String get roleHrSubtitle => "إدارة الموظفين والحضور";
  @override
  String get roleEmployeeTitle => "موظف";
  @override
  String get roleEmployeeSubtitle => "عرض بياناته فقط";
  @override
  String get featureEmployees => "الموظفين";
  @override
  String get featureAttendance => "الحضور";
  @override
  String get featureLeave => "الإجازات";
  @override
  String get featurePayroll => "الرواتب";
  @override
  String get featureRecruitment => "التوظيف";
  @override
  String get dashboardOverview => "نظرة عامة على نشاط الشركة اليوم";
  @override
  String get ofSeats => "من أصل 50 مقعد";
  @override
  String get needsReview => "تحتاج مراجعة";
  @override
  String get payrollDone => "تم";
  @override
  String get payrollMonthSample => "شهر فبراير 2025";
  @override
  String get viewAll => "عرض الكل";
  @override
  String get leaveType => "نوع الإجازة";
  @override
  String get leaveApproved => "تمت الموافقة";
  @override
  String get leaveRejected => "تم الرفض";
  @override
  String get adminProfileMenu => "الملف الشخصي";
  @override
  String get logout => "تسجيل الخروج";
  @override
  String get sampleAdminName => "أحمد المدير";
  @override
  String get sampleAdminRole => "مدير موارد بشرية";
  @override
  String get refreshAction => "تحديث";
  @override
  String get attendanceEditGrid => "تعديل حضور الجدول — يُحفظ عبر الخادم عند التفعيل";
  @override
  String attendanceEditEmployee(String name) => "تعديل حضور {name} — يُحفظ عبر الخادم عند التفعيل".replaceAll('{name}', name.toString());
  @override
  String exportPrepared(String format) => "تم تجهيز {format} للتجربة. التصدير الفعلي يُربَط بـ Laravel.".replaceAll('{format}', format.toString());
  @override
  String get formatExcel => "ملف Excel";
  @override
  String get formatPdf => "ملف PDF";
  @override
  String get payrollGenerateDemo => "تم جدولة إنشاء قسائم للتجربة. التنفيذ الفعلي من الخادم.";
  @override
  String get colEmployee => "الموظف";
  @override
  String get colBaseSalary => "الراتب الأساسي";
  @override
  String get colAllowances => "البدلات";
  @override
  String get colDeductions => "الخصومات";
  @override
  String get colNetSalary => "صافي الراتب";
  @override
  String get colStatus => "الحالة";
  @override
  String get colCheckIn => "وقت الدخول";
  @override
  String get colCheckOut => "وقت الخروج";
  @override
  String get colWorkHours => "ساعات العمل";
  @override
  String get breakdownBase => "الراتب الأساسي";
  @override
  String get breakdownAllowances => "البدلات";
  @override
  String get breakdownDeductions => "الخصومات";
  @override
  String get breakdownNet => "صافي الراتب";
  @override
  String get filterAllDepartments => "كل الأقسام";
  @override
  String filterDepartmentButton(String name) => "القسم: {name}".replaceAll('{name}', name.toString());
  @override
  String get monthFebruary2025 => "فبراير 2025";
  @override
  String get monthJanuary2025 => "يناير 2025";
  @override
  String get formSavedSuccess => "تم حفظ البيانات بنجاح";
  @override
  String get fieldRequired => "مطلوب";
  @override
  String get fullName => "الاسم الكامل";
  @override
  String get birthDate => "تاريخ الميلاد";
  @override
  String get hireDate => "تاريخ التعيين";
  @override
  String get bankAccount => "رقم الحساب البنكي";
  @override
  String get insuranceType => "نوع التأمين";
  @override
  String get insuranceHealthOpt => "تأمين صحي";
  @override
  String get insuranceSocialOpt => "تأمين اجتماعي";
  @override
  String get insuranceOtherOpt => "أخرى";
  @override
  String get policyNumber => "رقم البوليصة / رقم التأمين";
  @override
  String get insuranceCompany => "شركة التأمين";
  @override
  String get coverageStart => "تاريخ بداية التغطية";
  @override
  String get coverageEnd => "تاريخ نهاية التغطية";
  @override
  String get payslipMonthField => "الشهر";
  @override
  String get download => "تنزيل";
  @override
  String get addJob => "إضافة وظيفة";
  @override
  String get recruitmentPaidBanner => "ميزة مدفوعة - تفعيل من الإعدادات";
  @override
  String get loginBrandingTitle => "نظام إدارة الموارد البشرية";
  @override
  String get loginBrandingSubtitle => "إدارة الموظفين، الحضور، الإجازات والرواتب في مكان واحد";
  @override
  String get loginFormSubtitle => "أدخل بياناتك للوصول إلى لوحة التحكم";
  @override
  String get enterEmail => "أدخل البريد الإلكتروني";
  @override
  String get enterPassword => "أدخل كلمة المرور";
  @override
  String get forgotPasswordTitle => "استعادة كلمة المرور";
  @override
  String get forgotPasswordBody => "أدخل بريدك الإلكتروني وسنرسل لك رابطاً لإعادة تعيين كلمة المرور";
  @override
  String get sendResetLink => "إرسال الرابط";
  @override
  String get backToLogin => "العودة لتسجيل الدخول";
  @override
  String get resetLinkSent => "تم إرسال الرابط";
  @override
  String get resetLinkSentBody => "تحقق من بريدك الإلكتروني واضغط على الرابط لإعادة تعيين كلمة المرور. على الموبايل يمكن فتح الرابط مباشرة في التطبيق.";
  @override
  String get resetPasswordTitle => "تعيين كلمة مرور جديدة";
  @override
  String resetPasswordBody(String email) => "أدخل كلمة مرور جديدة لحساب $email";
  @override
  String get newPassword => "كلمة المرور الجديدة";
  @override
  String get confirmNewPassword => "تأكيد كلمة المرور";
  @override
  String get saveNewPassword => "حفظ كلمة المرور";
  @override
  String get passwordResetSuccess => "تم تغيير كلمة المرور";
  @override
  String get passwordResetSuccessBody => "يمكنك الآن تسجيل الدخول بكلمة المرور الجديدة.";
  @override
  String get resetLinkInvalid => "رابط غير صالح";
  @override
  String get resetLinkInvalidBody => "الرابط منتهي أو غير مكتمل. اطلب رابطاً جديداً من شاشة نسيت كلمة المرور.";
  @override
  String get passwordMinLength => "كلمة المرور 8 أحرف على الأقل";
  @override
  String get passwordsDoNotMatch => "كلمتا المرور غير متطابقتين";
  @override
  String get addCompanyTitle => "إضافة شركة";
  @override
  String get demoCompanyLabel => "الشركة";
  @override
  String get companyAddedSuccess => "تم إضافة الشركة بنجاح";
  @override
  String get jobTitleField => "المسمى الوظيفي";
  @override
  String get jobLocationField => "الموقع";
  @override
  String get jobDescriptionField => "الوصف";
  @override
  String get jobAddedSuccess => "تم إضافة الوظيفة بنجاح";
  @override
  String get payslipDownloading => "جاري تحميل قسيمة الراتب...";
  @override
  String get registerSubtitle => "إنشاء حساب شركة جديد - نظام متعدد المستأجرين";
  @override
  String get enterCompanyName => "أدخل اسم الشركة";
  @override
  String get haveAccountLogin => "لديك حساب؟ تسجيل الدخول";
  @override
  String get leaveAdminSubtitle => "إدارة طلبات الإجازات والموافقات";
  @override
  String get filterAll => "الكل";
  @override
  String get filterPendingShort => "معلقة";
  @override
  String get filterApprovedShort => "موافق عليها";
  @override
  String get filterRejectedShort => "مرفوضة";
  @override
  String get leaveColFrom => "من";
  @override
  String get leaveColTo => "إلى";
  @override
  String get leaveColDays => "الأيام";
  @override
  String get leaveColBalanceLeft => "الرصيد المتبقي";
  @override
  String get leaveBalancePerEmployee => "رصيد الإجازات حسب الموظف";
  @override
  String get annualShort => "سنوية";
  @override
  String get sickShort => "مرضية";
  @override
  String get emergencyShort => "طارئة";
  @override
  String get wifiChecking => "جاري التحقق...";
  @override
  String get wifiOnCompany => "متصل بشبكة الشركة";
  @override
  String get wifiOffCompany => "غير متصل - تسجيل الحضور عبر الواي فاي فقط";
  @override
  String networkLabel(String name) => "الشبكة: {name}".replaceAll('{name}', name.toString());
  @override
  String get recheckWifi => "إعادة التحقق";
  @override
  String get attendanceTodayTitle => "حالة الحضور اليوم";
  @override
  String get checkInTimeSample => "08:00";
  @override
  String get checkInRecorded => "تم تسجيل الدخول";
  @override
  String get greetingHello => "مرحباً";
  @override
  String greetingWithName(String name) => "مرحباً، {name}".replaceAll('{name}', name.toString());
  @override
  String get homeDateSample => "السبت 7 فبراير 2025";
  @override
  String get wifiCheckingHome => "جاري التحقق من شبكة الواي فاي...";
  @override
  String get wifiNotOnCompanyHome => "غير متصل بشبكة الشركة";
  @override
  String get attendanceOnlyWifiHint => "تسجيل الحضور يتم عبر شبكة الواي فاي الخاصة بالشركة فقط";
  @override
  String get quickActionsTitle => "إجراءات سريعة";
  @override
  String get attendanceLogLabel => "سجل الحضور";
  @override
  String get profileQuickLabel => "الملف الشخصي";
  @override
  String get notificationsTooltip => "الإشعارات";
  @override
  String get employeeAppSubtitle => "تطبيق الموظفين";
  @override
  String get leaveNotes => "السبب / ملاحظات";
  @override
  String get documentsSection => "المستندات";
  @override
  String get employmentContract => "عقد العمل";
  @override
  String get payslipJanuaryDoc => "قسيمة الراتب - يناير";
  @override
  String get companyLabelRow => "الشركة";
  @override
  String get roleLabelRow => "الدور";
  @override
  String get baseSalaryLabel => "الراتب الأساسي";
  @override
  String get roleDetailTitle => "تفاصيل الدور";
  @override
  String get permissionsTitle => "الصلاحيات";
  @override
  String get editPermissionsButton => "تعديل الصلاحيات";
  @override
  String get aiAssistantWelcome => "مرحباً! أنا المساعد الذكي. اسألني عن الموظفين، الحضور، الإجازات أو الرواتب.";
  @override
  String get apiBaseUrlMissing => "لم يُعرَّف عنوان الخادم.";
  @override
  String get apiErrorServer => "خطأ في الخادم";
  @override
  String apiErrorConnection(String details) => "خطأ في الاتصال: {details}".replaceAll('{details}', details.toString());
  @override
  String get apiInvalidResponse => "استجابة غير صالحة من الخادم";
  @override
  String get apiNoTokenReceived => "لم يتم استلام رمز المصادقة";
  @override
  String apiReadResponseFailed(String details) => "تعذّر قراءة الاستجابة: {details}".replaceAll('{details}', details.toString());
  @override
  String apiErrorEmployeesList(String details) => "تعذّر تحميل الموظفين: {details}".replaceAll('{details}', details.toString());
  @override
  String apiErrorEmployeeDetail(String details) => "تعذّر تحميل بيانات الموظف: {details}".replaceAll('{details}', details.toString());
  @override
  String apiErrorAttendance(String details) => "تعذّر تحميل الحضور: {details}".replaceAll('{details}', details.toString());
  @override
  String apiErrorLeaveRequests(String details) => "تعذّر تحميل طلبات الإجازات: {details}".replaceAll('{details}', details.toString());
  @override
  String apiErrorLeaveBalances(String details) => "تعذّر تحميل أرصدة الإجازات: {details}".replaceAll('{details}', details.toString());
  @override
  String apiErrorPayroll(String details) => "تعذّر تحميل الرواتب: {details}".replaceAll('{details}', details.toString());
  @override
  String apiErrorNotifications(String details) => "تعذّر تحميل الإشعارات: {details}".replaceAll('{details}', details.toString());
  @override
  String get demoUserName => "مستخدم تجريبي";
  @override
  String get leaveApproveSuccess => "تمت الموافقة على طلب الإجازة";
  @override
  String get leaveRejectSuccess => "تم رفض طلب الإجازة";
  @override
  String get registerSuccessServer => "تم إنشاء الحساب. يمكنك تسجيل الدخول الآن.";
  @override
  String get aiPanelTitle => "المساعد الذكي";
  @override
  String get aiTyping => "جاري الكتابة…";
  @override
  String get aiInputHint => "اسأل عن الموظفين، الحضور، الإجازات…";
  @override
  String get planStarter => "بداية";
  @override
  String get planStarterDesc => "حتى 25 موظفاً • نواة Nawa Tech HRM";
  @override
  String get planGrowth => "نمو";
  @override
  String get planGrowthDesc => "حتى 50 موظفاً • يشمل التوظيف";
  @override
  String get planEnterprise => "مؤسسات";
  @override
  String get planEnterpriseDesc => "حتى 200 موظف • جاهز لطبقة ذكاء عبر API";
  @override
  String get saasPlanSection => "خطة الاشتراك";
  @override
  String get trialExpiredBanner => "انتهت الفترة التجريبية. رقِّ الخطة للمتابعة.";
  @override
  String get emailUnverifiedBanner => "يرجى تأكيد بريدك الإلكتروني للمتابعة. تحقق من صندوق الوارد أو أعد إرسال الرابط.";
  @override
  String get verifyEmailTitle => "تأكيد البريد الإلكتروني";
  @override
  String get verifyEmailBody => "أرسلنا رابط تأكيد إلى بريدك. افتح الرابط من هاتفك أو الحاسوب ثم ارجع للتطبيق.";
  @override
  String get resendVerificationLink => "إعادة إرسال رابط التأكيد";
  @override
  String get verificationLinkSent => "تم إرسال رابط التأكيد. تحقق من بريدك الإلكتروني.";
  @override
  String get verifyContinueButton => "تم التأكيد — متابعة";
  @override
  String get verifyingEmail => "جارٍ تأكيد البريد...";
  @override
  String get verifyEmailSuccess => "تم تأكيد بريدك الإلكتروني بنجاح";
  @override
  String get verifyEmailFailed => "تعذر تأكيد البريد. اطلب رابطاً جديداً.";
  @override
  String trialEndsOn(String date) => "تنتهي التجربة في $date";
  @override
  String trialDaysLeft(int days) => "متبقي $days يوم في التجربة المجانية";
  @override
  String get saasRecruitmentLocked => "رقّ الخطة من الإعدادات لفتح التوظيف.";
  @override
  String get employeeLimitReached => "بلغت حد الموظفين للخطة. رقِّ من الإعدادات.";
  @override
  String get loginUseWebForAdmin => "هذا الحساب للإدارة. سجّل الدخول من لوحة الويب.";
  @override
  String get loginUseMobileForEmployee => "هذا حساب موظف. استخدم تطبيق الجوال لتسجيل الدخول.";
  @override
  String get employeeLoginCredentialsHint => "استخدم البريد وكلمة المرور التي أنشأها المسؤول لدخول التطبيق.";
  @override
  String get employeeAppLoginTab => "دخول تطبيق الجوال";
  @override
  String get enableEmployeeAppLogin => "تفعيل دخول تطبيق الجوال";
  @override
  String get employeeAppLoginSectionHint => "إنشاء أو تحديث كلمة مرور التطبيق للموظف. الدخول من الهاتف فقط.";
  @override
  String get employeeAppPassword => "كلمة مرور التطبيق";
  @override
  String get employeeAppPasswordConfirm => "تأكيد كلمة مرور التطبيق";
  @override
  String get appAccessPasswordMismatch => "كلمتا مرور التطبيق غير متطابقتين أو أقل من 8 أحرف.";
  @override
  String get appAccessSaved => "تم تحديث صلاحية دخول التطبيق.";
  @override
  String get clearAction => "مسح";
  @override
  String get cannotDeleteOwnAccount => "لا يمكن حذف حسابك";
  @override
  String get leaveStatusPending => "معلقة";
  @override
  String get leaveStatusApproved => "موافقة عليها";
  @override
  String get leaveStatusRejected => "مرفوضة";
  @override
  String get markAllRead => "تعليم الكل كمقروء";
  @override
  String get noJobsYet => "لا توجد وظائف بعد. أضف أول وظيفة.";
  @override
  String get addCandidate => "إضافة مرشح";
  @override
  String get candidateName => "اسم المرشح";
  @override
  String get candidateEmail => "بريد المرشح الإلكتروني";
  @override
  String get candidatePhone => "هاتف المرشح";
  @override
  String get candidateNotes => "ملاحظات";
  @override
  String get candidateAdded => "تمت إضافة المرشح";
  @override
  String get candidateStageUpdated => "تم تحديث المرحلة";
  @override
  String get jobDeleted => "تم حذف الوظيفة";
  @override
  String get jobUpdated => "تم تحديث الوظيفة";
  @override
  String get jobCreated => "تم إنشاء الوظيفة بنجاح";
  @override
  String get jobStatusOpen => "مفتوحة";
  @override
  String get jobStatusClosed => "مغلقة";
  @override
  String get jobStatusDraft => "مسودة";
  @override
  String get candidateStageName => "المرحلة";
  @override
  String get candidateStageRejected => "مرفوض";
  @override
  String get editJob => "تعديل الوظيفة";
  @override
  String get performance => "الأداء";
  @override
  String get reports => "التقارير";
  @override
  String get performanceTitle => "تحليل أداء الموظفين";
  @override
  String get performanceNewReview => "إدخال تقييم جديد";
  @override
  String get periodLabel => "الفترة";
  @override
  String get ratingLabel => "التقييم";
  @override
  String get goalsSummary => "ملخص الأهداف";
  @override
  String get strengths => "نقاط القوة";
  @override
  String get improvementAreas => "مجالات التحسين";
  @override
  String get managerComment => "تعليق المدير";
  @override
  String get saveReview => "حفظ التقييم";
  @override
  String get reviewSaved => "تم حفظ التقييم";
  @override
  String get aiSummaryCol => "ملخص ذكي";
  @override
  String get noAnalysisYet => "لا يوجد تحليل بعد";
  @override
  String get analyzing => "جاري...";
  @override
  String get queueAiAnalysis => "جدولة تحليل AI";
  @override
  String get analyzeAi => "تحليل AI";
  @override
  String get analysisQueued => "تمت جدولة التحليل وسيتم التحديث تلقائياً";
  @override
  String get aiAnalysisGenerated => "تم توليد التحليل الذكي";
  @override
  String get aiAnalysisCompleted => "اكتمل التحليل الذكي";
  @override
  String get asyncMode => "وضع Async";
  @override
  String get processing => "قيد المعالجة...";
  @override
  String get taskFailed => "فشلت المهمة";
  @override
  String get reportsTitle => "تقارير ذكية وملخصات الإدارة";
  @override
  String get fromDate => "من";
  @override
  String get toDate => "إلى";
  @override
  String get generateSummary => "توليد الملخص";
  @override
  String get reportQueued => "تمت جدولة التقرير وسيظهر فور اكتماله";
  @override
  String get executiveNarrative => "السرد التنفيذي";
  @override
  String get loadDataFailed => "تعذّر تحميل البيانات. تحقق من إعدادات الـ API ثم أعد المحاولة.";
  @override
  String get welcomeHowItWorks => "كيف يعمل";
  @override
  String get welcomeStep1Title => "شغّل الـ API ولوحة الإدارة";
  @override
  String get welcomeStep1Desc => "شغّل Laravel، زرّع البيانات التجريبية، وسجّل دخول لوحة الأدمن على الويب.";
  @override
  String get welcomeStep2Title => "افتح تطبيق الموظف";
  @override
  String get welcomeStep2Desc => "استخدم تطبيق الموبايل بحسابات العرض التجريبي للحضور والإجازات وقسيمة الراتب.";
  @override
  String get welcomeStep3Title => "استكشف AI والتوظيف";
  @override
  String get welcomeStep3Desc => "جرّب مركز AI، مطابقة التوظيف، تقييمات الأداء، والتقارير الذكية.";
  @override
  String get generateWithAi => "توليد بالذكاء الاصطناعي";
  @override
  String get aiBriefingTitle => "ملخص HR بالذكاء الاصطناعي";
  @override
  String get aiBriefingSubtitle => "ملخص ذكي لآخر 30 يوماً";
  @override
  String get generateBriefing => "توليد الملخص";
  @override
  String get openAiAssistant => "المساعد الذكي";
  @override
  String get tryAiAssistant => "جرّب المساعد الذكي";
  @override
  String get aiJobGenerated => "تم توليد وصف الوظيفة";
  @override
  String get askAiAboutHr => "اسأل عن الإجازات، الراتب، الحضور…";
}

class AppStringsEn extends AppStrings {
  AppStringsEn([super.locale = "en"]);

  @override
  String get appName => "Nawa Tech HRM";
  @override
  String get appTagline => "Where management feels effortless";
  @override
  String get login => "Sign in";
  @override
  String get registerCompany => "Register company";
  @override
  String get email => "Email";
  @override
  String get password => "Password";
  @override
  String get companyName => "Company name";
  @override
  String get forgotPassword => "Forgot password?";
  @override
  String get dashboard => "Dashboard";
  @override
  String get employeesCount => "Employees";
  @override
  String get todayAttendance => "Today's attendance";
  @override
  String get present => "Present";
  @override
  String get absent => "Absent";
  @override
  String get late => "Late";
  @override
  String get pendingLeaves => "Pending leave requests";
  @override
  String get payrollStatus => "Payroll status";
  @override
  String get processed => "Processed";
  @override
  String get pending => "Pending";
  @override
  String get employees => "Employees";
  @override
  String get addEmployee => "Add employee";
  @override
  String get editEmployee => "Edit employee";
  @override
  String get employeeProfile => "Employee profile";
  @override
  String get personalInfo => "Personal information";
  @override
  String get jobInfo => "Job information";
  @override
  String get salaryInfo => "Salary";
  @override
  String get insuranceInfo => "Insurance";
  @override
  String get status => "Status";
  @override
  String get active => "Active";
  @override
  String get inactive => "Inactive";
  @override
  String get attendance => "Attendance";
  @override
  String get dailyAttendance => "Daily attendance";
  @override
  String get editAttendance => "Edit attendance";
  @override
  String get checkIn => "Check in";
  @override
  String get checkOut => "Check out";
  @override
  String get exportExcel => "Export Excel";
  @override
  String get exportPdf => "Export PDF";
  @override
  String get leave => "Leave";
  @override
  String get leaveRequests => "Leave requests";
  @override
  String get approve => "Approve";
  @override
  String get reject => "Reject";
  @override
  String get leaveBalance => "Leave balance";
  @override
  String get requestLeave => "Request leave";
  @override
  String get payroll => "Payroll";
  @override
  String get monthlyPayroll => "Monthly payroll";
  @override
  String get salaryBreakdown => "Salary breakdown";
  @override
  String get generatePayslip => "Generate payslip";
  @override
  String get payslip => "Payslip";
  @override
  String get payslipEmployeeSection => "Employee";
  @override
  String get payslipEarningsSection => "Earnings";
  @override
  String get payslipDeductionsSection => "Deductions";
  @override
  String get recruitment => "Recruitment";
  @override
  String get jobListings => "Job listings";
  @override
  String get candidates => "Candidates";
  @override
  String get convertToEmployee => "Convert to employee";
  @override
  String get recruitmentStageNew => "New";
  @override
  String get recruitmentStageInterview => "Interview";
  @override
  String get recruitmentStageOffer => "Job offer";
  @override
  String get recruitmentStageHired => "Hired";
  @override
  String get recruitmentJobTitleFlutterDeveloper => "Flutter Developer";
  @override
  String get recruitmentJobTitleAccountant => "Accountant";
  @override
  String get recruitmentDepartmentTechnical => "Technology";
  @override
  String get recruitmentDepartmentFinance => "Finance";
  @override
  String get recruitmentJobStatusOpen => "Open";
  @override
  String get recruitmentApplicantFileExample => "Applicant file — example";
  @override
  String get recruitmentApplicantNameSample => "Ahmed Applicant";
  @override
  String get recruitmentApplicantRoleSample => "Flutter Developer";
  @override
  String get recruitmentApplicantEmailSample => "ahmed@email.com";
  @override
  String recruitmentApplicantsCount(int count) => "{count} applicants".replaceAll('{count}', count.toString());
  @override
  String recruitmentApplicantIndexed(int index) => "Applicant {index}".replaceAll('{index}', index.toString());
  @override
  String get recruitmentJobDetailsTitle => "Job details";
  @override
  String get recruitmentLocationLabel => "Location";
  @override
  String get recruitmentLocationValue => "Riyadh";
  @override
  String get recruitmentApplicantsLabel => "Applicants";
  @override
  String get recruitmentDescriptionLabel => "Description";
  @override
  String get recruitmentJobDescriptionSample => "We are looking for a passionate Flutter developer to join our team. Experience building multi-platform applications is required, along with strong Dart and Flutter skills.";
  @override
  String get settings => "Settings";
  @override
  String get companyInfo => "Company information";
  @override
  String get rolesPermissions => "Roles & permissions";
  @override
  String get subscriptionBilling => "Subscription & billing";
  @override
  String get save => "Save";
  @override
  String get cancel => "Cancel";
  @override
  String get search => "Search";
  @override
  String get filter => "Filter";
  @override
  String get export => "Export";
  @override
  String get date => "Date";
  @override
  String get name => "Name";
  @override
  String get department => "Department";
  @override
  String get position => "Position";
  @override
  String get actions => "Actions";
  @override
  String get view => "View";
  @override
  String get edit => "Edit";
  @override
  String get delete => "Delete";
  @override
  String get appearance => "Appearance";
  @override
  String get darkMode => "Dark mode";
  @override
  String get darkModeOn => "On";
  @override
  String get darkModeOff => "Off";
  @override
  String get lightMode => "Light mode";
  @override
  String get language => "Language";
  @override
  String get languageTitle => "App language";
  @override
  String get arabic => "Arabic";
  @override
  String get english => "English";
  @override
  String get serverBindingTitle => "Server (Laravel API)";
  @override
  String get serverBindingDescription => "Enter your API base URL (e.g. https://your-domain.com/api) and enable \"Use server\" to connect.";
  @override
  String get baseUrlLabel => "Base URL";
  @override
  String get baseUrlHint => "https://hrm-nawa-api.onrender.com/api";
  @override
  String get useServer => "Use server";
  @override
  String get serverEnabled => "Server connection enabled";
  @override
  String get serverDisabled => "Using demo data";
  @override
  String get serverSettingsSaved => "Server settings saved";
  @override
  String get companySavedLocal => "Company info saved locally (demo)";
  @override
  String get planUpgradeLater => "Plan upgrades will be available via the billing portal.";
  @override
  String get planUpgradeStarter => "Request Starter upgrade";
  @override
  String get planUpgradeGrowth => "Request Growth upgrade";
  @override
  String get billingNotConfigured => "Billing portal is not configured yet — contact support or platform admin.";
  @override
  String get platformConsoleTitle => "Platform console";
  @override
  String get platformOverview => "Overview";
  @override
  String get platformCompanies => "Companies";
  @override
  String get platformUsers => "Users";
  @override
  String get platformTrialsActive => "Active trials";
  @override
  String get platformTrialsExpired => "Expired trials";
  @override
  String get platformSearchCompanies => "Search by name or email";
  @override
  String get platformNoCompanies => "No companies found.";
  @override
  String get platformActivateCompany => "Activate";
  @override
  String get platformSuspendCompany => "Suspend";
  @override
  String get platformExtendTrial => "Extend trial +14";
  @override
  String get platformSetStarter => "Set Starter";
  @override
  String get platformSetGrowth => "Set Growth";
  @override
  String get employeeNavHome => "Home";
  @override
  String get employeeNavAttendance => "Attendance";
  @override
  String get employeeNavLeave => "Leave";
  @override
  String get employeeNavPayroll => "Payroll";
  @override
  String get employeeNavNotifications => "Alerts";
  @override
  String get employeeNavProfile => "Profile";
  @override
  String get myNotifications => "My notifications";
  @override
  String get retryAction => "Retry";
  @override
  String get dashboardPartialLoadError => "Some dashboard data could not be loaded. Check API settings and try again.";
  @override
  String get payslipNotFound => "No payslip found for this month.";
  @override
  String get noNotifications => "No notifications";
  @override
  String get refreshTooltip => "Refresh";
  @override
  String get payslipDownloadLater => "PDF download will use the server in production (demo: planned).";
  @override
  String get rolePermissionsServer => "Permission changes are saved on the server in the full release.";
  @override
  String jobEditServer(String jobId) => "Editing job {jobId} — saved on the server when enabled.".replaceAll('{jobId}', jobId.toString());
  @override
  String get convertEmployeeHint => "Candidate will be added as an employee (complete the form).";
  @override
  String get sessionExpired => "Session expired. Please sign in again.";
  @override
  String get apiHttpsRequired => "Use https:// for the API URL in production (localhost is allowed).";
  @override
  String get invalidApiUrl => "Enter a valid API URL (e.g. https://example.com/api).";
  @override
  String get apiUrlRequired => "Enter the server URL before enabling API mode.";
  @override
  String get notificationsTitle => "Notifications";
  @override
  String get employeeNotificationsTitle => "My notifications";
  @override
  String get phone => "Phone";
  @override
  String get address => "Address";
  @override
  String get wifiAttendanceTitle => "Wi‑Fi attendance";
  @override
  String get wifiAttendanceBody => "Check-in is allowed only when the device is on the company Wi‑Fi.";
  @override
  String get wifiSsidLabel => "Wi‑Fi network name (SSID)";
  @override
  String get wifiSsidHint => "e.g. Company_Office";
  @override
  String get wifiSettingsSaved => "Wi‑Fi attendance settings saved";
  @override
  String get dataFromServer => "Data from Laravel";
  @override
  String get dataLocalDemo => "Local demo data";
  @override
  String get subscriptionPlanName => "Professional plan";
  @override
  String get subscriptionPlanPrice => "50 employees • 1,200 SAR/month";
  @override
  String get upgradePlan => "Upgrade plan";
  @override
  String get paymentPortalLater => "Payment and upgrades will connect to the billing portal at launch.";
  @override
  String get roleAdminTitle => "System administrator";
  @override
  String get roleAdminSubtitle => "Full access";
  @override
  String get roleHrTitle => "HR manager";
  @override
  String get roleHrSubtitle => "Employees and attendance";
  @override
  String get roleEmployeeTitle => "Employee";
  @override
  String get roleEmployeeSubtitle => "Own data only";
  @override
  String get featureEmployees => "Employees";
  @override
  String get featureAttendance => "Attendance";
  @override
  String get featureLeave => "Leave";
  @override
  String get featurePayroll => "Payroll";
  @override
  String get featureRecruitment => "Recruitment";
  @override
  String get dashboardOverview => "Company activity at a glance";
  @override
  String get ofSeats => "of 50 seats";
  @override
  String get needsReview => "Awaiting review";
  @override
  String get payrollDone => "Done";
  @override
  String get payrollMonthSample => "February 2025";
  @override
  String get viewAll => "View all";
  @override
  String get leaveType => "Leave type";
  @override
  String get leaveApproved => "Approved";
  @override
  String get leaveRejected => "Rejected";
  @override
  String get adminProfileMenu => "Profile";
  @override
  String get logout => "Sign out";
  @override
  String get sampleAdminName => "Ahmed (Manager)";
  @override
  String get sampleAdminRole => "HR Manager";
  @override
  String get refreshAction => "Refresh";
  @override
  String get attendanceEditGrid => "Edit attendance for the table — saved on the server when enabled.";
  @override
  String attendanceEditEmployee(String name) => "Edit attendance for {name} — saved on the server when enabled.".replaceAll('{name}', name.toString());
  @override
  String exportPrepared(String format) => "{format} prepared for demo. Real export connects to Laravel.".replaceAll('{format}', format.toString());
  @override
  String get formatExcel => "Excel file";
  @override
  String get formatPdf => "PDF file";
  @override
  String get payrollGenerateDemo => "Payslip generation scheduled for demo. Execution runs on the server.";
  @override
  String get colEmployee => "Employee";
  @override
  String get colBaseSalary => "Base salary";
  @override
  String get colAllowances => "Allowances";
  @override
  String get colDeductions => "Deductions";
  @override
  String get colNetSalary => "Net salary";
  @override
  String get colStatus => "Status";
  @override
  String get colCheckIn => "Check-in time";
  @override
  String get colCheckOut => "Check-out time";
  @override
  String get colWorkHours => "Work hours";
  @override
  String get breakdownBase => "Base salary";
  @override
  String get breakdownAllowances => "Allowances";
  @override
  String get breakdownDeductions => "Deductions";
  @override
  String get breakdownNet => "Net pay";
  @override
  String get filterAllDepartments => "All departments";
  @override
  String filterDepartmentButton(String name) => "Dept: {name}".replaceAll('{name}', name.toString());
  @override
  String get monthFebruary2025 => "February 2025";
  @override
  String get monthJanuary2025 => "January 2025";
  @override
  String get formSavedSuccess => "Saved successfully";
  @override
  String get fieldRequired => "Required";
  @override
  String get fullName => "Full name";
  @override
  String get birthDate => "Date of birth";
  @override
  String get hireDate => "Hire date";
  @override
  String get bankAccount => "Bank account number";
  @override
  String get insuranceType => "Insurance type";
  @override
  String get insuranceHealthOpt => "Health insurance";
  @override
  String get insuranceSocialOpt => "Social insurance";
  @override
  String get insuranceOtherOpt => "Other";
  @override
  String get policyNumber => "Policy / member ID";
  @override
  String get insuranceCompany => "Insurance provider";
  @override
  String get coverageStart => "Coverage start";
  @override
  String get coverageEnd => "Coverage end";
  @override
  String get payslipMonthField => "Pay period";
  @override
  String get download => "Download";
  @override
  String get addJob => "Add job";
  @override
  String get recruitmentPaidBanner => "Paid feature — enable in settings";
  @override
  String get loginBrandingTitle => "Human resources management";
  @override
  String get loginBrandingSubtitle => "Employees, attendance, leave and payroll in one place.";
  @override
  String get loginFormSubtitle => "Enter your credentials to access the dashboard.";
  @override
  String get enterEmail => "Enter your email";
  @override
  String get enterPassword => "Enter your password";
  @override
  String get forgotPasswordTitle => "Reset password";
  @override
  String get forgotPasswordBody => "Enter your email and we will send a reset link.";
  @override
  String get sendResetLink => "Send link";
  @override
  String get backToLogin => "Back to sign in";
  @override
  String get resetLinkSent => "Link sent";
  @override
  String get resetLinkSentBody => "Check your email and follow the link to reset your password. On mobile, the link can open the app directly.";
  @override
  String get resetPasswordTitle => "Set a new password";
  @override
  String resetPasswordBody(String email) => "Choose a new password for $email";
  @override
  String get newPassword => "New password";
  @override
  String get confirmNewPassword => "Confirm password";
  @override
  String get saveNewPassword => "Save password";
  @override
  String get passwordResetSuccess => "Password updated";
  @override
  String get passwordResetSuccessBody => "You can now sign in with your new password.";
  @override
  String get resetLinkInvalid => "Invalid link";
  @override
  String get resetLinkInvalidBody => "This reset link is incomplete or expired. Request a new one from Forgot password.";
  @override
  String get passwordMinLength => "Password must be at least 8 characters";
  @override
  String get passwordsDoNotMatch => "Passwords do not match";
  @override
  String get addCompanyTitle => "Add company";
  @override
  String get demoCompanyLabel => "Company";
  @override
  String get companyAddedSuccess => "Company added successfully";
  @override
  String get jobTitleField => "Job title";
  @override
  String get jobLocationField => "Location";
  @override
  String get jobDescriptionField => "Description";
  @override
  String get jobAddedSuccess => "Job added successfully";
  @override
  String get payslipDownloading => "Downloading payslip…";
  @override
  String get registerSubtitle => "Create a new company account — multi-tenant Nawa Tech HRM";
  @override
  String get enterCompanyName => "Enter company name";
  @override
  String get haveAccountLogin => "Already have an account? Sign in";
  @override
  String get leaveAdminSubtitle => "Manage leave requests and approvals";
  @override
  String get filterAll => "All";
  @override
  String get filterPendingShort => "Pending";
  @override
  String get filterApprovedShort => "Approved";
  @override
  String get filterRejectedShort => "Rejected";
  @override
  String get leaveColFrom => "From";
  @override
  String get leaveColTo => "To";
  @override
  String get leaveColDays => "Days";
  @override
  String get leaveColBalanceLeft => "Balance left";
  @override
  String get leaveBalancePerEmployee => "Leave balance by employee";
  @override
  String get annualShort => "Annual";
  @override
  String get sickShort => "Sick";
  @override
  String get emergencyShort => "Emergency";
  @override
  String get wifiChecking => "Checking…";
  @override
  String get wifiOnCompany => "Connected to company network";
  @override
  String get wifiOffCompany => "Not connected — attendance only on company Wi‑Fi";
  @override
  String networkLabel(String name) => "Network: {name}".replaceAll('{name}', name.toString());
  @override
  String get recheckWifi => "Recheck";
  @override
  String get attendanceTodayTitle => "Today's attendance";
  @override
  String get checkInTimeSample => "08:00";
  @override
  String get checkInRecorded => "Checked in";
  @override
  String get greetingHello => "Hello";
  @override
  String greetingWithName(String name) => "Hello, {name}".replaceAll('{name}', name.toString());
  @override
  String get homeDateSample => "Saturday, 7 February 2025";
  @override
  String get wifiCheckingHome => "Checking Wi‑Fi…";
  @override
  String get wifiNotOnCompanyHome => "Not on company network";
  @override
  String get attendanceOnlyWifiHint => "Check-in works only on the company Wi‑Fi.";
  @override
  String get quickActionsTitle => "Quick actions";
  @override
  String get attendanceLogLabel => "Attendance log";
  @override
  String get profileQuickLabel => "Profile";
  @override
  String get notificationsTooltip => "Notifications";
  @override
  String get employeeAppSubtitle => "Employee app";
  @override
  String get leaveNotes => "Reason / notes";
  @override
  String get documentsSection => "Documents";
  @override
  String get employmentContract => "Employment contract";
  @override
  String get payslipJanuaryDoc => "Payslip — January";
  @override
  String get companyLabelRow => "Company";
  @override
  String get roleLabelRow => "Role";
  @override
  String get baseSalaryLabel => "Base salary";
  @override
  String get roleDetailTitle => "Role details";
  @override
  String get permissionsTitle => "Permissions";
  @override
  String get editPermissionsButton => "Edit permissions";
  @override
  String get aiAssistantWelcome => "Hi! I am your assistant. Ask about employees, attendance, leave, or payroll.";
  @override
  String get apiBaseUrlMissing => "Server URL is not configured.";
  @override
  String get apiErrorServer => "Server error";
  @override
  String apiErrorConnection(String details) => "Connection error: {details}".replaceAll('{details}', details.toString());
  @override
  String get apiInvalidResponse => "Invalid response from server";
  @override
  String get apiNoTokenReceived => "No authentication token received";
  @override
  String apiReadResponseFailed(String details) => "Could not read server response: {details}".replaceAll('{details}', details.toString());
  @override
  String apiErrorEmployeesList(String details) => "Could not load employees: {details}".replaceAll('{details}', details.toString());
  @override
  String apiErrorEmployeeDetail(String details) => "Could not load employee: {details}".replaceAll('{details}', details.toString());
  @override
  String apiErrorAttendance(String details) => "Could not load attendance: {details}".replaceAll('{details}', details.toString());
  @override
  String apiErrorLeaveRequests(String details) => "Could not load leave requests: {details}".replaceAll('{details}', details.toString());
  @override
  String apiErrorLeaveBalances(String details) => "Could not load leave balances: {details}".replaceAll('{details}', details.toString());
  @override
  String apiErrorPayroll(String details) => "Could not load payroll: {details}".replaceAll('{details}', details.toString());
  @override
  String apiErrorNotifications(String details) => "Could not load notifications: {details}".replaceAll('{details}', details.toString());
  @override
  String get demoUserName => "Demo user";
  @override
  String get leaveApproveSuccess => "Leave request approved";
  @override
  String get leaveRejectSuccess => "Leave request rejected";
  @override
  String get registerSuccessServer => "Account created. You can sign in now.";
  @override
  String get aiPanelTitle => "AI assistant";
  @override
  String get aiTyping => "Typing…";
  @override
  String get aiInputHint => "Ask about employees, attendance, leave…";
  @override
  String get planStarter => "Starter";
  @override
  String get planStarterDesc => "Up to 25 employees • core Nawa Tech HRM";
  @override
  String get planGrowth => "Growth";
  @override
  String get planGrowthDesc => "Up to 50 employees • includes recruitment";
  @override
  String get planEnterprise => "Enterprise";
  @override
  String get planEnterpriseDesc => "Up to 200 employees • recruitment + AI tier ready";
  @override
  String get saasPlanSection => "Subscription plan";
  @override
  String get trialExpiredBanner => "Your free trial has expired. Upgrade to continue.";
  @override
  String get emailUnverifiedBanner => "Please verify your email to continue. Check your inbox or resend the link.";
  @override
  String get verifyEmailTitle => "Verify your email";
  @override
  String get verifyEmailBody => "We sent a confirmation link to your inbox. Open it on your phone or computer, then return here.";
  @override
  String get resendVerificationLink => "Resend verification link";
  @override
  String get verificationLinkSent => "Verification link sent. Check your email.";
  @override
  String get verifyContinueButton => "I verified — continue";
  @override
  String get verifyingEmail => "Verifying email...";
  @override
  String get verifyEmailSuccess => "Your email was verified successfully";
  @override
  String get verifyEmailFailed => "Could not verify email. Request a new link.";
  @override
  String trialEndsOn(String date) => "Trial ends on $date";
  @override
  String trialDaysLeft(int days) => "$days days left in your free trial";
  @override
  String get saasRecruitmentLocked => "Upgrade plan in Settings to unlock recruitment.";
  @override
  String get employeeLimitReached => "Employee limit for your plan reached. Upgrade in Settings.";
  @override
  String get loginUseWebForAdmin => "This account is for administrators. Sign in from the web admin panel.";
  @override
  String get loginUseMobileForEmployee => "This account is for employees. Use the mobile app to sign in.";
  @override
  String get employeeLoginCredentialsHint => "Use the email and password your administrator created for mobile access.";
  @override
  String get employeeAppLoginTab => "Mobile app login";
  @override
  String get enableEmployeeAppLogin => "Enable mobile app login";
  @override
  String get employeeAppLoginSectionHint => "Creates or updates the employee’s app password. Employees sign in on the phone only.";
  @override
  String get employeeAppPassword => "App password";
  @override
  String get employeeAppPasswordConfirm => "Confirm app password";
  @override
  String get appAccessPasswordMismatch => "App passwords do not match or are too short (min 8).";
  @override
  String get appAccessSaved => "Mobile app access updated.";
  @override
  String get clearAction => "Clear";
  @override
  String get cannotDeleteOwnAccount => "Cannot delete your own account";
  @override
  String get leaveStatusPending => "Pending";
  @override
  String get leaveStatusApproved => "Approved";
  @override
  String get leaveStatusRejected => "Rejected";
  @override
  String get markAllRead => "Mark all as read";
  @override
  String get noJobsYet => "No job postings yet. Add your first job.";
  @override
  String get addCandidate => "Add candidate";
  @override
  String get candidateName => "Candidate name";
  @override
  String get candidateEmail => "Candidate email";
  @override
  String get candidatePhone => "Candidate phone";
  @override
  String get candidateNotes => "Notes";
  @override
  String get candidateAdded => "Candidate added";
  @override
  String get candidateStageUpdated => "Stage updated";
  @override
  String get jobDeleted => "Job deleted";
  @override
  String get jobUpdated => "Job updated";
  @override
  String get jobCreated => "Job created successfully";
  @override
  String get jobStatusOpen => "Open";
  @override
  String get jobStatusClosed => "Closed";
  @override
  String get jobStatusDraft => "Draft";
  @override
  String get candidateStageName => "Stage";
  @override
  String get candidateStageRejected => "Rejected";
  @override
  String get editJob => "Edit job";
  @override
  String get performance => "Performance";
  @override
  String get reports => "Reports";
  @override
  String get performanceTitle => "Employee Performance Analysis";
  @override
  String get performanceNewReview => "New Review Input";
  @override
  String get periodLabel => "Period";
  @override
  String get ratingLabel => "Rating";
  @override
  String get goalsSummary => "Goals summary";
  @override
  String get strengths => "Strengths";
  @override
  String get improvementAreas => "Improvement areas";
  @override
  String get managerComment => "Manager comment";
  @override
  String get saveReview => "Save review";
  @override
  String get reviewSaved => "Review saved";
  @override
  String get aiSummaryCol => "AI summary";
  @override
  String get noAnalysisYet => "No analysis yet";
  @override
  String get analyzing => "Analyzing...";
  @override
  String get queueAiAnalysis => "Queue AI analysis";
  @override
  String get analyzeAi => "Analyze AI";
  @override
  String get analysisQueued => "Analysis queued and auto-refresh enabled";
  @override
  String get aiAnalysisGenerated => "AI analysis generated";
  @override
  String get aiAnalysisCompleted => "AI analysis completed";
  @override
  String get asyncMode => "Async mode";
  @override
  String get processing => "Processing...";
  @override
  String get taskFailed => "Task failed";
  @override
  String get reportsTitle => "AI Reports & Dashboard Summaries";
  @override
  String get fromDate => "From";
  @override
  String get toDate => "To";
  @override
  String get generateSummary => "Generate summary";
  @override
  String get reportQueued => "Report queued and will appear once completed";
  @override
  String get executiveNarrative => "Executive Narrative";
  @override
  String get loadDataFailed => "Could not load data. Check API settings and try again.";
  @override
  String get welcomeHowItWorks => "How it works";
  @override
  String get welcomeStep1Title => "Start the API & admin demo";
  @override
  String get welcomeStep1Desc => "Run Laravel, seed demo data, and sign in to the web admin dashboard.";
  @override
  String get welcomeStep2Title => "Open the employee app";
  @override
  String get welcomeStep2Desc => "Use the mobile app with demo credentials to try attendance, leave, and payslip.";
  @override
  String get welcomeStep3Title => "Explore AI & recruitment";
  @override
  String get welcomeStep3Desc => "Try AI Command Center, recruitment matching, performance reviews, and reports.";
  @override
  String get generateWithAi => "Generate with AI";
  @override
  String get aiBriefingTitle => "AI HR Briefing";
  @override
  String get aiBriefingSubtitle => "Smart 30-day summary for your team";
  @override
  String get generateBriefing => "Generate briefing";
  @override
  String get openAiAssistant => "AI Assistant";
  @override
  String get tryAiAssistant => "Try AI Assistant";
  @override
  String get aiJobGenerated => "Job description generated";
  @override
  String get askAiAboutHr => "Ask about leave, payslip, attendance…";
}

class _AppStringsDelegate extends LocalizationsDelegate<AppStrings> {
  const _AppStringsDelegate();

  @override
  bool isSupported(Locale locale) =>
      <String>['ar', 'en'].contains(locale.languageCode);

  @override
  Future<AppStrings> load(Locale locale) async => lookupAppStrings(locale);

  @override
  bool shouldReload(_AppStringsDelegate old) => false;
}

AppStrings lookupAppStrings(Locale locale) {
  switch (locale.languageCode) {
    case 'en':
      return AppStringsEn();
    case 'ar':
    default:
      return AppStringsAr();
  }
}
