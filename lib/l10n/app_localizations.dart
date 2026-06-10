import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';
import 'app_localizations_en.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('ar'),
    Locale('en'),
  ];

  /// No description provided for @appName.
  ///
  /// In en, this message translates to:
  /// **'Nawa Tech HRM'**
  String get appName;

  /// No description provided for @appTagline.
  ///
  /// In en, this message translates to:
  /// **'Where management feels effortless'**
  String get appTagline;

  /// No description provided for @login.
  ///
  /// In en, this message translates to:
  /// **'Sign in'**
  String get login;

  /// No description provided for @registerCompany.
  ///
  /// In en, this message translates to:
  /// **'Register company'**
  String get registerCompany;

  /// No description provided for @email.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get email;

  /// No description provided for @password.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get password;

  /// No description provided for @companyName.
  ///
  /// In en, this message translates to:
  /// **'Company name'**
  String get companyName;

  /// No description provided for @forgotPassword.
  ///
  /// In en, this message translates to:
  /// **'Forgot password?'**
  String get forgotPassword;

  /// No description provided for @dashboard.
  ///
  /// In en, this message translates to:
  /// **'Dashboard'**
  String get dashboard;

  /// No description provided for @employeesCount.
  ///
  /// In en, this message translates to:
  /// **'Employees'**
  String get employeesCount;

  /// No description provided for @todayAttendance.
  ///
  /// In en, this message translates to:
  /// **'Today\'s attendance'**
  String get todayAttendance;

  /// No description provided for @present.
  ///
  /// In en, this message translates to:
  /// **'Present'**
  String get present;

  /// No description provided for @absent.
  ///
  /// In en, this message translates to:
  /// **'Absent'**
  String get absent;

  /// No description provided for @late.
  ///
  /// In en, this message translates to:
  /// **'Late'**
  String get late;

  /// No description provided for @pendingLeaves.
  ///
  /// In en, this message translates to:
  /// **'Pending leave requests'**
  String get pendingLeaves;

  /// No description provided for @payrollStatus.
  ///
  /// In en, this message translates to:
  /// **'Payroll status'**
  String get payrollStatus;

  /// No description provided for @processed.
  ///
  /// In en, this message translates to:
  /// **'Processed'**
  String get processed;

  /// No description provided for @pending.
  ///
  /// In en, this message translates to:
  /// **'Pending'**
  String get pending;

  /// No description provided for @employees.
  ///
  /// In en, this message translates to:
  /// **'Employees'**
  String get employees;

  /// No description provided for @addEmployee.
  ///
  /// In en, this message translates to:
  /// **'Add employee'**
  String get addEmployee;

  /// No description provided for @editEmployee.
  ///
  /// In en, this message translates to:
  /// **'Edit employee'**
  String get editEmployee;

  /// No description provided for @employeeProfile.
  ///
  /// In en, this message translates to:
  /// **'Employee profile'**
  String get employeeProfile;

  /// No description provided for @personalInfo.
  ///
  /// In en, this message translates to:
  /// **'Personal information'**
  String get personalInfo;

  /// No description provided for @jobInfo.
  ///
  /// In en, this message translates to:
  /// **'Job information'**
  String get jobInfo;

  /// No description provided for @salaryInfo.
  ///
  /// In en, this message translates to:
  /// **'Salary'**
  String get salaryInfo;

  /// No description provided for @insuranceInfo.
  ///
  /// In en, this message translates to:
  /// **'Insurance'**
  String get insuranceInfo;

  /// No description provided for @status.
  ///
  /// In en, this message translates to:
  /// **'Status'**
  String get status;

  /// No description provided for @active.
  ///
  /// In en, this message translates to:
  /// **'Active'**
  String get active;

  /// No description provided for @inactive.
  ///
  /// In en, this message translates to:
  /// **'Inactive'**
  String get inactive;

  /// No description provided for @attendance.
  ///
  /// In en, this message translates to:
  /// **'Attendance'**
  String get attendance;

  /// No description provided for @dailyAttendance.
  ///
  /// In en, this message translates to:
  /// **'Daily attendance'**
  String get dailyAttendance;

  /// No description provided for @editAttendance.
  ///
  /// In en, this message translates to:
  /// **'Edit attendance'**
  String get editAttendance;

  /// No description provided for @checkIn.
  ///
  /// In en, this message translates to:
  /// **'Check in'**
  String get checkIn;

  /// No description provided for @checkOut.
  ///
  /// In en, this message translates to:
  /// **'Check out'**
  String get checkOut;

  /// No description provided for @exportExcel.
  ///
  /// In en, this message translates to:
  /// **'Export Excel'**
  String get exportExcel;

  /// No description provided for @exportPdf.
  ///
  /// In en, this message translates to:
  /// **'Export PDF'**
  String get exportPdf;

  /// No description provided for @leave.
  ///
  /// In en, this message translates to:
  /// **'Leave'**
  String get leave;

  /// No description provided for @leaveRequests.
  ///
  /// In en, this message translates to:
  /// **'Leave requests'**
  String get leaveRequests;

  /// No description provided for @approve.
  ///
  /// In en, this message translates to:
  /// **'Approve'**
  String get approve;

  /// No description provided for @reject.
  ///
  /// In en, this message translates to:
  /// **'Reject'**
  String get reject;

  /// No description provided for @leaveBalance.
  ///
  /// In en, this message translates to:
  /// **'Leave balance'**
  String get leaveBalance;

  /// No description provided for @requestLeave.
  ///
  /// In en, this message translates to:
  /// **'Request leave'**
  String get requestLeave;

  /// No description provided for @payroll.
  ///
  /// In en, this message translates to:
  /// **'Payroll'**
  String get payroll;

  /// No description provided for @monthlyPayroll.
  ///
  /// In en, this message translates to:
  /// **'Monthly payroll'**
  String get monthlyPayroll;

  /// No description provided for @salaryBreakdown.
  ///
  /// In en, this message translates to:
  /// **'Salary breakdown'**
  String get salaryBreakdown;

  /// No description provided for @generatePayslip.
  ///
  /// In en, this message translates to:
  /// **'Generate payslip'**
  String get generatePayslip;

  /// No description provided for @payslip.
  ///
  /// In en, this message translates to:
  /// **'Payslip'**
  String get payslip;

  /// No description provided for @payslipEmployeeSection.
  ///
  /// In en, this message translates to:
  /// **'Employee'**
  String get payslipEmployeeSection;

  /// No description provided for @payslipEarningsSection.
  ///
  /// In en, this message translates to:
  /// **'Earnings'**
  String get payslipEarningsSection;

  /// No description provided for @payslipDeductionsSection.
  ///
  /// In en, this message translates to:
  /// **'Deductions'**
  String get payslipDeductionsSection;

  /// No description provided for @recruitment.
  ///
  /// In en, this message translates to:
  /// **'Recruitment'**
  String get recruitment;

  /// No description provided for @jobListings.
  ///
  /// In en, this message translates to:
  /// **'Job listings'**
  String get jobListings;

  /// No description provided for @candidates.
  ///
  /// In en, this message translates to:
  /// **'Candidates'**
  String get candidates;

  /// No description provided for @convertToEmployee.
  ///
  /// In en, this message translates to:
  /// **'Convert to employee'**
  String get convertToEmployee;

  /// No description provided for @recruitmentStageNew.
  ///
  /// In en, this message translates to:
  /// **'New'**
  String get recruitmentStageNew;

  /// No description provided for @recruitmentStageInterview.
  ///
  /// In en, this message translates to:
  /// **'Interview'**
  String get recruitmentStageInterview;

  /// No description provided for @recruitmentStageOffer.
  ///
  /// In en, this message translates to:
  /// **'Job offer'**
  String get recruitmentStageOffer;

  /// No description provided for @recruitmentStageHired.
  ///
  /// In en, this message translates to:
  /// **'Hired'**
  String get recruitmentStageHired;

  /// No description provided for @recruitmentJobTitleFlutterDeveloper.
  ///
  /// In en, this message translates to:
  /// **'Flutter Developer'**
  String get recruitmentJobTitleFlutterDeveloper;

  /// No description provided for @recruitmentJobTitleAccountant.
  ///
  /// In en, this message translates to:
  /// **'Accountant'**
  String get recruitmentJobTitleAccountant;

  /// No description provided for @recruitmentDepartmentTechnical.
  ///
  /// In en, this message translates to:
  /// **'Technology'**
  String get recruitmentDepartmentTechnical;

  /// No description provided for @recruitmentDepartmentFinance.
  ///
  /// In en, this message translates to:
  /// **'Finance'**
  String get recruitmentDepartmentFinance;

  /// No description provided for @recruitmentJobStatusOpen.
  ///
  /// In en, this message translates to:
  /// **'Open'**
  String get recruitmentJobStatusOpen;

  /// No description provided for @recruitmentApplicantFileExample.
  ///
  /// In en, this message translates to:
  /// **'Applicant file — example'**
  String get recruitmentApplicantFileExample;

  /// No description provided for @recruitmentApplicantNameSample.
  ///
  /// In en, this message translates to:
  /// **'Ahmed Applicant'**
  String get recruitmentApplicantNameSample;

  /// No description provided for @recruitmentApplicantRoleSample.
  ///
  /// In en, this message translates to:
  /// **'Flutter Developer'**
  String get recruitmentApplicantRoleSample;

  /// No description provided for @recruitmentApplicantEmailSample.
  ///
  /// In en, this message translates to:
  /// **'ahmed@email.com'**
  String get recruitmentApplicantEmailSample;

  /// No description provided for @recruitmentApplicantsCount.
  ///
  /// In en, this message translates to:
  /// **'{count} applicants'**
  String recruitmentApplicantsCount(int count);

  /// No description provided for @recruitmentApplicantIndexed.
  ///
  /// In en, this message translates to:
  /// **'Applicant {index}'**
  String recruitmentApplicantIndexed(int index);

  /// No description provided for @recruitmentJobDetailsTitle.
  ///
  /// In en, this message translates to:
  /// **'Job details'**
  String get recruitmentJobDetailsTitle;

  /// No description provided for @recruitmentLocationLabel.
  ///
  /// In en, this message translates to:
  /// **'Location'**
  String get recruitmentLocationLabel;

  /// No description provided for @recruitmentLocationValue.
  ///
  /// In en, this message translates to:
  /// **'Riyadh'**
  String get recruitmentLocationValue;

  /// No description provided for @recruitmentApplicantsLabel.
  ///
  /// In en, this message translates to:
  /// **'Applicants'**
  String get recruitmentApplicantsLabel;

  /// No description provided for @recruitmentDescriptionLabel.
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get recruitmentDescriptionLabel;

  /// No description provided for @recruitmentJobDescriptionSample.
  ///
  /// In en, this message translates to:
  /// **'We are looking for a passionate Flutter developer to join our team. Experience building multi-platform applications is required, along with strong Dart and Flutter skills.'**
  String get recruitmentJobDescriptionSample;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @companyInfo.
  ///
  /// In en, this message translates to:
  /// **'Company information'**
  String get companyInfo;

  /// No description provided for @rolesPermissions.
  ///
  /// In en, this message translates to:
  /// **'Roles & permissions'**
  String get rolesPermissions;

  /// No description provided for @subscriptionBilling.
  ///
  /// In en, this message translates to:
  /// **'Subscription & billing'**
  String get subscriptionBilling;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @search.
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get search;

  /// No description provided for @filter.
  ///
  /// In en, this message translates to:
  /// **'Filter'**
  String get filter;

  /// No description provided for @export.
  ///
  /// In en, this message translates to:
  /// **'Export'**
  String get export;

  /// No description provided for @date.
  ///
  /// In en, this message translates to:
  /// **'Date'**
  String get date;

  /// No description provided for @name.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get name;

  /// No description provided for @department.
  ///
  /// In en, this message translates to:
  /// **'Department'**
  String get department;

  /// No description provided for @position.
  ///
  /// In en, this message translates to:
  /// **'Position'**
  String get position;

  /// No description provided for @actions.
  ///
  /// In en, this message translates to:
  /// **'Actions'**
  String get actions;

  /// No description provided for @view.
  ///
  /// In en, this message translates to:
  /// **'View'**
  String get view;

  /// No description provided for @edit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get edit;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @appearance.
  ///
  /// In en, this message translates to:
  /// **'Appearance'**
  String get appearance;

  /// No description provided for @darkMode.
  ///
  /// In en, this message translates to:
  /// **'Dark mode'**
  String get darkMode;

  /// No description provided for @darkModeOn.
  ///
  /// In en, this message translates to:
  /// **'On'**
  String get darkModeOn;

  /// No description provided for @darkModeOff.
  ///
  /// In en, this message translates to:
  /// **'Off'**
  String get darkModeOff;

  /// No description provided for @lightMode.
  ///
  /// In en, this message translates to:
  /// **'Light mode'**
  String get lightMode;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @languageTitle.
  ///
  /// In en, this message translates to:
  /// **'App language'**
  String get languageTitle;

  /// No description provided for @arabic.
  ///
  /// In en, this message translates to:
  /// **'Arabic'**
  String get arabic;

  /// No description provided for @english.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get english;

  /// No description provided for @serverBindingTitle.
  ///
  /// In en, this message translates to:
  /// **'Server (Laravel API)'**
  String get serverBindingTitle;

  /// No description provided for @serverBindingDescription.
  ///
  /// In en, this message translates to:
  /// **'Enter your API base URL (e.g. https://your-domain.com/api) and enable \"Use server\" to connect.'**
  String get serverBindingDescription;

  /// No description provided for @baseUrlLabel.
  ///
  /// In en, this message translates to:
  /// **'Base URL'**
  String get baseUrlLabel;

  /// No description provided for @baseUrlHint.
  ///
  /// In en, this message translates to:
  /// **'https://your-laravel.com/api'**
  String get baseUrlHint;

  /// No description provided for @useServer.
  ///
  /// In en, this message translates to:
  /// **'Use server'**
  String get useServer;

  /// No description provided for @serverEnabled.
  ///
  /// In en, this message translates to:
  /// **'Server connection enabled'**
  String get serverEnabled;

  /// No description provided for @serverDisabled.
  ///
  /// In en, this message translates to:
  /// **'Using demo data'**
  String get serverDisabled;

  /// No description provided for @serverSettingsSaved.
  ///
  /// In en, this message translates to:
  /// **'Server settings saved'**
  String get serverSettingsSaved;

  /// No description provided for @companySavedLocal.
  ///
  /// In en, this message translates to:
  /// **'Company info saved locally (demo)'**
  String get companySavedLocal;

  /// No description provided for @planUpgradeLater.
  ///
  /// In en, this message translates to:
  /// **'Plan upgrades will be available via the billing portal.'**
  String get planUpgradeLater;

  /// No description provided for @employeeNavHome.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get employeeNavHome;

  /// No description provided for @employeeNavAttendance.
  ///
  /// In en, this message translates to:
  /// **'Attendance'**
  String get employeeNavAttendance;

  /// No description provided for @employeeNavLeave.
  ///
  /// In en, this message translates to:
  /// **'Leave'**
  String get employeeNavLeave;

  /// No description provided for @employeeNavPayroll.
  ///
  /// In en, this message translates to:
  /// **'Payroll'**
  String get employeeNavPayroll;

  /// No description provided for @employeeNavProfile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get employeeNavProfile;

  /// No description provided for @myNotifications.
  ///
  /// In en, this message translates to:
  /// **'My notifications'**
  String get myNotifications;

  /// No description provided for @retryAction.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retryAction;

  /// No description provided for @noNotifications.
  ///
  /// In en, this message translates to:
  /// **'No notifications'**
  String get noNotifications;

  /// No description provided for @refreshTooltip.
  ///
  /// In en, this message translates to:
  /// **'Refresh'**
  String get refreshTooltip;

  /// No description provided for @payslipDownloadLater.
  ///
  /// In en, this message translates to:
  /// **'PDF download will use the server in production (demo: planned).'**
  String get payslipDownloadLater;

  /// No description provided for @rolePermissionsServer.
  ///
  /// In en, this message translates to:
  /// **'Permission changes are saved on the server in the full release.'**
  String get rolePermissionsServer;

  /// No description provided for @jobEditServer.
  ///
  /// In en, this message translates to:
  /// **'Editing job {jobId} — saved on the server when enabled.'**
  String jobEditServer(String jobId);

  /// No description provided for @convertEmployeeHint.
  ///
  /// In en, this message translates to:
  /// **'Candidate will be added as an employee (complete the form).'**
  String get convertEmployeeHint;

  /// No description provided for @sessionExpired.
  ///
  /// In en, this message translates to:
  /// **'Session expired. Please sign in again.'**
  String get sessionExpired;

  /// No description provided for @apiHttpsRequired.
  ///
  /// In en, this message translates to:
  /// **'Use https:// for the API URL in production (localhost is allowed).'**
  String get apiHttpsRequired;

  /// No description provided for @invalidApiUrl.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid API URL (e.g. https://example.com/api).'**
  String get invalidApiUrl;

  /// No description provided for @apiUrlRequired.
  ///
  /// In en, this message translates to:
  /// **'Enter the server URL before enabling API mode.'**
  String get apiUrlRequired;

  /// No description provided for @notificationsTitle.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get notificationsTitle;

  /// No description provided for @employeeNotificationsTitle.
  ///
  /// In en, this message translates to:
  /// **'My notifications'**
  String get employeeNotificationsTitle;

  /// No description provided for @phone.
  ///
  /// In en, this message translates to:
  /// **'Phone'**
  String get phone;

  /// No description provided for @address.
  ///
  /// In en, this message translates to:
  /// **'Address'**
  String get address;

  /// No description provided for @wifiAttendanceTitle.
  ///
  /// In en, this message translates to:
  /// **'Wi‑Fi attendance'**
  String get wifiAttendanceTitle;

  /// No description provided for @wifiAttendanceBody.
  ///
  /// In en, this message translates to:
  /// **'Check-in is allowed only when the device is on the company Wi‑Fi.'**
  String get wifiAttendanceBody;

  /// No description provided for @wifiSsidLabel.
  ///
  /// In en, this message translates to:
  /// **'Wi‑Fi network name (SSID)'**
  String get wifiSsidLabel;

  /// No description provided for @wifiSsidHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. Company_Office'**
  String get wifiSsidHint;

  /// No description provided for @wifiSettingsSaved.
  ///
  /// In en, this message translates to:
  /// **'Wi‑Fi attendance settings saved'**
  String get wifiSettingsSaved;

  /// No description provided for @dataFromServer.
  ///
  /// In en, this message translates to:
  /// **'Data from Laravel'**
  String get dataFromServer;

  /// No description provided for @dataLocalDemo.
  ///
  /// In en, this message translates to:
  /// **'Local demo data'**
  String get dataLocalDemo;

  /// No description provided for @subscriptionPlanName.
  ///
  /// In en, this message translates to:
  /// **'Professional plan'**
  String get subscriptionPlanName;

  /// No description provided for @subscriptionPlanPrice.
  ///
  /// In en, this message translates to:
  /// **'50 employees • 1,200 SAR/month'**
  String get subscriptionPlanPrice;

  /// No description provided for @upgradePlan.
  ///
  /// In en, this message translates to:
  /// **'Upgrade plan'**
  String get upgradePlan;

  /// No description provided for @paymentPortalLater.
  ///
  /// In en, this message translates to:
  /// **'Payment and upgrades will connect to the billing portal at launch.'**
  String get paymentPortalLater;

  /// No description provided for @roleAdminTitle.
  ///
  /// In en, this message translates to:
  /// **'System administrator'**
  String get roleAdminTitle;

  /// No description provided for @roleAdminSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Full access'**
  String get roleAdminSubtitle;

  /// No description provided for @roleHrTitle.
  ///
  /// In en, this message translates to:
  /// **'HR manager'**
  String get roleHrTitle;

  /// No description provided for @roleHrSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Employees and attendance'**
  String get roleHrSubtitle;

  /// No description provided for @roleEmployeeTitle.
  ///
  /// In en, this message translates to:
  /// **'Employee'**
  String get roleEmployeeTitle;

  /// No description provided for @roleEmployeeSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Own data only'**
  String get roleEmployeeSubtitle;

  /// No description provided for @featureEmployees.
  ///
  /// In en, this message translates to:
  /// **'Employees'**
  String get featureEmployees;

  /// No description provided for @featureAttendance.
  ///
  /// In en, this message translates to:
  /// **'Attendance'**
  String get featureAttendance;

  /// No description provided for @featureLeave.
  ///
  /// In en, this message translates to:
  /// **'Leave'**
  String get featureLeave;

  /// No description provided for @featurePayroll.
  ///
  /// In en, this message translates to:
  /// **'Payroll'**
  String get featurePayroll;

  /// No description provided for @featureRecruitment.
  ///
  /// In en, this message translates to:
  /// **'Recruitment'**
  String get featureRecruitment;

  /// No description provided for @dashboardOverview.
  ///
  /// In en, this message translates to:
  /// **'Company activity at a glance'**
  String get dashboardOverview;

  /// No description provided for @ofSeats.
  ///
  /// In en, this message translates to:
  /// **'of 50 seats'**
  String get ofSeats;

  /// No description provided for @needsReview.
  ///
  /// In en, this message translates to:
  /// **'Awaiting review'**
  String get needsReview;

  /// No description provided for @payrollDone.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get payrollDone;

  /// No description provided for @payrollMonthSample.
  ///
  /// In en, this message translates to:
  /// **'February 2025'**
  String get payrollMonthSample;

  /// No description provided for @viewAll.
  ///
  /// In en, this message translates to:
  /// **'View all'**
  String get viewAll;

  /// No description provided for @leaveType.
  ///
  /// In en, this message translates to:
  /// **'Leave type'**
  String get leaveType;

  /// No description provided for @leaveApproved.
  ///
  /// In en, this message translates to:
  /// **'Approved'**
  String get leaveApproved;

  /// No description provided for @leaveRejected.
  ///
  /// In en, this message translates to:
  /// **'Rejected'**
  String get leaveRejected;

  /// No description provided for @adminProfileMenu.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get adminProfileMenu;

  /// No description provided for @logout.
  ///
  /// In en, this message translates to:
  /// **'Sign out'**
  String get logout;

  /// No description provided for @sampleAdminName.
  ///
  /// In en, this message translates to:
  /// **'Ahmed (Manager)'**
  String get sampleAdminName;

  /// No description provided for @sampleAdminRole.
  ///
  /// In en, this message translates to:
  /// **'HR Manager'**
  String get sampleAdminRole;

  /// No description provided for @refreshAction.
  ///
  /// In en, this message translates to:
  /// **'Refresh'**
  String get refreshAction;

  /// No description provided for @attendanceEditGrid.
  ///
  /// In en, this message translates to:
  /// **'Edit attendance for the table — saved on the server when enabled.'**
  String get attendanceEditGrid;

  /// No description provided for @attendanceEditEmployee.
  ///
  /// In en, this message translates to:
  /// **'Edit attendance for {name} — saved on the server when enabled.'**
  String attendanceEditEmployee(String name);

  /// No description provided for @exportPrepared.
  ///
  /// In en, this message translates to:
  /// **'{format} prepared for demo. Real export connects to Laravel.'**
  String exportPrepared(String format);

  /// No description provided for @formatExcel.
  ///
  /// In en, this message translates to:
  /// **'Excel file'**
  String get formatExcel;

  /// No description provided for @formatPdf.
  ///
  /// In en, this message translates to:
  /// **'PDF file'**
  String get formatPdf;

  /// No description provided for @payrollGenerateDemo.
  ///
  /// In en, this message translates to:
  /// **'Payslip generation scheduled for demo. Execution runs on the server.'**
  String get payrollGenerateDemo;

  /// No description provided for @colEmployee.
  ///
  /// In en, this message translates to:
  /// **'Employee'**
  String get colEmployee;

  /// No description provided for @colBaseSalary.
  ///
  /// In en, this message translates to:
  /// **'Base salary'**
  String get colBaseSalary;

  /// No description provided for @colAllowances.
  ///
  /// In en, this message translates to:
  /// **'Allowances'**
  String get colAllowances;

  /// No description provided for @colDeductions.
  ///
  /// In en, this message translates to:
  /// **'Deductions'**
  String get colDeductions;

  /// No description provided for @colNetSalary.
  ///
  /// In en, this message translates to:
  /// **'Net salary'**
  String get colNetSalary;

  /// No description provided for @colStatus.
  ///
  /// In en, this message translates to:
  /// **'Status'**
  String get colStatus;

  /// No description provided for @colCheckIn.
  ///
  /// In en, this message translates to:
  /// **'Check-in time'**
  String get colCheckIn;

  /// No description provided for @colCheckOut.
  ///
  /// In en, this message translates to:
  /// **'Check-out time'**
  String get colCheckOut;

  /// No description provided for @colWorkHours.
  ///
  /// In en, this message translates to:
  /// **'Work hours'**
  String get colWorkHours;

  /// No description provided for @breakdownBase.
  ///
  /// In en, this message translates to:
  /// **'Base salary'**
  String get breakdownBase;

  /// No description provided for @breakdownAllowances.
  ///
  /// In en, this message translates to:
  /// **'Allowances'**
  String get breakdownAllowances;

  /// No description provided for @breakdownDeductions.
  ///
  /// In en, this message translates to:
  /// **'Deductions'**
  String get breakdownDeductions;

  /// No description provided for @breakdownNet.
  ///
  /// In en, this message translates to:
  /// **'Net pay'**
  String get breakdownNet;

  /// No description provided for @filterAllDepartments.
  ///
  /// In en, this message translates to:
  /// **'All departments'**
  String get filterAllDepartments;

  /// No description provided for @filterDepartmentButton.
  ///
  /// In en, this message translates to:
  /// **'Dept: {name}'**
  String filterDepartmentButton(String name);

  /// No description provided for @monthFebruary2025.
  ///
  /// In en, this message translates to:
  /// **'February 2025'**
  String get monthFebruary2025;

  /// No description provided for @monthJanuary2025.
  ///
  /// In en, this message translates to:
  /// **'January 2025'**
  String get monthJanuary2025;

  /// No description provided for @formSavedSuccess.
  ///
  /// In en, this message translates to:
  /// **'Saved successfully'**
  String get formSavedSuccess;

  /// No description provided for @fieldRequired.
  ///
  /// In en, this message translates to:
  /// **'Required'**
  String get fieldRequired;

  /// No description provided for @fullName.
  ///
  /// In en, this message translates to:
  /// **'Full name'**
  String get fullName;

  /// No description provided for @birthDate.
  ///
  /// In en, this message translates to:
  /// **'Date of birth'**
  String get birthDate;

  /// No description provided for @hireDate.
  ///
  /// In en, this message translates to:
  /// **'Hire date'**
  String get hireDate;

  /// No description provided for @bankAccount.
  ///
  /// In en, this message translates to:
  /// **'Bank account number'**
  String get bankAccount;

  /// No description provided for @insuranceType.
  ///
  /// In en, this message translates to:
  /// **'Insurance type'**
  String get insuranceType;

  /// No description provided for @insuranceHealthOpt.
  ///
  /// In en, this message translates to:
  /// **'Health insurance'**
  String get insuranceHealthOpt;

  /// No description provided for @insuranceSocialOpt.
  ///
  /// In en, this message translates to:
  /// **'Social insurance'**
  String get insuranceSocialOpt;

  /// No description provided for @insuranceOtherOpt.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get insuranceOtherOpt;

  /// No description provided for @policyNumber.
  ///
  /// In en, this message translates to:
  /// **'Policy / member ID'**
  String get policyNumber;

  /// No description provided for @insuranceCompany.
  ///
  /// In en, this message translates to:
  /// **'Insurance provider'**
  String get insuranceCompany;

  /// No description provided for @coverageStart.
  ///
  /// In en, this message translates to:
  /// **'Coverage start'**
  String get coverageStart;

  /// No description provided for @coverageEnd.
  ///
  /// In en, this message translates to:
  /// **'Coverage end'**
  String get coverageEnd;

  /// No description provided for @payslipMonthField.
  ///
  /// In en, this message translates to:
  /// **'Pay period'**
  String get payslipMonthField;

  /// No description provided for @download.
  ///
  /// In en, this message translates to:
  /// **'Download'**
  String get download;

  /// No description provided for @addJob.
  ///
  /// In en, this message translates to:
  /// **'Add job'**
  String get addJob;

  /// No description provided for @recruitmentPaidBanner.
  ///
  /// In en, this message translates to:
  /// **'Paid feature — enable in settings'**
  String get recruitmentPaidBanner;

  /// No description provided for @loginBrandingTitle.
  ///
  /// In en, this message translates to:
  /// **'Human resources management'**
  String get loginBrandingTitle;

  /// No description provided for @loginBrandingSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Employees, attendance, leave and payroll in one place.'**
  String get loginBrandingSubtitle;

  /// No description provided for @loginFormSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Enter your credentials to access the dashboard.'**
  String get loginFormSubtitle;

  /// No description provided for @enterEmail.
  ///
  /// In en, this message translates to:
  /// **'Enter your email'**
  String get enterEmail;

  /// No description provided for @enterPassword.
  ///
  /// In en, this message translates to:
  /// **'Enter your password'**
  String get enterPassword;

  /// No description provided for @forgotPasswordTitle.
  ///
  /// In en, this message translates to:
  /// **'Reset password'**
  String get forgotPasswordTitle;

  /// No description provided for @forgotPasswordBody.
  ///
  /// In en, this message translates to:
  /// **'Enter your email and we will send a reset link.'**
  String get forgotPasswordBody;

  /// No description provided for @sendResetLink.
  ///
  /// In en, this message translates to:
  /// **'Send link'**
  String get sendResetLink;

  /// No description provided for @backToLogin.
  ///
  /// In en, this message translates to:
  /// **'Back to sign in'**
  String get backToLogin;

  /// No description provided for @resetLinkSent.
  ///
  /// In en, this message translates to:
  /// **'Link sent'**
  String get resetLinkSent;

  /// No description provided for @resetLinkSentBody.
  ///
  /// In en, this message translates to:
  /// **'Check your email and follow the link to reset your password.'**
  String get resetLinkSentBody;

  /// No description provided for @addCompanyTitle.
  ///
  /// In en, this message translates to:
  /// **'Add company'**
  String get addCompanyTitle;

  /// No description provided for @demoCompanyLabel.
  ///
  /// In en, this message translates to:
  /// **'Demo company'**
  String get demoCompanyLabel;

  /// No description provided for @companyAddedSuccess.
  ///
  /// In en, this message translates to:
  /// **'Company added successfully'**
  String get companyAddedSuccess;

  /// No description provided for @jobTitleField.
  ///
  /// In en, this message translates to:
  /// **'Job title'**
  String get jobTitleField;

  /// No description provided for @jobLocationField.
  ///
  /// In en, this message translates to:
  /// **'Location'**
  String get jobLocationField;

  /// No description provided for @jobDescriptionField.
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get jobDescriptionField;

  /// No description provided for @jobAddedSuccess.
  ///
  /// In en, this message translates to:
  /// **'Job added successfully'**
  String get jobAddedSuccess;

  /// No description provided for @payslipDownloading.
  ///
  /// In en, this message translates to:
  /// **'Downloading payslip…'**
  String get payslipDownloading;

  /// No description provided for @registerSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Create a new company account — multi-tenant Nawa Tech HRM'**
  String get registerSubtitle;

  /// No description provided for @enterCompanyName.
  ///
  /// In en, this message translates to:
  /// **'Enter company name'**
  String get enterCompanyName;

  /// No description provided for @haveAccountLogin.
  ///
  /// In en, this message translates to:
  /// **'Already have an account? Sign in'**
  String get haveAccountLogin;

  /// No description provided for @leaveAdminSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Manage leave requests and approvals'**
  String get leaveAdminSubtitle;

  /// No description provided for @filterAll.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get filterAll;

  /// No description provided for @filterPendingShort.
  ///
  /// In en, this message translates to:
  /// **'Pending'**
  String get filterPendingShort;

  /// No description provided for @filterApprovedShort.
  ///
  /// In en, this message translates to:
  /// **'Approved'**
  String get filterApprovedShort;

  /// No description provided for @filterRejectedShort.
  ///
  /// In en, this message translates to:
  /// **'Rejected'**
  String get filterRejectedShort;

  /// No description provided for @leaveColFrom.
  ///
  /// In en, this message translates to:
  /// **'From'**
  String get leaveColFrom;

  /// No description provided for @leaveColTo.
  ///
  /// In en, this message translates to:
  /// **'To'**
  String get leaveColTo;

  /// No description provided for @leaveColDays.
  ///
  /// In en, this message translates to:
  /// **'Days'**
  String get leaveColDays;

  /// No description provided for @leaveColBalanceLeft.
  ///
  /// In en, this message translates to:
  /// **'Balance left'**
  String get leaveColBalanceLeft;

  /// No description provided for @leaveBalancePerEmployee.
  ///
  /// In en, this message translates to:
  /// **'Leave balance by employee'**
  String get leaveBalancePerEmployee;

  /// No description provided for @annualShort.
  ///
  /// In en, this message translates to:
  /// **'Annual'**
  String get annualShort;

  /// No description provided for @sickShort.
  ///
  /// In en, this message translates to:
  /// **'Sick'**
  String get sickShort;

  /// No description provided for @emergencyShort.
  ///
  /// In en, this message translates to:
  /// **'Emergency'**
  String get emergencyShort;

  /// No description provided for @wifiChecking.
  ///
  /// In en, this message translates to:
  /// **'Checking…'**
  String get wifiChecking;

  /// No description provided for @wifiOnCompany.
  ///
  /// In en, this message translates to:
  /// **'Connected to company network'**
  String get wifiOnCompany;

  /// No description provided for @wifiOffCompany.
  ///
  /// In en, this message translates to:
  /// **'Not connected — attendance only on company Wi‑Fi'**
  String get wifiOffCompany;

  /// No description provided for @networkLabel.
  ///
  /// In en, this message translates to:
  /// **'Network: {name}'**
  String networkLabel(String name);

  /// No description provided for @recheckWifi.
  ///
  /// In en, this message translates to:
  /// **'Recheck'**
  String get recheckWifi;

  /// No description provided for @attendanceTodayTitle.
  ///
  /// In en, this message translates to:
  /// **'Today\'s attendance'**
  String get attendanceTodayTitle;

  /// No description provided for @checkInTimeSample.
  ///
  /// In en, this message translates to:
  /// **'08:00'**
  String get checkInTimeSample;

  /// No description provided for @checkInRecorded.
  ///
  /// In en, this message translates to:
  /// **'Checked in'**
  String get checkInRecorded;

  /// No description provided for @greetingHello.
  ///
  /// In en, this message translates to:
  /// **'Hello'**
  String get greetingHello;

  /// No description provided for @greetingWithName.
  ///
  /// In en, this message translates to:
  /// **'Hello, {name}'**
  String greetingWithName(String name);

  /// No description provided for @homeDateSample.
  ///
  /// In en, this message translates to:
  /// **'Saturday, 7 February 2025'**
  String get homeDateSample;

  /// No description provided for @wifiCheckingHome.
  ///
  /// In en, this message translates to:
  /// **'Checking Wi‑Fi…'**
  String get wifiCheckingHome;

  /// No description provided for @wifiNotOnCompanyHome.
  ///
  /// In en, this message translates to:
  /// **'Not on company network'**
  String get wifiNotOnCompanyHome;

  /// No description provided for @attendanceOnlyWifiHint.
  ///
  /// In en, this message translates to:
  /// **'Check-in works only on the company Wi‑Fi.'**
  String get attendanceOnlyWifiHint;

  /// No description provided for @quickActionsTitle.
  ///
  /// In en, this message translates to:
  /// **'Quick actions'**
  String get quickActionsTitle;

  /// No description provided for @attendanceLogLabel.
  ///
  /// In en, this message translates to:
  /// **'Attendance log'**
  String get attendanceLogLabel;

  /// No description provided for @profileQuickLabel.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profileQuickLabel;

  /// No description provided for @notificationsTooltip.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get notificationsTooltip;

  /// No description provided for @employeeAppSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Employee app'**
  String get employeeAppSubtitle;

  /// No description provided for @leaveNotes.
  ///
  /// In en, this message translates to:
  /// **'Reason / notes'**
  String get leaveNotes;

  /// No description provided for @documentsSection.
  ///
  /// In en, this message translates to:
  /// **'Documents'**
  String get documentsSection;

  /// No description provided for @employmentContract.
  ///
  /// In en, this message translates to:
  /// **'Employment contract'**
  String get employmentContract;

  /// No description provided for @payslipJanuaryDoc.
  ///
  /// In en, this message translates to:
  /// **'Payslip — January'**
  String get payslipJanuaryDoc;

  /// No description provided for @companyLabelRow.
  ///
  /// In en, this message translates to:
  /// **'Company'**
  String get companyLabelRow;

  /// No description provided for @roleLabelRow.
  ///
  /// In en, this message translates to:
  /// **'Role'**
  String get roleLabelRow;

  /// No description provided for @baseSalaryLabel.
  ///
  /// In en, this message translates to:
  /// **'Base salary'**
  String get baseSalaryLabel;

  /// No description provided for @roleDetailTitle.
  ///
  /// In en, this message translates to:
  /// **'Role details'**
  String get roleDetailTitle;

  /// No description provided for @permissionsTitle.
  ///
  /// In en, this message translates to:
  /// **'Permissions'**
  String get permissionsTitle;

  /// No description provided for @editPermissionsButton.
  ///
  /// In en, this message translates to:
  /// **'Edit permissions'**
  String get editPermissionsButton;

  /// No description provided for @aiAssistantWelcome.
  ///
  /// In en, this message translates to:
  /// **'Hi! I am your assistant. Ask about employees, attendance, leave, or payroll.'**
  String get aiAssistantWelcome;

  /// No description provided for @apiBaseUrlMissing.
  ///
  /// In en, this message translates to:
  /// **'Server URL is not configured.'**
  String get apiBaseUrlMissing;

  /// No description provided for @apiErrorServer.
  ///
  /// In en, this message translates to:
  /// **'Server error'**
  String get apiErrorServer;

  /// No description provided for @apiErrorConnection.
  ///
  /// In en, this message translates to:
  /// **'Connection error: {details}'**
  String apiErrorConnection(String details);

  /// No description provided for @apiInvalidResponse.
  ///
  /// In en, this message translates to:
  /// **'Invalid response from server'**
  String get apiInvalidResponse;

  /// No description provided for @apiNoTokenReceived.
  ///
  /// In en, this message translates to:
  /// **'No authentication token received'**
  String get apiNoTokenReceived;

  /// No description provided for @apiReadResponseFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not read server response: {details}'**
  String apiReadResponseFailed(String details);

  /// No description provided for @apiErrorEmployeesList.
  ///
  /// In en, this message translates to:
  /// **'Could not load employees: {details}'**
  String apiErrorEmployeesList(String details);

  /// No description provided for @apiErrorEmployeeDetail.
  ///
  /// In en, this message translates to:
  /// **'Could not load employee: {details}'**
  String apiErrorEmployeeDetail(String details);

  /// No description provided for @apiErrorAttendance.
  ///
  /// In en, this message translates to:
  /// **'Could not load attendance: {details}'**
  String apiErrorAttendance(String details);

  /// No description provided for @apiErrorLeaveRequests.
  ///
  /// In en, this message translates to:
  /// **'Could not load leave requests: {details}'**
  String apiErrorLeaveRequests(String details);

  /// No description provided for @apiErrorLeaveBalances.
  ///
  /// In en, this message translates to:
  /// **'Could not load leave balances: {details}'**
  String apiErrorLeaveBalances(String details);

  /// No description provided for @apiErrorPayroll.
  ///
  /// In en, this message translates to:
  /// **'Could not load payroll: {details}'**
  String apiErrorPayroll(String details);

  /// No description provided for @apiErrorNotifications.
  ///
  /// In en, this message translates to:
  /// **'Could not load notifications: {details}'**
  String apiErrorNotifications(String details);

  /// No description provided for @demoUserName.
  ///
  /// In en, this message translates to:
  /// **'Demo user'**
  String get demoUserName;

  /// No description provided for @leaveApproveSuccess.
  ///
  /// In en, this message translates to:
  /// **'Leave request approved'**
  String get leaveApproveSuccess;

  /// No description provided for @leaveRejectSuccess.
  ///
  /// In en, this message translates to:
  /// **'Leave request rejected'**
  String get leaveRejectSuccess;

  /// No description provided for @registerSuccessServer.
  ///
  /// In en, this message translates to:
  /// **'Account created. You can sign in now.'**
  String get registerSuccessServer;

  /// No description provided for @aiPanelTitle.
  ///
  /// In en, this message translates to:
  /// **'AI assistant'**
  String get aiPanelTitle;

  /// No description provided for @aiTyping.
  ///
  /// In en, this message translates to:
  /// **'Typing…'**
  String get aiTyping;

  /// No description provided for @aiInputHint.
  ///
  /// In en, this message translates to:
  /// **'Ask about employees, attendance, leave…'**
  String get aiInputHint;

  /// No description provided for @planStarter.
  ///
  /// In en, this message translates to:
  /// **'Starter'**
  String get planStarter;

  /// No description provided for @planStarterDesc.
  ///
  /// In en, this message translates to:
  /// **'Up to 25 employees • core Nawa Tech HRM'**
  String get planStarterDesc;

  /// No description provided for @planGrowth.
  ///
  /// In en, this message translates to:
  /// **'Growth'**
  String get planGrowth;

  /// No description provided for @planGrowthDesc.
  ///
  /// In en, this message translates to:
  /// **'Up to 50 employees • includes recruitment'**
  String get planGrowthDesc;

  /// No description provided for @planEnterprise.
  ///
  /// In en, this message translates to:
  /// **'Enterprise'**
  String get planEnterprise;

  /// No description provided for @planEnterpriseDesc.
  ///
  /// In en, this message translates to:
  /// **'Up to 200 employees • recruitment + AI tier ready'**
  String get planEnterpriseDesc;

  /// No description provided for @saasPlanSection.
  ///
  /// In en, this message translates to:
  /// **'Plan (demo)'**
  String get saasPlanSection;

  /// No description provided for @saasRecruitmentLocked.
  ///
  /// In en, this message translates to:
  /// **'Upgrade plan in Settings to unlock recruitment.'**
  String get saasRecruitmentLocked;

  /// No description provided for @employeeLimitReached.
  ///
  /// In en, this message translates to:
  /// **'Employee limit for your plan reached. Upgrade in Settings.'**
  String get employeeLimitReached;

  /// No description provided for @loginUseWebForAdmin.
  ///
  /// In en, this message translates to:
  /// **'This account is for administrators. Sign in from the web admin panel.'**
  String get loginUseWebForAdmin;

  /// No description provided for @loginUseMobileForEmployee.
  ///
  /// In en, this message translates to:
  /// **'This account is for employees. Use the mobile app to sign in.'**
  String get loginUseMobileForEmployee;

  /// No description provided for @employeeLoginCredentialsHint.
  ///
  /// In en, this message translates to:
  /// **'Use the email and password your administrator created for mobile access.'**
  String get employeeLoginCredentialsHint;

  /// No description provided for @employeeAppLoginTab.
  ///
  /// In en, this message translates to:
  /// **'Mobile app login'**
  String get employeeAppLoginTab;

  /// No description provided for @enableEmployeeAppLogin.
  ///
  /// In en, this message translates to:
  /// **'Enable mobile app login'**
  String get enableEmployeeAppLogin;

  /// No description provided for @employeeAppLoginSectionHint.
  ///
  /// In en, this message translates to:
  /// **'Creates or updates the employee’s app password. Employees sign in on the phone only.'**
  String get employeeAppLoginSectionHint;

  /// No description provided for @employeeAppPassword.
  ///
  /// In en, this message translates to:
  /// **'App password'**
  String get employeeAppPassword;

  /// No description provided for @employeeAppPasswordConfirm.
  ///
  /// In en, this message translates to:
  /// **'Confirm app password'**
  String get employeeAppPasswordConfirm;

  /// No description provided for @appAccessPasswordMismatch.
  ///
  /// In en, this message translates to:
  /// **'App passwords do not match or are too short (min 8).'**
  String get appAccessPasswordMismatch;

  /// No description provided for @appAccessSaved.
  ///
  /// In en, this message translates to:
  /// **'Mobile app access updated.'**
  String get appAccessSaved;

  /// No description provided for @clearAction.
  ///
  /// In en, this message translates to:
  /// **'Clear'**
  String get clearAction;

  /// No description provided for @cannotDeleteOwnAccount.
  ///
  /// In en, this message translates to:
  /// **'Cannot delete your own account'**
  String get cannotDeleteOwnAccount;

  /// No description provided for @leaveStatusPending.
  ///
  /// In en, this message translates to:
  /// **'Pending'**
  String get leaveStatusPending;

  /// No description provided for @leaveStatusApproved.
  ///
  /// In en, this message translates to:
  /// **'Approved'**
  String get leaveStatusApproved;

  /// No description provided for @leaveStatusRejected.
  ///
  /// In en, this message translates to:
  /// **'Rejected'**
  String get leaveStatusRejected;

  /// No description provided for @markAllRead.
  ///
  /// In en, this message translates to:
  /// **'Mark all as read'**
  String get markAllRead;

  /// No description provided for @noJobsYet.
  ///
  /// In en, this message translates to:
  /// **'No job postings yet. Add your first job.'**
  String get noJobsYet;

  /// No description provided for @addCandidate.
  ///
  /// In en, this message translates to:
  /// **'Add candidate'**
  String get addCandidate;

  /// No description provided for @candidateName.
  ///
  /// In en, this message translates to:
  /// **'Candidate name'**
  String get candidateName;

  /// No description provided for @candidateEmail.
  ///
  /// In en, this message translates to:
  /// **'Candidate email'**
  String get candidateEmail;

  /// No description provided for @candidatePhone.
  ///
  /// In en, this message translates to:
  /// **'Candidate phone'**
  String get candidatePhone;

  /// No description provided for @candidateNotes.
  ///
  /// In en, this message translates to:
  /// **'Notes'**
  String get candidateNotes;

  /// No description provided for @candidateAdded.
  ///
  /// In en, this message translates to:
  /// **'Candidate added'**
  String get candidateAdded;

  /// No description provided for @candidateStageUpdated.
  ///
  /// In en, this message translates to:
  /// **'Stage updated'**
  String get candidateStageUpdated;

  /// No description provided for @jobDeleted.
  ///
  /// In en, this message translates to:
  /// **'Job deleted'**
  String get jobDeleted;

  /// No description provided for @jobUpdated.
  ///
  /// In en, this message translates to:
  /// **'Job updated'**
  String get jobUpdated;

  /// No description provided for @jobCreated.
  ///
  /// In en, this message translates to:
  /// **'Job created successfully'**
  String get jobCreated;

  /// No description provided for @jobStatusOpen.
  ///
  /// In en, this message translates to:
  /// **'Open'**
  String get jobStatusOpen;

  /// No description provided for @jobStatusClosed.
  ///
  /// In en, this message translates to:
  /// **'Closed'**
  String get jobStatusClosed;

  /// No description provided for @jobStatusDraft.
  ///
  /// In en, this message translates to:
  /// **'Draft'**
  String get jobStatusDraft;

  /// No description provided for @candidateStageName.
  ///
  /// In en, this message translates to:
  /// **'Stage'**
  String get candidateStageName;

  /// No description provided for @candidateStageRejected.
  ///
  /// In en, this message translates to:
  /// **'Rejected'**
  String get candidateStageRejected;

  /// No description provided for @editJob.
  ///
  /// In en, this message translates to:
  /// **'Edit job'**
  String get editJob;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['ar', 'en'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar':
      return AppLocalizationsAr();
    case 'en':
      return AppLocalizationsEn();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
