import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../api/api_config.dart';
import '../auth/auth_session.dart';
import '../saas/subscription_controller.dart';
import '../../core/utils/platform_helper.dart';
import '../../features/admin/auth/login_screen.dart';
import '../../features/admin/auth/company_register_screen.dart';
import '../../features/admin/auth/forgot_password_screen.dart';
import '../../features/admin/notifications/notifications_screen.dart';
import '../../features/admin/profile/admin_profile_screen.dart';
import '../../features/admin/companies/add_company_screen.dart';
import '../../features/admin/recruitment/job_detail_screen.dart';
import '../../features/admin/recruitment/add_job_screen.dart';
import '../../core/repositories/recruitment_repository.dart' show JobItem;
import '../../features/admin/layout/admin_layout.dart';
import '../../features/admin/dashboard/dashboard_screen.dart';
import '../../features/admin/employees/employees_screen.dart';
import '../../features/admin/employees/employee_form_screen.dart';
import '../../features/admin/employees/employee_profile_screen.dart';
import '../../features/admin/attendance/attendance_screen.dart';
import '../../features/admin/leave/leave_screen.dart';
import '../../features/admin/payroll/payroll_screen.dart';
import '../../features/admin/payroll/payslip_detail_screen.dart';
import '../../features/admin/recruitment/recruitment_screen.dart';
import '../../features/admin/settings/settings_screen.dart';
import '../../features/admin/settings/role_detail_screen.dart';
import '../../features/employee/auth/employee_login_screen.dart';
import '../../features/employee/home/employee_home_screen.dart';
import '../../features/employee/attendance/employee_attendance_screen.dart';
import '../../features/employee/leave/employee_leave_screen.dart';
import '../../features/employee/leave/leave_request_screen.dart';
import '../../features/employee/payslip/employee_payslip_screen.dart';
import '../../features/employee/profile/employee_profile_screen.dart';
import '../../features/employee/notifications/employee_notifications_screen.dart';
import '../../features/welcome/welcome_screen.dart';
import '../../l10n/app_localizations.dart';

final GlobalKey<NavigatorState> _rootNavigatorKey = GlobalKey<NavigatorState>();
final GlobalKey<NavigatorState> _adminShellNavigatorKey = GlobalKey<NavigatorState>();

String? _authRedirect(BuildContext context, GoRouterState state) {
  final path = state.uri.path;
  if (path == '/register' || path == '/forgot-password') {
    return null;
  }
  if (path == '/login') {
    if (ApiConfig.useApi && AuthSession.instance.hasSession) {
      return PlatformHelper.isAdminApp ? '/admin' : '/employee';
    }
    return null;
  }
  if (!ApiConfig.useApi) return null;
  if (!AuthSession.instance.hasSession) {
    return '/login';
  }
  return null;
}

GoRouter createAppRouter() {
  return GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: '/welcome',
    refreshListenable: AuthSession.instance,
    redirect: _authRedirect,
    routes: [
      GoRoute(
        path: '/',
        redirect: (context, state) =>
            PlatformHelper.isAdminApp ? '/admin' : '/employee',
      ),
      GoRoute(
        path: '/welcome',
        builder: (context, state) => const WelcomeScreen(),
      ),
      GoRoute(
        path: '/login',
        builder: (context, state) => PlatformHelper.isAdminApp
            ? const LoginScreen()
            : const EmployeeLoginScreen(),
      ),
      GoRoute(
        path: '/register',
        builder: (context, state) => const CompanyRegisterScreen(),
      ),
      GoRoute(
        path: '/forgot-password',
        builder: (context, state) => const ForgotPasswordScreen(),
      ),
      // Admin Web - ShellRoute للحفاظ على التخطيط عند التنقل
      ShellRoute(
        navigatorKey: _adminShellNavigatorKey,
        builder: (context, state, child) => AdminShell(child: child),
        routes: [
          GoRoute(
            path: '/admin',
            builder: (context, state) => const DashboardScreen(),
          ),
          GoRoute(
            path: '/admin/employees',
            builder: (context, state) => const EmployeesScreen(),
          ),
          GoRoute(
            path: '/admin/employees/add',
            builder: (context, state) => const EmployeeFormScreen(),
          ),
          GoRoute(
            path: '/admin/employees/:id',
            builder: (_, state) => EmployeeFormScreen(employeeId: state.pathParameters['id']),
          ),
          GoRoute(
            path: '/admin/employees/:id/view',
            builder: (_, state) => EmployeeDetailScreen(employeeId: state.pathParameters['id']),
          ),
          GoRoute(
            path: '/admin/attendance',
            builder: (context, state) => const AttendanceScreen(),
          ),
          GoRoute(
            path: '/admin/leave',
            builder: (context, state) => const LeaveScreen(),
          ),
          GoRoute(
            path: '/admin/payroll',
            builder: (context, state) => const PayrollScreen(),
          ),
          GoRoute(
            path: '/admin/payroll/payslip/:employeeId',
            builder: (context, state) => PayslipDetailScreen(
              employeeId: state.pathParameters['employeeId'],
              month: state.uri.queryParameters['month'],
            ),
          ),
          GoRoute(
            path: '/admin/recruitment',
            redirect: (context, state) =>
                SubscriptionController.instance.recruitmentEnabled ? null : '/admin/settings',
            builder: (context, state) => const RecruitmentScreen(),
          ),
          GoRoute(
            path: '/admin/recruitment/add',
            redirect: (context, state) =>
                SubscriptionController.instance.recruitmentEnabled ? null : '/admin/settings',
            builder: (context, state) => AddJobScreen(
              editJob: state.extra is JobItem ? state.extra as JobItem : null,
            ),
          ),
          GoRoute(
            path: '/admin/recruitment/job/:id',
            redirect: (context, state) =>
                SubscriptionController.instance.recruitmentEnabled ? null : '/admin/settings',
            builder: (context, state) => JobDetailScreen(jobId: state.pathParameters['id']),
          ),
          GoRoute(
            path: '/admin/settings',
            builder: (context, state) => const SettingsScreen(),
          ),
          GoRoute(
            path: '/admin/settings/role/:id',
            builder: (context, state) => RoleDetailScreen(roleId: state.pathParameters['id']),
          ),
          GoRoute(
            path: '/admin/notifications',
            builder: (context, state) => const NotificationsScreen(),
          ),
          GoRoute(
            path: '/admin/profile',
            builder: (context, state) => const AdminProfileScreen(),
          ),
          GoRoute(
            path: '/admin/companies/add',
            builder: (context, state) => const AddCompanyScreen(),
          ),
        ],
      ),
      // Employee (Mobile) routes - Shell for bottom nav
      ShellRoute(
        builder: (context, state, child) => EmployeeShell(child: child),
        routes: [
          GoRoute(
            path: '/employee',
            builder: (context, state) => const EmployeeHomeScreen(),
          ),
          GoRoute(
            path: '/employee/attendance',
            builder: (context, state) => const EmployeeAttendanceScreen(),
          ),
          GoRoute(
            path: '/employee/leave',
            builder: (context, state) => const EmployeeLeaveScreen(),
          ),
          GoRoute(
            path: '/employee/leave/request',
            builder: (context, state) => const LeaveRequestScreen(),
          ),
          GoRoute(
            path: '/employee/payslip',
            builder: (context, state) => const EmployeePayslipScreen(),
          ),
          GoRoute(
            path: '/employee/profile',
            builder: (context, state) => const EmployeeProfileScreen(),
          ),
          GoRoute(
            path: '/employee/notifications',
            builder: (context, state) => const EmployeeNotificationsScreen(),
          ),
        ],
      ),
    ],
  );
}

/// Admin shell - يعرض التخطيط فقط على الويب
class AdminShell extends StatelessWidget {
  const AdminShell({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    if (!PlatformHelper.isAdminApp) {
      return child;
    }
    return AdminLayout(child: child);
  }
}

class EmployeeShell extends StatelessWidget {
  const EmployeeShell({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    if (!PlatformHelper.isEmployeeApp) {
      return child;
    }
    return Scaffold(
      body: child,
      bottomNavigationBar: Builder(
        builder: (context) {
          final l10n = AppLocalizations.of(context)!;
          return NavigationBar(
            selectedIndex: _selectedIndex(context),
            onDestinationSelected: (i) => _onSelect(context, i),
            destinations: [
              NavigationDestination(
                icon: const Icon(Icons.home_outlined),
                selectedIcon: const Icon(Icons.home),
                label: l10n.employeeNavHome,
              ),
              NavigationDestination(
                icon: const Icon(Icons.access_time_outlined),
                selectedIcon: const Icon(Icons.access_time),
                label: l10n.employeeNavAttendance,
              ),
              NavigationDestination(
                icon: const Icon(Icons.event_note_outlined),
                selectedIcon: const Icon(Icons.event_note),
                label: l10n.employeeNavLeave,
              ),
              NavigationDestination(
                icon: const Icon(Icons.receipt_long_outlined),
                selectedIcon: const Icon(Icons.receipt_long),
                label: l10n.employeeNavPayroll,
              ),
              NavigationDestination(
                icon: const Icon(Icons.person_outline),
                selectedIcon: const Icon(Icons.person),
                label: l10n.employeeNavProfile,
              ),
            ],
          );
        },
      ),
    );
  }

  int _selectedIndex(BuildContext context) {
    final path = GoRouterState.of(context).uri.path;
    if (path.contains('attendance')) return 1;
    if (path.contains('leave')) return 2;
    if (path.contains('payslip')) return 3;
    if (path.contains('profile')) return 4;
    return 0;
  }

  void _onSelect(BuildContext context, int index) {
    switch (index) {
      case 0:
        context.go('/employee');
        break;
      case 1:
        context.go('/employee/attendance');
        break;
      case 2:
        context.go('/employee/leave');
        break;
      case 3:
        context.go('/employee/payslip');
        break;
      case 4:
        context.go('/employee/profile');
        break;
    }
  }
}
