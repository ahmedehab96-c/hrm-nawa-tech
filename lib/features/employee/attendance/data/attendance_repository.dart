import 'dart:convert';

import 'package:hrm_saas/core/api/api_client.dart';
import 'package:hrm_saas/core/api/api_config.dart';
import 'package:hrm_saas/core/api/api_enabled.dart';
import 'package:hrm_saas/core/api/api_localized.dart';
import 'package:hrm_saas/core/api/api_result.dart';

class AttendanceRecord {
  AttendanceRecord({
    this.id,
    required this.employeeId,
    required this.employeeName,
    this.checkIn,
    this.checkOut,
    this.status = 'present',
    this.workDate,
  });

  final String? id;
  final String employeeId;
  final String employeeName;
  final String? checkIn;
  final String? checkOut;
  final String status;
  final String? workDate;
}

class AttendanceRepository {
  static Future<ApiResult<List<AttendanceRecord>>> getDailyAttendance({String? date}) async {
    await ApiConfig.load();
    if (isApiEnabled) {
      final path = date != null ? 'attendance?date=$date' : 'attendance';
      final res = await ApiClient.get(path);
      if (res is ApiFailure<dynamic>) return ApiFailure((res as ApiFailure<dynamic>).message, statusCode: (res as ApiFailure<dynamic>).statusCode);
      try {
        final decoded = jsonDecode((res as ApiSuccess).data.body);
        List<dynamic> list = const [];
        if (decoded is List) {
          list = decoded;
        } else if (decoded is Map && decoded['data'] is List) {
          list = decoded['data'] as List;
        }
        final items = list.map((e) {
          final m = e as Map<String, dynamic>;
          return AttendanceRecord(
            id: m['id']?.toString(),
            employeeId: m['employee_id']?.toString() ?? m['id']?.toString() ?? '',
            employeeName: m['employee_name']?.toString() ?? m['name']?.toString() ?? '',
            checkIn: m['check_in']?.toString(),
            checkOut: m['check_out']?.toString(),
            status: m['status']?.toString() ?? 'present',
            workDate: m['work_date']?.toString(),
          );
        }).toList();
        return ApiSuccess(items);
      } catch (e) {
        return ApiFailure(ApiLocalized.strings.apiErrorAttendance(e.toString()));
      }
    }
    return ApiSuccess([
      AttendanceRecord(id: '1', employeeId: '1', employeeName: 'محمد أحمد', checkIn: '08:00', checkOut: '17:00', status: 'present'),
      AttendanceRecord(id: '2', employeeId: '2', employeeName: 'سارة علي',  checkIn: '08:15', checkOut: null,    status: 'late'),
      AttendanceRecord(id: '3', employeeId: '3', employeeName: 'خالد حسن', checkIn: '08:00', checkOut: '17:00', status: 'present'),
      AttendanceRecord(id: null, employeeId: '4', employeeName: 'نور محمد', checkIn: null,    checkOut: null,    status: 'absent'),
    ]);
  }

  /// تسجيل خروج الحضور (للموظف) - يستدعي API عند تفعيل الخادم
  static Future<ApiResult<void>> recordCheckOut() async {
    await ApiConfig.load();
    if (isApiEnabled) {
      final res = await ApiClient.post('attendance/check-out');
      if (res is ApiFailure<dynamic>) {
        return ApiFailure((res as ApiFailure<dynamic>).message, statusCode: (res as ApiFailure<dynamic>).statusCode);
      }
      return const ApiSuccess(null);
    }
    return const ApiSuccess(null);
  }

  /// تسجيل دخول الحضور (للموظف)
  static Future<ApiResult<void>> recordCheckIn() async {
    await ApiConfig.load();
    if (isApiEnabled) {
      final res = await ApiClient.post('attendance/check-in');
      if (res is ApiFailure<dynamic>) {
        return ApiFailure((res as ApiFailure<dynamic>).message, statusCode: (res as ApiFailure<dynamic>).statusCode);
      }
      return const ApiSuccess(null);
    }
    return const ApiSuccess(null);
  }
}
