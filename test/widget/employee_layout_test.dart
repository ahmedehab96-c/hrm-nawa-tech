import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hrm_saas/core/widgets/responsive_helper.dart';
import 'package:hrm_saas/core/widgets/responsive_page.dart';
import 'package:hrm_saas/features/employee/attendance/employee_attendance_screen.dart';
import 'package:hrm_saas/features/employee/auth/employee_forgot_password_screen.dart';
import 'package:hrm_saas/features/employee/auth/employee_login_screen.dart';
import 'package:hrm_saas/features/employee/home/employee_home_screen.dart';
import 'package:hrm_saas/features/employee/leave/employee_leave_screen.dart';
import 'package:hrm_saas/features/employee/leave/leave_request_screen.dart';
import 'package:hrm_saas/features/employee/notifications/employee_notifications_screen.dart';
import 'package:hrm_saas/features/employee/payslip/employee_payslip_screen.dart';
import 'package:hrm_saas/features/employee/profile/employee_profile_screen.dart';

import '../helpers/layout_harness.dart';

void main() {
  group('responsive core widgets', () {
    testWidgets('LabeledValueRow on narrow Arabic stress', (tester) async {
      await pumpEmployeeScreen(
        tester,
        variant: narrowArStress,
        child: const Scaffold(
          body: ResponsivePage(
            child: Column(
              children: [
                LabeledValueRow(
                  label: 'الراتب الأساسي الطويل جداً للاختبار',
                  value: '12,345.67 SAR',
                ),
                LabeledValueRow(
                  label: 'البدلات',
                  value: '999,999.00',
                ),
              ],
            ),
          ),
        ),
      );
    });

    testWidgets('ResponsiveHelper breakpoints', (tester) async {
      late ResponsiveHelper phone;
      late ResponsiveHelper tablet;
      late ResponsiveHelper desktop;

      await pumpEmployeeScreen(
        tester,
        variant: phoneAr,
        child: Builder(
          builder: (context) {
            phone = ResponsiveHelper.of(context);
            return const SizedBox();
          },
        ),
      );
      expect(phone.isMobile, isTrue);
      expect(phone.navLayout, NavLayout.bottomBar);

      await pumpEmployeeScreen(
        tester,
        variant: tabletEn,
        child: Builder(
          builder: (context) {
            tablet = ResponsiveHelper.of(context);
            return const SizedBox();
          },
        ),
      );
      expect(tablet.isTablet, isTrue);
      expect(tablet.navLayout, NavLayout.navigationRail);

      await pumpEmployeeScreen(
        tester,
        variant: desktopEn,
        child: Builder(
          builder: (context) {
            desktop = ResponsiveHelper.of(context);
            return const SizedBox();
          },
        ),
      );
      expect(desktop.isDesktop, isTrue);
      expect(desktop.navLayout, NavLayout.sideNav);
    });
  });

  group('employee screens layout matrix', () {
    final screens = <String, Widget Function()>{
      'home': () => const EmployeeHomeScreen(),
      'attendance': () => const EmployeeAttendanceScreen(),
      'leave': () => const EmployeeLeaveScreen(),
      'leave_request': () => const LeaveRequestScreen(),
      'payslip': () => const EmployeePayslipScreen(),
      'notifications': () => const EmployeeNotificationsScreen(),
      'profile': () => const EmployeeProfileScreen(),
      'login': () => const EmployeeLoginScreen(),
      'forgot_password': () => const EmployeeForgotPasswordScreen(),
    };

    final variants = [
      narrowAr,
      narrowArStress,
      phoneAr,
      landscapeAr,
      tabletEn,
      desktopEn,
    ];

    for (final entry in screens.entries) {
      for (final variant in variants) {
        testWidgets('${entry.key} ${variant.name}', (tester) async {
          await pumpEmployeeScreen(
            tester,
            variant: variant,
            wrapShell: entry.key != 'login' && entry.key != 'forgot_password',
            child: entry.value(),
          );
        });
      }
    }
  });

  group('keyboard form layouts', () {
    testWidgets('login with keyboard insets', (tester) async {
      await pumpEmployeeScreen(
        tester,
        variant: keyboardAr,
        child: const EmployeeLoginScreen(),
      );
    });

    testWidgets('leave request with keyboard insets', (tester) async {
      await pumpEmployeeScreen(
        tester,
        variant: keyboardAr,
        child: const LeaveRequestScreen(),
      );
    });

    testWidgets('profile with keyboard insets', (tester) async {
      await pumpEmployeeScreen(
        tester,
        variant: keyboardAr,
        child: const EmployeeProfileScreen(),
      );
    });

    testWidgets('forgot password with keyboard insets', (tester) async {
      await pumpEmployeeScreen(
        tester,
        variant: keyboardAr,
        child: const EmployeeForgotPasswordScreen(),
      );
    });
  });
}
