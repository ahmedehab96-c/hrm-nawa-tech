import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../api/api_config.dart';
import '../auth/auth_session.dart';
import '../../features/employee/auth/employee_login_screen.dart';
import '../../features/employee/auth/employee_forgot_password_screen.dart';
import '../../features/employee/auth/employee_reset_password_screen.dart';
import '../../features/employee/auth/employee_verify_email_screen.dart';
import '../../features/employee/home/employee_home_screen.dart';
import '../../features/employee/attendance/employee_attendance_screen.dart';
import '../../features/employee/leave/employee_leave_screen.dart';
import '../../features/employee/leave/leave_request_screen.dart';
import '../../features/employee/payslip/employee_payslip_screen.dart';
import '../../features/employee/profile/employee_profile_screen.dart';
import '../../features/employee/notifications/employee_notifications_screen.dart';
import '../../features/employee/shell/employee_shell.dart';

final _rootKey = GlobalKey<NavigatorState>();

Page<void> Function(BuildContext, GoRouterState) _fade(Widget child) =>
    (ctx, state) => _fadeOf(ctx, state, child);

CustomTransitionPage<void> _fadeOf(
  BuildContext ctx,
  GoRouterState state,
  Widget child,
) =>
    CustomTransitionPage(
      key: state.pageKey,
      child: child,
      transitionDuration: const Duration(milliseconds: 220),
      transitionsBuilder: (context, animation, secondaryAnimation, child) =>
          FadeTransition(opacity: animation, child: child),
    );

String? _authRedirect(BuildContext context, GoRouterState state) {
  final path = state.uri.path;
  final session = AuthSession.instance;

  if (path == '/login' ||
      path == '/forgot-password' ||
      path == '/reset-password' ||
      path == '/verify-email') {
    final hasVerifyLink = path == '/verify-email' &&
        (state.uri.queryParameters['id']?.isNotEmpty ?? false) &&
        (state.uri.queryParameters['hash']?.isNotEmpty ?? false);
    if (hasVerifyLink) {
      return null;
    }
    if (ApiConfig.useApi && session.hasSession && session.emailVerified) {
      return '/employee';
    }
    return null;
  }

  if (!ApiConfig.useApi) return null;
  if (!session.hasSession) return '/login';
  if (!session.emailVerified && path != '/verify-email') return '/verify-email';
  return null;
}

GoRouter createAppRouter() => GoRouter(
      navigatorKey: _rootKey,
      initialLocation: '/employee',
      refreshListenable: AuthSession.instance,
      redirect: _authRedirect,
      routes: [
        GoRoute(path: '/', redirect: (context, state) => '/employee'),
        GoRoute(
          path: '/login',
          pageBuilder: _fade(const EmployeeLoginScreen()),
        ),
        GoRoute(
          path: '/forgot-password',
          pageBuilder: _fade(const EmployeeForgotPasswordScreen()),
        ),
        GoRoute(
          path: '/reset-password',
          pageBuilder: (context, state) => _fadeOf(
            context,
            state,
            EmployeeResetPasswordScreen(
              token: state.uri.queryParameters['token'] ?? '',
              email: state.uri.queryParameters['email'] ?? '',
            ),
          ),
        ),
        GoRoute(
          path: '/verify-email',
          pageBuilder: (context, state) => _fadeOf(
            context,
            state,
            EmployeeVerifyEmailScreen(
              verifyId: state.uri.queryParameters['id'],
              verifyHash: state.uri.queryParameters['hash'],
              verifyExpires: state.uri.queryParameters['expires'],
              verifySignature: state.uri.queryParameters['signature'],
            ),
          ),
        ),
        ShellRoute(
          builder: (context, state, child) => EmployeeShell(child: child),
          routes: [
            GoRoute(
              path: '/employee',
              pageBuilder: _fade(const EmployeeHomeScreen()),
            ),
            GoRoute(
              path: '/employee/attendance',
              pageBuilder: _fade(const EmployeeAttendanceScreen()),
            ),
            GoRoute(
              path: '/employee/leave',
              pageBuilder: _fade(const EmployeeLeaveScreen()),
            ),
            GoRoute(
              path: '/employee/leave/request',
              pageBuilder: _fade(const LeaveRequestScreen()),
            ),
            GoRoute(
              path: '/employee/payslip',
              pageBuilder: _fade(const EmployeePayslipScreen()),
            ),
            GoRoute(
              path: '/employee/profile',
              pageBuilder: _fade(const EmployeeProfileScreen()),
            ),
            GoRoute(
              path: '/employee/notifications',
              pageBuilder: _fade(const EmployeeNotificationsScreen()),
            ),
          ],
        ),
      ],
    );
