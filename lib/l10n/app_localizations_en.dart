// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appName => 'Nawa Tech HRM';

  @override
  String get appTagline => 'Where management feels effortless';

  @override
  String get login => 'Sign in';

  @override
  String get registerCompany => 'Register company';

  @override
  String get email => 'Email';

  @override
  String get password => 'Password';

  @override
  String get companyName => 'Company name';

  @override
  String get forgotPassword => 'Forgot password?';

  @override
  String get dashboard => 'Dashboard';

  @override
  String get employeesCount => 'Employees';

  @override
  String get todayAttendance => 'Today\'s attendance';

  @override
  String get present => 'Present';

  @override
  String get absent => 'Absent';

  @override
  String get late => 'Late';

  @override
  String get pendingLeaves => 'Pending leave requests';

  @override
  String get payrollStatus => 'Payroll status';

  @override
  String get processed => 'Processed';

  @override
  String get pending => 'Pending';

  @override
  String get employees => 'Employees';

  @override
  String get addEmployee => 'Add employee';

  @override
  String get editEmployee => 'Edit employee';

  @override
  String get employeeProfile => 'Employee profile';

  @override
  String get personalInfo => 'Personal information';

  @override
  String get jobInfo => 'Job information';

  @override
  String get salaryInfo => 'Salary';

  @override
  String get insuranceInfo => 'Insurance';

  @override
  String get status => 'Status';

  @override
  String get active => 'Active';

  @override
  String get inactive => 'Inactive';

  @override
  String get attendance => 'Attendance';

  @override
  String get dailyAttendance => 'Daily attendance';

  @override
  String get editAttendance => 'Edit attendance';

  @override
  String get checkIn => 'Check in';

  @override
  String get checkOut => 'Check out';

  @override
  String get exportExcel => 'Export Excel';

  @override
  String get exportPdf => 'Export PDF';

  @override
  String get leave => 'Leave';

  @override
  String get leaveRequests => 'Leave requests';

  @override
  String get approve => 'Approve';

  @override
  String get reject => 'Reject';

  @override
  String get leaveBalance => 'Leave balance';

  @override
  String get requestLeave => 'Request leave';

  @override
  String get payroll => 'Payroll';

  @override
  String get monthlyPayroll => 'Monthly payroll';

  @override
  String get salaryBreakdown => 'Salary breakdown';

  @override
  String get generatePayslip => 'Generate payslip';

  @override
  String get payslip => 'Payslip';

  @override
  String get payslipEmployeeSection => 'Employee';

  @override
  String get payslipEarningsSection => 'Earnings';

  @override
  String get payslipDeductionsSection => 'Deductions';

  @override
  String get recruitment => 'Recruitment';

  @override
  String get jobListings => 'Job listings';

  @override
  String get candidates => 'Candidates';

  @override
  String get convertToEmployee => 'Convert to employee';

  @override
  String get recruitmentStageNew => 'New';

  @override
  String get recruitmentStageInterview => 'Interview';

  @override
  String get recruitmentStageOffer => 'Job offer';

  @override
  String get recruitmentStageHired => 'Hired';

  @override
  String get recruitmentJobTitleFlutterDeveloper => 'Flutter Developer';

  @override
  String get recruitmentJobTitleAccountant => 'Accountant';

  @override
  String get recruitmentDepartmentTechnical => 'Technology';

  @override
  String get recruitmentDepartmentFinance => 'Finance';

  @override
  String get recruitmentJobStatusOpen => 'Open';

  @override
  String get recruitmentApplicantFileExample => 'Applicant file — example';

  @override
  String get recruitmentApplicantNameSample => 'Ahmed Applicant';

  @override
  String get recruitmentApplicantRoleSample => 'Flutter Developer';

  @override
  String get recruitmentApplicantEmailSample => 'ahmed@email.com';

  @override
  String recruitmentApplicantsCount(int count) {
    return '$count applicants';
  }

  @override
  String recruitmentApplicantIndexed(int index) {
    return 'Applicant $index';
  }

  @override
  String get recruitmentJobDetailsTitle => 'Job details';

  @override
  String get recruitmentLocationLabel => 'Location';

  @override
  String get recruitmentLocationValue => 'Riyadh';

  @override
  String get recruitmentApplicantsLabel => 'Applicants';

  @override
  String get recruitmentDescriptionLabel => 'Description';

  @override
  String get recruitmentJobDescriptionSample =>
      'We are looking for a passionate Flutter developer to join our team. Experience building multi-platform applications is required, along with strong Dart and Flutter skills.';

  @override
  String get settings => 'Settings';

  @override
  String get companyInfo => 'Company information';

  @override
  String get rolesPermissions => 'Roles & permissions';

  @override
  String get subscriptionBilling => 'Subscription & billing';

  @override
  String get save => 'Save';

  @override
  String get cancel => 'Cancel';

  @override
  String get search => 'Search';

  @override
  String get filter => 'Filter';

  @override
  String get export => 'Export';

  @override
  String get date => 'Date';

  @override
  String get name => 'Name';

  @override
  String get department => 'Department';

  @override
  String get position => 'Position';

  @override
  String get actions => 'Actions';

  @override
  String get view => 'View';

  @override
  String get edit => 'Edit';

  @override
  String get delete => 'Delete';

  @override
  String get appearance => 'Appearance';

  @override
  String get darkMode => 'Dark mode';

  @override
  String get darkModeOn => 'On';

  @override
  String get darkModeOff => 'Off';

  @override
  String get lightMode => 'Light mode';

  @override
  String get language => 'Language';

  @override
  String get languageTitle => 'App language';

  @override
  String get arabic => 'Arabic';

  @override
  String get english => 'English';

  @override
  String get serverBindingTitle => 'Server (Laravel API)';

  @override
  String get serverBindingDescription =>
      'Enter your API base URL (e.g. https://your-domain.com/api) and enable \"Use server\" to connect.';

  @override
  String get baseUrlLabel => 'Base URL';

  @override
  String get baseUrlHint => 'https://your-laravel.com/api';

  @override
  String get useServer => 'Use server';

  @override
  String get serverEnabled => 'Server connection enabled';

  @override
  String get serverDisabled => 'Using demo data';

  @override
  String get serverSettingsSaved => 'Server settings saved';

  @override
  String get companySavedLocal => 'Company info saved locally (demo)';

  @override
  String get planUpgradeLater =>
      'Plan upgrades will be available via the billing portal.';

  @override
  String get employeeNavHome => 'Home';

  @override
  String get employeeNavAttendance => 'Attendance';

  @override
  String get employeeNavLeave => 'Leave';

  @override
  String get employeeNavPayroll => 'Payroll';

  @override
  String get employeeNavProfile => 'Profile';

  @override
  String get myNotifications => 'My notifications';

  @override
  String get retryAction => 'Retry';

  @override
  String get noNotifications => 'No notifications';

  @override
  String get refreshTooltip => 'Refresh';

  @override
  String get payslipDownloadLater =>
      'PDF download will use the server in production (demo: planned).';

  @override
  String get rolePermissionsServer =>
      'Permission changes are saved on the server in the full release.';

  @override
  String jobEditServer(String jobId) {
    return 'Editing job $jobId — saved on the server when enabled.';
  }

  @override
  String get convertEmployeeHint =>
      'Candidate will be added as an employee (complete the form).';

  @override
  String get sessionExpired => 'Session expired. Please sign in again.';

  @override
  String get apiHttpsRequired =>
      'Use https:// for the API URL in production (localhost is allowed).';

  @override
  String get invalidApiUrl =>
      'Enter a valid API URL (e.g. https://example.com/api).';

  @override
  String get apiUrlRequired => 'Enter the server URL before enabling API mode.';

  @override
  String get notificationsTitle => 'Notifications';

  @override
  String get employeeNotificationsTitle => 'My notifications';

  @override
  String get phone => 'Phone';

  @override
  String get address => 'Address';

  @override
  String get wifiAttendanceTitle => 'Wi‑Fi attendance';

  @override
  String get wifiAttendanceBody =>
      'Check-in is allowed only when the device is on the company Wi‑Fi.';

  @override
  String get wifiSsidLabel => 'Wi‑Fi network name (SSID)';

  @override
  String get wifiSsidHint => 'e.g. Company_Office';

  @override
  String get wifiSettingsSaved => 'Wi‑Fi attendance settings saved';

  @override
  String get dataFromServer => 'Data from Laravel';

  @override
  String get dataLocalDemo => 'Local demo data';

  @override
  String get subscriptionPlanName => 'Professional plan';

  @override
  String get subscriptionPlanPrice => '50 employees • 1,200 SAR/month';

  @override
  String get upgradePlan => 'Upgrade plan';

  @override
  String get paymentPortalLater =>
      'Payment and upgrades will connect to the billing portal at launch.';

  @override
  String get roleAdminTitle => 'System administrator';

  @override
  String get roleAdminSubtitle => 'Full access';

  @override
  String get roleHrTitle => 'HR manager';

  @override
  String get roleHrSubtitle => 'Employees and attendance';

  @override
  String get roleEmployeeTitle => 'Employee';

  @override
  String get roleEmployeeSubtitle => 'Own data only';

  @override
  String get featureEmployees => 'Employees';

  @override
  String get featureAttendance => 'Attendance';

  @override
  String get featureLeave => 'Leave';

  @override
  String get featurePayroll => 'Payroll';

  @override
  String get featureRecruitment => 'Recruitment';

  @override
  String get dashboardOverview => 'Company activity at a glance';

  @override
  String get ofSeats => 'of 50 seats';

  @override
  String get needsReview => 'Awaiting review';

  @override
  String get payrollDone => 'Done';

  @override
  String get payrollMonthSample => 'February 2025';

  @override
  String get viewAll => 'View all';

  @override
  String get leaveType => 'Leave type';

  @override
  String get leaveApproved => 'Approved';

  @override
  String get leaveRejected => 'Rejected';

  @override
  String get adminProfileMenu => 'Profile';

  @override
  String get logout => 'Sign out';

  @override
  String get sampleAdminName => 'Ahmed (Manager)';

  @override
  String get sampleAdminRole => 'HR Manager';

  @override
  String get refreshAction => 'Refresh';

  @override
  String get attendanceEditGrid =>
      'Edit attendance for the table — saved on the server when enabled.';

  @override
  String attendanceEditEmployee(String name) {
    return 'Edit attendance for $name — saved on the server when enabled.';
  }

  @override
  String exportPrepared(String format) {
    return '$format prepared for demo. Real export connects to Laravel.';
  }

  @override
  String get formatExcel => 'Excel file';

  @override
  String get formatPdf => 'PDF file';

  @override
  String get payrollGenerateDemo =>
      'Payslip generation scheduled for demo. Execution runs on the server.';

  @override
  String get colEmployee => 'Employee';

  @override
  String get colBaseSalary => 'Base salary';

  @override
  String get colAllowances => 'Allowances';

  @override
  String get colDeductions => 'Deductions';

  @override
  String get colNetSalary => 'Net salary';

  @override
  String get colStatus => 'Status';

  @override
  String get colCheckIn => 'Check-in time';

  @override
  String get colCheckOut => 'Check-out time';

  @override
  String get colWorkHours => 'Work hours';

  @override
  String get breakdownBase => 'Base salary';

  @override
  String get breakdownAllowances => 'Allowances';

  @override
  String get breakdownDeductions => 'Deductions';

  @override
  String get breakdownNet => 'Net pay';

  @override
  String get filterAllDepartments => 'All departments';

  @override
  String filterDepartmentButton(String name) {
    return 'Dept: $name';
  }

  @override
  String get monthFebruary2025 => 'February 2025';

  @override
  String get monthJanuary2025 => 'January 2025';

  @override
  String get formSavedSuccess => 'Saved successfully';

  @override
  String get fieldRequired => 'Required';

  @override
  String get fullName => 'Full name';

  @override
  String get birthDate => 'Date of birth';

  @override
  String get hireDate => 'Hire date';

  @override
  String get bankAccount => 'Bank account number';

  @override
  String get insuranceType => 'Insurance type';

  @override
  String get insuranceHealthOpt => 'Health insurance';

  @override
  String get insuranceSocialOpt => 'Social insurance';

  @override
  String get insuranceOtherOpt => 'Other';

  @override
  String get policyNumber => 'Policy / member ID';

  @override
  String get insuranceCompany => 'Insurance provider';

  @override
  String get coverageStart => 'Coverage start';

  @override
  String get coverageEnd => 'Coverage end';

  @override
  String get payslipMonthField => 'Pay period';

  @override
  String get download => 'Download';

  @override
  String get addJob => 'Add job';

  @override
  String get recruitmentPaidBanner => 'Paid feature — enable in settings';

  @override
  String get loginBrandingTitle => 'Human resources management';

  @override
  String get loginBrandingSubtitle =>
      'Employees, attendance, leave and payroll in one place.';

  @override
  String get loginFormSubtitle =>
      'Enter your credentials to access the dashboard.';

  @override
  String get enterEmail => 'Enter your email';

  @override
  String get enterPassword => 'Enter your password';

  @override
  String get forgotPasswordTitle => 'Reset password';

  @override
  String get forgotPasswordBody =>
      'Enter your email and we will send a reset link.';

  @override
  String get sendResetLink => 'Send link';

  @override
  String get backToLogin => 'Back to sign in';

  @override
  String get resetLinkSent => 'Link sent';

  @override
  String get resetLinkSentBody =>
      'Check your email and follow the link to reset your password.';

  @override
  String get addCompanyTitle => 'Add company';

  @override
  String get demoCompanyLabel => 'Company';

  @override
  String get companyAddedSuccess => 'Company added successfully';

  @override
  String get jobTitleField => 'Job title';

  @override
  String get jobLocationField => 'Location';

  @override
  String get jobDescriptionField => 'Description';

  @override
  String get jobAddedSuccess => 'Job added successfully';

  @override
  String get payslipDownloading => 'Downloading payslip…';

  @override
  String get registerSubtitle =>
      'Create a new company account — multi-tenant Nawa Tech HRM';

  @override
  String get enterCompanyName => 'Enter company name';

  @override
  String get haveAccountLogin => 'Already have an account? Sign in';

  @override
  String get leaveAdminSubtitle => 'Manage leave requests and approvals';

  @override
  String get filterAll => 'All';

  @override
  String get filterPendingShort => 'Pending';

  @override
  String get filterApprovedShort => 'Approved';

  @override
  String get filterRejectedShort => 'Rejected';

  @override
  String get leaveColFrom => 'From';

  @override
  String get leaveColTo => 'To';

  @override
  String get leaveColDays => 'Days';

  @override
  String get leaveColBalanceLeft => 'Balance left';

  @override
  String get leaveBalancePerEmployee => 'Leave balance by employee';

  @override
  String get annualShort => 'Annual';

  @override
  String get sickShort => 'Sick';

  @override
  String get emergencyShort => 'Emergency';

  @override
  String get wifiChecking => 'Checking…';

  @override
  String get wifiOnCompany => 'Connected to company network';

  @override
  String get wifiOffCompany =>
      'Not connected — attendance only on company Wi‑Fi';

  @override
  String networkLabel(String name) {
    return 'Network: $name';
  }

  @override
  String get recheckWifi => 'Recheck';

  @override
  String get attendanceTodayTitle => 'Today\'s attendance';

  @override
  String get checkInTimeSample => '08:00';

  @override
  String get checkInRecorded => 'Checked in';

  @override
  String get greetingHello => 'Hello';

  @override
  String greetingWithName(String name) {
    return 'Hello, $name';
  }

  @override
  String get homeDateSample => 'Saturday, 7 February 2025';

  @override
  String get wifiCheckingHome => 'Checking Wi‑Fi…';

  @override
  String get wifiNotOnCompanyHome => 'Not on company network';

  @override
  String get attendanceOnlyWifiHint =>
      'Check-in works only on the company Wi‑Fi.';

  @override
  String get quickActionsTitle => 'Quick actions';

  @override
  String get attendanceLogLabel => 'Attendance log';

  @override
  String get profileQuickLabel => 'Profile';

  @override
  String get notificationsTooltip => 'Notifications';

  @override
  String get employeeAppSubtitle => 'Employee app';

  @override
  String get leaveNotes => 'Reason / notes';

  @override
  String get documentsSection => 'Documents';

  @override
  String get employmentContract => 'Employment contract';

  @override
  String get payslipJanuaryDoc => 'Payslip — January';

  @override
  String get companyLabelRow => 'Company';

  @override
  String get roleLabelRow => 'Role';

  @override
  String get baseSalaryLabel => 'Base salary';

  @override
  String get roleDetailTitle => 'Role details';

  @override
  String get permissionsTitle => 'Permissions';

  @override
  String get editPermissionsButton => 'Edit permissions';

  @override
  String get aiAssistantWelcome =>
      'Hi! I am your assistant. Ask about employees, attendance, leave, or payroll.';

  @override
  String get apiBaseUrlMissing => 'Server URL is not configured.';

  @override
  String get apiErrorServer => 'Server error';

  @override
  String apiErrorConnection(String details) {
    return 'Connection error: $details';
  }

  @override
  String get apiInvalidResponse => 'Invalid response from server';

  @override
  String get apiNoTokenReceived => 'No authentication token received';

  @override
  String apiReadResponseFailed(String details) {
    return 'Could not read server response: $details';
  }

  @override
  String apiErrorEmployeesList(String details) {
    return 'Could not load employees: $details';
  }

  @override
  String apiErrorEmployeeDetail(String details) {
    return 'Could not load employee: $details';
  }

  @override
  String apiErrorAttendance(String details) {
    return 'Could not load attendance: $details';
  }

  @override
  String apiErrorLeaveRequests(String details) {
    return 'Could not load leave requests: $details';
  }

  @override
  String apiErrorLeaveBalances(String details) {
    return 'Could not load leave balances: $details';
  }

  @override
  String apiErrorPayroll(String details) {
    return 'Could not load payroll: $details';
  }

  @override
  String apiErrorNotifications(String details) {
    return 'Could not load notifications: $details';
  }

  @override
  String get demoUserName => 'Demo user';

  @override
  String get leaveApproveSuccess => 'Leave request approved';

  @override
  String get leaveRejectSuccess => 'Leave request rejected';

  @override
  String get registerSuccessServer => 'Account created. You can sign in now.';

  @override
  String get aiPanelTitle => 'AI assistant';

  @override
  String get aiTyping => 'Typing…';

  @override
  String get aiInputHint => 'Ask about employees, attendance, leave…';

  @override
  String get planStarter => 'Starter';

  @override
  String get planStarterDesc => 'Up to 25 employees • core Nawa Tech HRM';

  @override
  String get planGrowth => 'Growth';

  @override
  String get planGrowthDesc => 'Up to 50 employees • includes recruitment';

  @override
  String get planEnterprise => 'Enterprise';

  @override
  String get planEnterpriseDesc =>
      'Up to 200 employees • recruitment + AI tier ready';

  @override
  String get saasPlanSection => 'Plan (demo)';

  @override
  String get saasRecruitmentLocked =>
      'Upgrade plan in Settings to unlock recruitment.';

  @override
  String get employeeLimitReached =>
      'Employee limit for your plan reached. Upgrade in Settings.';

  @override
  String get loginUseWebForAdmin =>
      'This account is for administrators. Sign in from the web admin panel.';

  @override
  String get loginUseMobileForEmployee =>
      'This account is for employees. Use the mobile app to sign in.';

  @override
  String get employeeLoginCredentialsHint =>
      'Use the email and password your administrator created for mobile access.';

  @override
  String get employeeAppLoginTab => 'Mobile app login';

  @override
  String get enableEmployeeAppLogin => 'Enable mobile app login';

  @override
  String get employeeAppLoginSectionHint =>
      'Creates or updates the employee’s app password. Employees sign in on the phone only.';

  @override
  String get employeeAppPassword => 'App password';

  @override
  String get employeeAppPasswordConfirm => 'Confirm app password';

  @override
  String get appAccessPasswordMismatch =>
      'App passwords do not match or are too short (min 8).';

  @override
  String get appAccessSaved => 'Mobile app access updated.';

  @override
  String get clearAction => 'Clear';

  @override
  String get cannotDeleteOwnAccount => 'Cannot delete your own account';

  @override
  String get leaveStatusPending => 'Pending';

  @override
  String get leaveStatusApproved => 'Approved';

  @override
  String get leaveStatusRejected => 'Rejected';

  @override
  String get markAllRead => 'Mark all as read';

  @override
  String get noJobsYet => 'No job postings yet. Add your first job.';

  @override
  String get addCandidate => 'Add candidate';

  @override
  String get candidateName => 'Candidate name';

  @override
  String get candidateEmail => 'Candidate email';

  @override
  String get candidatePhone => 'Candidate phone';

  @override
  String get candidateNotes => 'Notes';

  @override
  String get candidateAdded => 'Candidate added';

  @override
  String get candidateStageUpdated => 'Stage updated';

  @override
  String get jobDeleted => 'Job deleted';

  @override
  String get jobUpdated => 'Job updated';

  @override
  String get jobCreated => 'Job created successfully';

  @override
  String get jobStatusOpen => 'Open';

  @override
  String get jobStatusClosed => 'Closed';

  @override
  String get jobStatusDraft => 'Draft';

  @override
  String get candidateStageName => 'Stage';

  @override
  String get candidateStageRejected => 'Rejected';

  @override
  String get editJob => 'Edit job';
}
