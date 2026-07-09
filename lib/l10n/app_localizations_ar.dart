// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Arabic (`ar`).
class AppLocalizationsAr extends AppLocalizations {
  AppLocalizationsAr([String locale = 'ar']) : super(locale);

  @override
  String get appName => 'Nawa Tech HRM';

  @override
  String get appTagline => 'راحة الإدارة تبدأ من هنا';

  @override
  String get login => 'تسجيل الدخول';

  @override
  String get registerCompany => 'تسجيل شركة جديدة';

  @override
  String get email => 'البريد الإلكتروني';

  @override
  String get password => 'كلمة المرور';

  @override
  String get companyName => 'اسم الشركة';

  @override
  String get forgotPassword => 'نسيت كلمة المرور؟';

  @override
  String get dashboard => 'لوحة التحكم';

  @override
  String get employeesCount => 'عدد الموظفين';

  @override
  String get todayAttendance => 'الحضور اليوم';

  @override
  String get present => 'حاضر';

  @override
  String get absent => 'غائب';

  @override
  String get late => 'متأخر';

  @override
  String get pendingLeaves => 'طلبات الإجازات المعلقة';

  @override
  String get payrollStatus => 'حالة الرواتب';

  @override
  String get processed => 'تم المعالجة';

  @override
  String get pending => 'قيد الانتظار';

  @override
  String get employees => 'الموظفين';

  @override
  String get addEmployee => 'إضافة موظف';

  @override
  String get editEmployee => 'تعديل بيانات الموظف';

  @override
  String get employeeProfile => 'ملف الموظف';

  @override
  String get personalInfo => 'المعلومات الشخصية';

  @override
  String get jobInfo => 'معلومات الوظيفة';

  @override
  String get salaryInfo => 'معلومات الراتب';

  @override
  String get insuranceInfo => 'التأمين';

  @override
  String get status => 'الحالة';

  @override
  String get active => 'نشط';

  @override
  String get inactive => 'غير نشط';

  @override
  String get attendance => 'الحضور';

  @override
  String get dailyAttendance => 'الحضور اليومي';

  @override
  String get editAttendance => 'تعديل الحضور';

  @override
  String get checkIn => 'تسجيل الدخول';

  @override
  String get checkOut => 'تسجيل الخروج';

  @override
  String get exportExcel => 'تصدير Excel';

  @override
  String get exportPdf => 'تصدير PDF';

  @override
  String get leave => 'الإجازات';

  @override
  String get leaveRequests => 'طلبات الإجازات';

  @override
  String get approve => 'موافقة';

  @override
  String get reject => 'رفض';

  @override
  String get leaveBalance => 'رصيد الإجازات';

  @override
  String get requestLeave => 'طلب إجازة';

  @override
  String get payroll => 'الرواتب';

  @override
  String get monthlyPayroll => 'الرواتب الشهرية';

  @override
  String get salaryBreakdown => 'تفصيل الراتب';

  @override
  String get generatePayslip => 'إنشاء قسيمة راتب';

  @override
  String get payslip => 'قسيمة الراتب';

  @override
  String get payslipEmployeeSection => 'الموظف';

  @override
  String get payslipEarningsSection => 'المستحقات';

  @override
  String get payslipDeductionsSection => 'الخصومات';

  @override
  String get recruitment => 'التوظيف';

  @override
  String get jobListings => 'الوظائف المتاحة';

  @override
  String get candidates => 'المتقدمين';

  @override
  String get convertToEmployee => 'تحويل لموظف';

  @override
  String get recruitmentStageNew => 'جديد';

  @override
  String get recruitmentStageInterview => 'مقابلة';

  @override
  String get recruitmentStageOffer => 'عرض عمل';

  @override
  String get recruitmentStageHired => 'تم التعيين';

  @override
  String get recruitmentJobTitleFlutterDeveloper => 'مطور Flutter';

  @override
  String get recruitmentJobTitleAccountant => 'محاسب';

  @override
  String get recruitmentDepartmentTechnical => 'التقنية';

  @override
  String get recruitmentDepartmentFinance => 'المالية';

  @override
  String get recruitmentJobStatusOpen => 'مفتوح';

  @override
  String get recruitmentApplicantFileExample => 'ملف المتقدم - مثال';

  @override
  String get recruitmentApplicantNameSample => 'أحمد المتقدم';

  @override
  String get recruitmentApplicantRoleSample => 'مطور Flutter';

  @override
  String get recruitmentApplicantEmailSample => 'ahmed@email.com';

  @override
  String recruitmentApplicantsCount(int count) {
    return '$count متقدم';
  }

  @override
  String recruitmentApplicantIndexed(int index) {
    return 'متقدم $index';
  }

  @override
  String get recruitmentJobDetailsTitle => 'تفاصيل الوظيفة';

  @override
  String get recruitmentLocationLabel => 'الموقع';

  @override
  String get recruitmentLocationValue => 'الرياض';

  @override
  String get recruitmentApplicantsLabel => 'المتقدمين';

  @override
  String get recruitmentDescriptionLabel => 'الوصف';

  @override
  String get recruitmentJobDescriptionSample =>
      'نبحث عن مطور Flutter متحمس للانضمام لفريقنا. يشترط الخبرة في تطوير تطبيقات متعددة المنصات والتمكن من Dart و Flutter.';

  @override
  String get settings => 'الإعدادات';

  @override
  String get companyInfo => 'معلومات الشركة';

  @override
  String get rolesPermissions => 'الأدوار والصلاحيات';

  @override
  String get subscriptionBilling => 'الاشتراك والفوترة';

  @override
  String get save => 'حفظ';

  @override
  String get cancel => 'إلغاء';

  @override
  String get search => 'بحث';

  @override
  String get filter => 'تصفية';

  @override
  String get export => 'تصدير';

  @override
  String get date => 'التاريخ';

  @override
  String get name => 'الاسم';

  @override
  String get department => 'القسم';

  @override
  String get position => 'المنصب';

  @override
  String get actions => 'إجراءات';

  @override
  String get view => 'عرض';

  @override
  String get edit => 'تعديل';

  @override
  String get delete => 'حذف';

  @override
  String get appearance => 'المظهر';

  @override
  String get darkMode => 'الوضع الليلي';

  @override
  String get darkModeOn => 'مفعّل';

  @override
  String get darkModeOff => 'معطّل';

  @override
  String get lightMode => 'الوضع النهاري';

  @override
  String get language => 'اللغة';

  @override
  String get languageTitle => 'لغة التطبيق';

  @override
  String get arabic => 'العربية';

  @override
  String get english => 'الإنجليزية';

  @override
  String get serverBindingTitle => 'ربط الخادم (Laravel API)';

  @override
  String get serverBindingDescription =>
      'لتفعيل الربط مع خادم Laravel أدخل عنوان الـ API (مثال: https://your-domain.com/api) وفعّل \"استخدام الخادم\"';

  @override
  String get baseUrlLabel => 'عنوان الخادم (Base URL)';

  @override
  String get baseUrlHint => 'https://your-laravel.com/api';

  @override
  String get useServer => 'استخدام الخادم';

  @override
  String get serverEnabled => 'تم تفعيل الربط بالخادم';

  @override
  String get serverDisabled => 'الاعتماد على البيانات التجريبية';

  @override
  String get serverSettingsSaved => 'تم حفظ إعدادات الخادم';

  @override
  String get companySavedLocal => 'تم حفظ معلومات الشركة (محلياً للتجربة)';

  @override
  String get planUpgradeLater =>
      'ترقية الخطة ستكون متاحة عبر بوابة الدفع لاحقاً.';

  @override
  String get employeeNavHome => 'الرئيسية';

  @override
  String get employeeNavAttendance => 'الحضور';

  @override
  String get employeeNavLeave => 'الإجازات';

  @override
  String get employeeNavPayroll => 'الرواتب';

  @override
  String get employeeNavNotifications => 'إشعارات';

  @override
  String get employeeNavProfile => 'الملف';

  @override
  String get myNotifications => 'إشعاراتي';

  @override
  String get retryAction => 'إعادة المحاولة';

  @override
  String get dashboardPartialLoadError =>
      'تعذّر تحميل بعض بيانات لوحة التحكم. تحقق من إعدادات الـ API ثم أعد المحاولة.';

  @override
  String get payslipNotFound => 'لا توجد قسيمة راتب لهذا الشهر.';

  @override
  String get noNotifications => 'لا توجد إشعارات';

  @override
  String get refreshTooltip => 'تحديث';

  @override
  String get payslipDownloadLater =>
      'تنزيل قسيمة PDF يُربَط بالخادم — التجربة: تم التخطيط';

  @override
  String get rolePermissionsServer =>
      'تعديل الصلاحيات يُحفظ عبر الخادم في الإصدار الكامل';

  @override
  String jobEditServer(String jobId) {
    return 'تعديل الوظيفة $jobId — يُحفظ عبر الخادم عند التفعيل';
  }

  @override
  String get convertEmployeeHint => 'سيتم إضافة المرشح كموظف — أكمل النموذج.';

  @override
  String get sessionExpired => 'انتهت الجلسة. يرجى تسجيل الدخول مجدداً.';

  @override
  String get apiHttpsRequired =>
      'استخدم https:// لعنوان الـ API في الإنتاج (يُسمح بـ localhost).';

  @override
  String get invalidApiUrl =>
      'أدخل عنوان API صالحاً (مثال: https://example.com/api).';

  @override
  String get apiUrlRequired => 'أدخل عنوان الخادم قبل تفعيل وضع الـ API.';

  @override
  String get notificationsTitle => 'الإشعارات';

  @override
  String get employeeNotificationsTitle => 'إشعاراتي';

  @override
  String get phone => 'رقم الهاتف';

  @override
  String get address => 'العنوان';

  @override
  String get wifiAttendanceTitle => 'الحضور عبر الواي فاي';

  @override
  String get wifiAttendanceBody =>
      'يتم تسجيل الحضور فقط عند اتصال الموظف بشبكة الواي فاي الخاصة بالشركة';

  @override
  String get wifiSsidLabel => 'اسم شبكة الواي فاي (SSID)';

  @override
  String get wifiSsidHint => 'مثال: Company_Office';

  @override
  String get wifiSettingsSaved => 'تم حفظ إعدادات شبكة الحضور';

  @override
  String get dataFromServer => 'البيانات من Laravel';

  @override
  String get dataLocalDemo => 'البيانات التجريبية محلياً';

  @override
  String get subscriptionPlanName => 'الخطة الاحترافية';

  @override
  String get subscriptionPlanPrice => '50 موظف • 1,200 ريال/شهر';

  @override
  String get upgradePlan => 'ترقية الخطة';

  @override
  String get paymentPortalLater =>
      'صفحة الدفع والترقية تُربَط ببوابة الاشتراك عند الإطلاق';

  @override
  String get roleAdminTitle => 'مدير النظام';

  @override
  String get roleAdminSubtitle => 'صلاحيات كاملة';

  @override
  String get roleHrTitle => 'مدير الموارد البشرية';

  @override
  String get roleHrSubtitle => 'إدارة الموظفين والحضور';

  @override
  String get roleEmployeeTitle => 'موظف';

  @override
  String get roleEmployeeSubtitle => 'عرض بياناته فقط';

  @override
  String get featureEmployees => 'الموظفين';

  @override
  String get featureAttendance => 'الحضور';

  @override
  String get featureLeave => 'الإجازات';

  @override
  String get featurePayroll => 'الرواتب';

  @override
  String get featureRecruitment => 'التوظيف';

  @override
  String get dashboardOverview => 'نظرة عامة على نشاط الشركة اليوم';

  @override
  String get ofSeats => 'من أصل 50 مقعد';

  @override
  String get needsReview => 'تحتاج مراجعة';

  @override
  String get payrollDone => 'تم';

  @override
  String get payrollMonthSample => 'شهر فبراير 2025';

  @override
  String get viewAll => 'عرض الكل';

  @override
  String get leaveType => 'نوع الإجازة';

  @override
  String get leaveApproved => 'تمت الموافقة';

  @override
  String get leaveRejected => 'تم الرفض';

  @override
  String get adminProfileMenu => 'الملف الشخصي';

  @override
  String get logout => 'تسجيل الخروج';

  @override
  String get sampleAdminName => 'أحمد المدير';

  @override
  String get sampleAdminRole => 'مدير موارد بشرية';

  @override
  String get refreshAction => 'تحديث';

  @override
  String get attendanceEditGrid =>
      'تعديل حضور الجدول — يُحفظ عبر الخادم عند التفعيل';

  @override
  String attendanceEditEmployee(String name) {
    return 'تعديل حضور $name — يُحفظ عبر الخادم عند التفعيل';
  }

  @override
  String exportPrepared(String format) {
    return 'تم تجهيز $format للتجربة. التصدير الفعلي يُربَط بـ Laravel.';
  }

  @override
  String get formatExcel => 'ملف Excel';

  @override
  String get formatPdf => 'ملف PDF';

  @override
  String get payrollGenerateDemo =>
      'تم جدولة إنشاء قسائم للتجربة. التنفيذ الفعلي من الخادم.';

  @override
  String get colEmployee => 'الموظف';

  @override
  String get colBaseSalary => 'الراتب الأساسي';

  @override
  String get colAllowances => 'البدلات';

  @override
  String get colDeductions => 'الخصومات';

  @override
  String get colNetSalary => 'صافي الراتب';

  @override
  String get colStatus => 'الحالة';

  @override
  String get colCheckIn => 'وقت الدخول';

  @override
  String get colCheckOut => 'وقت الخروج';

  @override
  String get colWorkHours => 'ساعات العمل';

  @override
  String get breakdownBase => 'الراتب الأساسي';

  @override
  String get breakdownAllowances => 'البدلات';

  @override
  String get breakdownDeductions => 'الخصومات';

  @override
  String get breakdownNet => 'صافي الراتب';

  @override
  String get filterAllDepartments => 'كل الأقسام';

  @override
  String filterDepartmentButton(String name) {
    return 'القسم: $name';
  }

  @override
  String get monthFebruary2025 => 'فبراير 2025';

  @override
  String get monthJanuary2025 => 'يناير 2025';

  @override
  String get formSavedSuccess => 'تم حفظ البيانات بنجاح';

  @override
  String get fieldRequired => 'مطلوب';

  @override
  String get fullName => 'الاسم الكامل';

  @override
  String get birthDate => 'تاريخ الميلاد';

  @override
  String get hireDate => 'تاريخ التعيين';

  @override
  String get bankAccount => 'رقم الحساب البنكي';

  @override
  String get insuranceType => 'نوع التأمين';

  @override
  String get insuranceHealthOpt => 'تأمين صحي';

  @override
  String get insuranceSocialOpt => 'تأمين اجتماعي';

  @override
  String get insuranceOtherOpt => 'أخرى';

  @override
  String get policyNumber => 'رقم البوليصة / رقم التأمين';

  @override
  String get insuranceCompany => 'شركة التأمين';

  @override
  String get coverageStart => 'تاريخ بداية التغطية';

  @override
  String get coverageEnd => 'تاريخ نهاية التغطية';

  @override
  String get payslipMonthField => 'الشهر';

  @override
  String get download => 'تنزيل';

  @override
  String get addJob => 'إضافة وظيفة';

  @override
  String get recruitmentPaidBanner => 'ميزة مدفوعة - تفعيل من الإعدادات';

  @override
  String get loginBrandingTitle => 'نظام إدارة الموارد البشرية';

  @override
  String get loginBrandingSubtitle =>
      'إدارة الموظفين، الحضور، الإجازات والرواتب في مكان واحد';

  @override
  String get loginFormSubtitle => 'أدخل بياناتك للوصول إلى لوحة التحكم';

  @override
  String get enterEmail => 'أدخل البريد الإلكتروني';

  @override
  String get enterPassword => 'أدخل كلمة المرور';

  @override
  String get forgotPasswordTitle => 'استعادة كلمة المرور';

  @override
  String get forgotPasswordBody =>
      'أدخل بريدك الإلكتروني وسنرسل لك رابطاً لإعادة تعيين كلمة المرور';

  @override
  String get sendResetLink => 'إرسال الرابط';

  @override
  String get backToLogin => 'العودة لتسجيل الدخول';

  @override
  String get resetLinkSent => 'تم إرسال الرابط';

  @override
  String get resetLinkSentBody =>
      'تحقق من بريدك الإلكتروني واضغط على الرابط لإعادة تعيين كلمة المرور';

  @override
  String get addCompanyTitle => 'إضافة شركة';

  @override
  String get demoCompanyLabel => 'الشركة';

  @override
  String get companyAddedSuccess => 'تم إضافة الشركة بنجاح';

  @override
  String get jobTitleField => 'المسمى الوظيفي';

  @override
  String get jobLocationField => 'الموقع';

  @override
  String get jobDescriptionField => 'الوصف';

  @override
  String get jobAddedSuccess => 'تم إضافة الوظيفة بنجاح';

  @override
  String get payslipDownloading => 'جاري تحميل قسيمة الراتب...';

  @override
  String get registerSubtitle => 'إنشاء حساب شركة جديد - نظام متعدد المستأجرين';

  @override
  String get enterCompanyName => 'أدخل اسم الشركة';

  @override
  String get haveAccountLogin => 'لديك حساب؟ تسجيل الدخول';

  @override
  String get leaveAdminSubtitle => 'إدارة طلبات الإجازات والموافقات';

  @override
  String get filterAll => 'الكل';

  @override
  String get filterPendingShort => 'معلقة';

  @override
  String get filterApprovedShort => 'موافق عليها';

  @override
  String get filterRejectedShort => 'مرفوضة';

  @override
  String get leaveColFrom => 'من';

  @override
  String get leaveColTo => 'إلى';

  @override
  String get leaveColDays => 'الأيام';

  @override
  String get leaveColBalanceLeft => 'الرصيد المتبقي';

  @override
  String get leaveBalancePerEmployee => 'رصيد الإجازات حسب الموظف';

  @override
  String get annualShort => 'سنوية';

  @override
  String get sickShort => 'مرضية';

  @override
  String get emergencyShort => 'طارئة';

  @override
  String get wifiChecking => 'جاري التحقق...';

  @override
  String get wifiOnCompany => 'متصل بشبكة الشركة';

  @override
  String get wifiOffCompany => 'غير متصل - تسجيل الحضور عبر الواي فاي فقط';

  @override
  String networkLabel(String name) {
    return 'الشبكة: $name';
  }

  @override
  String get recheckWifi => 'إعادة التحقق';

  @override
  String get attendanceTodayTitle => 'حالة الحضور اليوم';

  @override
  String get checkInTimeSample => '08:00';

  @override
  String get checkInRecorded => 'تم تسجيل الدخول';

  @override
  String get greetingHello => 'مرحباً';

  @override
  String greetingWithName(String name) {
    return 'مرحباً، $name';
  }

  @override
  String get homeDateSample => 'السبت 7 فبراير 2025';

  @override
  String get wifiCheckingHome => 'جاري التحقق من شبكة الواي فاي...';

  @override
  String get wifiNotOnCompanyHome => 'غير متصل بشبكة الشركة';

  @override
  String get attendanceOnlyWifiHint =>
      'تسجيل الحضور يتم عبر شبكة الواي فاي الخاصة بالشركة فقط';

  @override
  String get quickActionsTitle => 'إجراءات سريعة';

  @override
  String get attendanceLogLabel => 'سجل الحضور';

  @override
  String get profileQuickLabel => 'الملف الشخصي';

  @override
  String get notificationsTooltip => 'الإشعارات';

  @override
  String get employeeAppSubtitle => 'تطبيق الموظفين';

  @override
  String get leaveNotes => 'السبب / ملاحظات';

  @override
  String get documentsSection => 'المستندات';

  @override
  String get employmentContract => 'عقد العمل';

  @override
  String get payslipJanuaryDoc => 'قسيمة الراتب - يناير';

  @override
  String get companyLabelRow => 'الشركة';

  @override
  String get roleLabelRow => 'الدور';

  @override
  String get baseSalaryLabel => 'الراتب الأساسي';

  @override
  String get roleDetailTitle => 'تفاصيل الدور';

  @override
  String get permissionsTitle => 'الصلاحيات';

  @override
  String get editPermissionsButton => 'تعديل الصلاحيات';

  @override
  String get aiAssistantWelcome =>
      'مرحباً! أنا المساعد الذكي. اسألني عن الموظفين، الحضور، الإجازات أو الرواتب.';

  @override
  String get apiBaseUrlMissing => 'لم يُعرَّف عنوان الخادم.';

  @override
  String get apiErrorServer => 'خطأ في الخادم';

  @override
  String apiErrorConnection(String details) {
    return 'خطأ في الاتصال: $details';
  }

  @override
  String get apiInvalidResponse => 'استجابة غير صالحة من الخادم';

  @override
  String get apiNoTokenReceived => 'لم يتم استلام رمز المصادقة';

  @override
  String apiReadResponseFailed(String details) {
    return 'تعذّر قراءة الاستجابة: $details';
  }

  @override
  String apiErrorEmployeesList(String details) {
    return 'تعذّر تحميل الموظفين: $details';
  }

  @override
  String apiErrorEmployeeDetail(String details) {
    return 'تعذّر تحميل بيانات الموظف: $details';
  }

  @override
  String apiErrorAttendance(String details) {
    return 'تعذّر تحميل الحضور: $details';
  }

  @override
  String apiErrorLeaveRequests(String details) {
    return 'تعذّر تحميل طلبات الإجازات: $details';
  }

  @override
  String apiErrorLeaveBalances(String details) {
    return 'تعذّر تحميل أرصدة الإجازات: $details';
  }

  @override
  String apiErrorPayroll(String details) {
    return 'تعذّر تحميل الرواتب: $details';
  }

  @override
  String apiErrorNotifications(String details) {
    return 'تعذّر تحميل الإشعارات: $details';
  }

  @override
  String get demoUserName => 'مستخدم تجريبي';

  @override
  String get leaveApproveSuccess => 'تمت الموافقة على طلب الإجازة';

  @override
  String get leaveRejectSuccess => 'تم رفض طلب الإجازة';

  @override
  String get registerSuccessServer =>
      'تم إنشاء الحساب. يمكنك تسجيل الدخول الآن.';

  @override
  String get aiPanelTitle => 'المساعد الذكي';

  @override
  String get aiTyping => 'جاري الكتابة…';

  @override
  String get aiInputHint => 'اسأل عن الموظفين، الحضور، الإجازات…';

  @override
  String get planStarter => 'بداية';

  @override
  String get planStarterDesc => 'حتى 25 موظفاً • نواة Nawa Tech HRM';

  @override
  String get planGrowth => 'نمو';

  @override
  String get planGrowthDesc => 'حتى 50 موظفاً • يشمل التوظيف';

  @override
  String get planEnterprise => 'مؤسسات';

  @override
  String get planEnterpriseDesc => 'حتى 200 موظف • جاهز لطبقة ذكاء عبر API';

  @override
  String get saasPlanSection => 'الخطة (تجريبي)';

  @override
  String get saasRecruitmentLocked => 'رقّ الخطة من الإعدادات لفتح التوظيف.';

  @override
  String get employeeLimitReached =>
      'بلغت حد الموظفين للخطة. رقِّ من الإعدادات.';

  @override
  String get loginUseWebForAdmin =>
      'هذا الحساب للإدارة. سجّل الدخول من لوحة الويب.';

  @override
  String get loginUseMobileForEmployee =>
      'هذا حساب موظف. استخدم تطبيق الجوال لتسجيل الدخول.';

  @override
  String get employeeLoginCredentialsHint =>
      'استخدم البريد وكلمة المرور التي أنشأها المسؤول لدخول التطبيق.';

  @override
  String get employeeAppLoginTab => 'دخول تطبيق الجوال';

  @override
  String get enableEmployeeAppLogin => 'تفعيل دخول تطبيق الجوال';

  @override
  String get employeeAppLoginSectionHint =>
      'إنشاء أو تحديث كلمة مرور التطبيق للموظف. الدخول من الهاتف فقط.';

  @override
  String get employeeAppPassword => 'كلمة مرور التطبيق';

  @override
  String get employeeAppPasswordConfirm => 'تأكيد كلمة مرور التطبيق';

  @override
  String get appAccessPasswordMismatch =>
      'كلمتا مرور التطبيق غير متطابقتين أو أقل من 8 أحرف.';

  @override
  String get appAccessSaved => 'تم تحديث صلاحية دخول التطبيق.';

  @override
  String get clearAction => 'مسح';

  @override
  String get cannotDeleteOwnAccount => 'لا يمكن حذف حسابك';

  @override
  String get leaveStatusPending => 'معلقة';

  @override
  String get leaveStatusApproved => 'موافقة عليها';

  @override
  String get leaveStatusRejected => 'مرفوضة';

  @override
  String get markAllRead => 'تعليم الكل كمقروء';

  @override
  String get noJobsYet => 'لا توجد وظائف بعد. أضف أول وظيفة.';

  @override
  String get addCandidate => 'إضافة مرشح';

  @override
  String get candidateName => 'اسم المرشح';

  @override
  String get candidateEmail => 'بريد المرشح الإلكتروني';

  @override
  String get candidatePhone => 'هاتف المرشح';

  @override
  String get candidateNotes => 'ملاحظات';

  @override
  String get candidateAdded => 'تمت إضافة المرشح';

  @override
  String get candidateStageUpdated => 'تم تحديث المرحلة';

  @override
  String get jobDeleted => 'تم حذف الوظيفة';

  @override
  String get jobUpdated => 'تم تحديث الوظيفة';

  @override
  String get jobCreated => 'تم إنشاء الوظيفة بنجاح';

  @override
  String get jobStatusOpen => 'مفتوحة';

  @override
  String get jobStatusClosed => 'مغلقة';

  @override
  String get jobStatusDraft => 'مسودة';

  @override
  String get candidateStageName => 'المرحلة';

  @override
  String get candidateStageRejected => 'مرفوض';

  @override
  String get editJob => 'تعديل الوظيفة';

  @override
  String get performance => 'الأداء';

  @override
  String get reports => 'التقارير';

  @override
  String get performanceTitle => 'تحليل أداء الموظفين';

  @override
  String get performanceNewReview => 'إدخال تقييم جديد';

  @override
  String get periodLabel => 'الفترة';

  @override
  String get ratingLabel => 'التقييم';

  @override
  String get goalsSummary => 'ملخص الأهداف';

  @override
  String get strengths => 'نقاط القوة';

  @override
  String get improvementAreas => 'مجالات التحسين';

  @override
  String get managerComment => 'تعليق المدير';

  @override
  String get saveReview => 'حفظ التقييم';

  @override
  String get reviewSaved => 'تم حفظ التقييم';

  @override
  String get aiSummaryCol => 'ملخص ذكي';

  @override
  String get noAnalysisYet => 'لا يوجد تحليل بعد';

  @override
  String get analyzing => 'جاري...';

  @override
  String get queueAiAnalysis => 'جدولة تحليل AI';

  @override
  String get analyzeAi => 'تحليل AI';

  @override
  String get analysisQueued => 'تمت جدولة التحليل وسيتم التحديث تلقائياً';

  @override
  String get aiAnalysisGenerated => 'تم توليد التحليل الذكي';

  @override
  String get aiAnalysisCompleted => 'اكتمل التحليل الذكي';

  @override
  String get asyncMode => 'وضع Async';

  @override
  String get processing => 'قيد المعالجة...';

  @override
  String get taskFailed => 'فشلت المهمة';

  @override
  String get reportsTitle => 'تقارير ذكية وملخصات الإدارة';

  @override
  String get fromDate => 'من';

  @override
  String get toDate => 'إلى';

  @override
  String get generateSummary => 'توليد الملخص';

  @override
  String get reportQueued => 'تمت جدولة التقرير وسيظهر فور اكتماله';

  @override
  String get executiveNarrative => 'السرد التنفيذي';

  @override
  String get loadDataFailed =>
      'تعذّر تحميل البيانات. تحقق من إعدادات الـ API ثم أعد المحاولة.';

  @override
  String get welcomeHowItWorks => 'كيف يعمل';

  @override
  String get welcomeStep1Title => 'شغّل الـ API ولوحة الإدارة';

  @override
  String get welcomeStep1Desc =>
      'شغّل Laravel، زرّع البيانات التجريبية، وسجّل دخول لوحة الأدمن على الويب.';

  @override
  String get welcomeStep2Title => 'افتح تطبيق الموظف';

  @override
  String get welcomeStep2Desc =>
      'استخدم تطبيق الموبايل بحسابات العرض التجريبي للحضور والإجازات وقسيمة الراتب.';

  @override
  String get welcomeStep3Title => 'استكشف AI والتوظيف';

  @override
  String get welcomeStep3Desc =>
      'جرّب مركز AI، مطابقة التوظيف، تقييمات الأداء، والتقارير الذكية.';

  @override
  String get generateWithAi => 'توليد بالذكاء الاصطناعي';

  @override
  String get aiBriefingTitle => 'ملخص HR بالذكاء الاصطناعي';

  @override
  String get aiBriefingSubtitle => 'ملخص ذكي لآخر 30 يوماً';

  @override
  String get generateBriefing => 'توليد الملخص';

  @override
  String get openAiAssistant => 'المساعد الذكي';

  @override
  String get tryAiAssistant => 'جرّب المساعد الذكي';

  @override
  String get aiJobGenerated => 'تم توليد وصف الوظيفة';

  @override
  String get askAiAboutHr => 'اسأل عن الإجازات، الراتب، الحضور…';
}
