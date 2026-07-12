import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../api/api_config.dart';
import '../auth/auth_session.dart';
import '../auth/user_role.dart';
import '../../core/utils/platform_helper.dart';
import '../../features/admin/auth/login_screen.dart';
import '../../features/admin/auth/register_screen.dart';
import '../../features/admin/auth/forgot_password_screen.dart';
import '../../features/admin/notifications/notifications_screen.dart';
import '../../features/admin/profile/admin_profile_screen.dart';
import '../../features/admin/ai/ai_command_center_screen.dart';
import '../../features/admin/performance/performance_screen.dart';
import '../../features/admin/reports/reports_screen.dart';
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
import '../../features/platform/views/platform_console_screen.dart';
import '../../features/employee/auth/employee_login_screen.dart';
import '../../features/employee/home/employee_home_screen.dart';
import '../../features/employee/attendance/employee_attendance_screen.dart';
import '../../features/employee/leave/employee_leave_screen.dart';
import '../../features/employee/leave/leave_request_screen.dart';
import '../../features/employee/payslip/employee_payslip_screen.dart';
import '../../features/employee/profile/employee_profile_screen.dart';
import '../../features/employee/notifications/employee_notifications_screen.dart';
import '../../features/welcome/welcome_screen.dart';
import '../../l10n/app_strings.dart';

final _rootKey  = GlobalKey<NavigatorState>();
final _adminKey = GlobalKey<NavigatorState>();

Page<void> Function(BuildContext, GoRouterState) _fade(Widget child) =>
    (ctx, state) => _fadeOf(ctx, state, child);

CustomTransitionPage<void> _fadeOf(BuildContext ctx, GoRouterState state, Widget child) =>
    CustomTransitionPage(
      key:                state.pageKey,
      child:              child,
      transitionDuration: const Duration(milliseconds: 220),
      transitionsBuilder: (context, animation, secondaryAnimation, child) =>
          FadeTransition(opacity: animation, child: child),
    );

String? _authRedirect(BuildContext context, GoRouterState state) {
  final path = state.uri.path;
  final session = AuthSession.instance;
  final role = session.role;

  if (path == '/register') {
    if (ApiConfig.useApi && session.hasSession) {
      return PlatformHelper.isAdminApp
          ? UserRole.webHomeFor(role)
          : '/employee';
    }
    return null;
  }
  if (path == '/forgot-password') return null;
  if (path == '/login') {
    if (ApiConfig.useApi && session.hasSession) {
      return PlatformHelper.isAdminApp
          ? UserRole.webHomeFor(role)
          : '/employee';
    }
    return null;
  }
  if (!ApiConfig.useApi) return null;
  if (!session.hasSession) return '/login';

  if (PlatformHelper.isAdminApp && UserRole.isSuperAdmin(role)) {
    if (path.startsWith('/admin')) return '/platform';
  } else if (path.startsWith('/platform')) {
    return PlatformHelper.isAdminApp ? '/admin' : '/employee';
  }

  return null;
}

GoRouter createAppRouter() => GoRouter(
      navigatorKey: _rootKey,
      initialLocation: '/welcome',
      refreshListenable: AuthSession.instance,
      redirect: _authRedirect,
      routes: [
        GoRoute(
          path: '/',
          redirect: (context, state) => PlatformHelper.isAdminApp ? '/welcome' : '/employee',
        ),
        GoRoute(path: '/welcome',         pageBuilder: _fade(const WelcomeScreen())),
        GoRoute(path: '/login',           pageBuilder: _fade(PlatformHelper.isAdminApp ? const LoginScreen() : const EmployeeLoginScreen())),
        GoRoute(path: '/register',        pageBuilder: _fade(const RegisterScreen())),
        GoRoute(path: '/forgot-password', pageBuilder: _fade(const ForgotPasswordScreen())),
        GoRoute(path: '/platform',        pageBuilder: _fade(const PlatformConsoleScreen())),

        ShellRoute(
          navigatorKey: _adminKey,
          builder: (context, state, child) => AdminShell(child: child),
          routes: [
            GoRoute(path: '/admin',               pageBuilder: _fade(const DashboardScreen())),
            GoRoute(path: '/admin/employees',      pageBuilder: _fade(const EmployeesScreen())),
            GoRoute(path: '/admin/employees/add',  pageBuilder: _fade(const EmployeeFormScreen())),
            GoRoute(path: '/admin/attendance',     pageBuilder: _fade(const AttendanceScreen())),
            GoRoute(path: '/admin/leave',          pageBuilder: _fade(const LeaveScreen())),
            GoRoute(path: '/admin/payroll',        pageBuilder: _fade(const PayrollScreen())),
            GoRoute(path: '/admin/settings',       pageBuilder: _fade(const SettingsScreen())),
            GoRoute(path: '/admin/notifications',  pageBuilder: _fade(const NotificationsScreen())),
            GoRoute(path: '/admin/profile',        pageBuilder: _fade(const AdminProfileScreen())),
            GoRoute(path: '/admin/ai',             pageBuilder: _fade(const AiCommandCenterScreen())),
            GoRoute(path: '/admin/performance',    pageBuilder: _fade(const PerformanceScreen())),
            GoRoute(path: '/admin/reports',        pageBuilder: _fade(const ReportsScreen())),
            GoRoute(path: '/admin/recruitment',    pageBuilder: _fade(const RecruitmentScreen())),
            GoRoute(
              path: '/admin/employees/:id',
              pageBuilder: (ctx, state) => _fadeOf(ctx, state,
                  EmployeeFormScreen(employeeId: state.pathParameters['id'])),
            ),
            GoRoute(
              path: '/admin/employees/:id/view',
              pageBuilder: (ctx, state) => _fadeOf(ctx, state,
                  EmployeeDetailScreen(employeeId: state.pathParameters['id'])),
            ),
            GoRoute(
              path: '/admin/payroll/payslip/:employeeId',
              pageBuilder: (ctx, state) => _fadeOf(ctx, state,
                  PayslipDetailScreen(
                    employeeId: state.pathParameters['employeeId'],
                    month:      state.uri.queryParameters['month'],
                  )),
            ),
            GoRoute(
              path: '/admin/recruitment/add',
              pageBuilder: (ctx, state) => _fadeOf(ctx, state,
                  AddJobScreen(editJob: state.extra is JobItem ? state.extra as JobItem : null)),
            ),
            GoRoute(
              path: '/admin/recruitment/job/:id',
              pageBuilder: (ctx, state) => _fadeOf(ctx, state,
                  JobDetailScreen(jobId: state.pathParameters['id'])),
            ),
            GoRoute(
              path: '/admin/settings/role/:id',
              pageBuilder: (ctx, state) => _fadeOf(ctx, state,
                  RoleDetailScreen(roleId: state.pathParameters['id'])),
            ),
          ],
        ),

        ShellRoute(
          builder: (context, state, child) => EmployeeShell(child: child),
          routes: [
            GoRoute(path: '/employee',               pageBuilder: _fade(const EmployeeHomeScreen())),
            GoRoute(path: '/employee/attendance',    pageBuilder: _fade(const EmployeeAttendanceScreen())),
            GoRoute(path: '/employee/leave',         pageBuilder: _fade(const EmployeeLeaveScreen())),
            GoRoute(path: '/employee/leave/request', pageBuilder: _fade(const LeaveRequestScreen())),
            GoRoute(path: '/employee/payslip',       pageBuilder: _fade(const EmployeePayslipScreen())),
            GoRoute(path: '/employee/profile',       pageBuilder: _fade(const EmployeeProfileScreen())),
            GoRoute(path: '/employee/notifications', pageBuilder: _fade(const EmployeeNotificationsScreen())),
          ],
        ),
      ],
    );

class AdminShell extends StatelessWidget {
  const AdminShell({super.key, required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) =>
      PlatformHelper.isAdminApp ? AdminLayout(child: child) : child;
}

class EmployeeShell extends StatelessWidget {
  const EmployeeShell({super.key, required this.child});
  final Widget child;

  static const _paths = [
    '/employee',
    '/employee/attendance',
    '/employee/leave',
    '/employee/payslip',
    '/employee/notifications',
    '/employee/profile',
  ];

  int _selectedIndex(BuildContext context) {
    final path = GoRouterState.of(context).uri.path;
    for (var i = _paths.length - 1; i > 0; i--) {
      if (path.startsWith(_paths[i])) return i;
    }
    return 0;
  }

  @override
  Widget build(BuildContext context) {
    if (!PlatformHelper.isEmployeeApp) return child;

    final l10n = AppStrings.of(context);

    return Scaffold(
      body: child,
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex(context),
        onDestinationSelected: (i) => context.go(_paths[i]),
        destinations: [
          NavigationDestination(icon: const Icon(Icons.home_outlined),        selectedIcon: const Icon(Icons.home),         label: l10n.employeeNavHome),
          NavigationDestination(icon: const Icon(Icons.access_time_outlined), selectedIcon: const Icon(Icons.access_time),  label: l10n.employeeNavAttendance),
          NavigationDestination(icon: const Icon(Icons.event_note_outlined),  selectedIcon: const Icon(Icons.event_note),   label: l10n.employeeNavLeave),
          NavigationDestination(icon: const Icon(Icons.receipt_long_outlined),selectedIcon: const Icon(Icons.receipt_long), label: l10n.employeeNavPayroll),
          NavigationDestination(icon: const Icon(Icons.notifications_outlined), selectedIcon: const Icon(Icons.notifications), label: l10n.employeeNavNotifications),
          NavigationDestination(icon: const Icon(Icons.person_outline),       selectedIcon: const Icon(Icons.person),       label: l10n.employeeNavProfile),
        ],
      ),
    );
  }
}
