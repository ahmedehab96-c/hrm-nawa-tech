import 'package:flutter/material.dart';
import 'package:hrm_saas/core/api/api_result.dart';
import 'package:hrm_saas/core/services/wifi_attendance_service.dart';
import 'package:hrm_saas/core/theme/app_theme.dart';
import 'package:hrm_saas/core/utils/attendance_gate.dart';
import 'package:hrm_saas/features/employee/attendance/data/attendance_repository.dart';
import 'package:hrm_saas/l10n/app_strings.dart';

/// Shared check-in / check-out flow used by Home and Attendance screens.
abstract final class AttendanceActions {
  static Future<void> checkIn(BuildContext context) async {
    final l10n = AppStrings.of(context);
    if (await requireCompanyWifiForAttendance()) {
      final result = await WifiAttendanceService.canRecordAttendance();
      if (!result.success) {
        if (!context.mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(result.message ?? l10n.wifiOffCompany),
          backgroundColor: AppColors.error,
        ));
        return;
      }
    }
    final res = await AttendanceRepository.recordCheckIn();
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(
        res is ApiSuccess<void>
            ? l10n.checkInRecorded
            : (res as ApiFailure<void>).message,
      ),
      backgroundColor:
          res is ApiSuccess<void> ? AppColors.success : AppColors.error,
    ));
  }

  static Future<void> checkOut(BuildContext context) async {
    final l10n = AppStrings.of(context);
    if (await requireCompanyWifiForAttendance()) {
      final result = await WifiAttendanceService.canRecordAttendance();
      if (!result.success) {
        if (!context.mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(result.message ?? l10n.wifiOffCompany),
          backgroundColor: AppColors.error,
        ));
        return;
      }
    }
    final res = await AttendanceRepository.recordCheckOut();
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(
        res is ApiSuccess<void>
            ? l10n.formSavedSuccess
            : (res as ApiFailure<void>).message,
      ),
      backgroundColor:
          res is ApiSuccess<void> ? AppColors.success : AppColors.error,
    ));
  }
}
