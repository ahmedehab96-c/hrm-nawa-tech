import 'dart:convert';

import '../api/api_client.dart';
import '../api/api_config.dart';
import '../api/api_localized.dart';
import '../api/api_result.dart';

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
    if (ApiConfig.useApi && ApiConfig.baseUrl != null && ApiConfig.baseUrl!.isNotEmpty) {
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

  /// تعديل سجل حضور موجود (للأدمن فقط)
  static Future<ApiResult<void>> updateRecord({
    required String recordId,
    String? checkIn,
    String? checkOut,
    String? status,
  }) async {
    await ApiConfig.load();
    if (!ApiConfig.useApi) return const ApiSuccess(null);
    final body = <String, dynamic>{};
    if (checkIn  != null) body['check_in']  = checkIn;
    if (checkOut != null) body['check_out'] = checkOut;
    if (status   != null) body['status']    = status;
    final res = await ApiClient.put('attendance/$recordId', body: body);
    return switch (res) {
      ApiFailure(:final message, :final statusCode) => ApiFailure(message, statusCode: statusCode),
      ApiSuccess() => const ApiSuccess(null),
    };
  }

  /// إنشاء أو تحديث سجل حضور (للأدمن — لتسجيل غائب)
  static Future<ApiResult<void>> upsertRecord({
    required String employeeId,
    required String date,
    String? checkIn,
    String? checkOut,
    required String status,
  }) async {
    await ApiConfig.load();
    if (!ApiConfig.useApi) return const ApiSuccess(null);
    final body = <String, dynamic>{
      'employee_id': int.tryParse(employeeId) ?? employeeId,
      'date': date,
      'status': status,
      'check_in':  ?checkIn,
      'check_out': ?checkOut,
    };
    final res = await ApiClient.post('attendance', body: body);
    return switch (res) {
      ApiFailure(:final message, :final statusCode) => ApiFailure(message, statusCode: statusCode),
      ApiSuccess() => const ApiSuccess(null),
    };
  }

  /// تسجيل خروج الحضور (للموظف) - يستدعي API عند تفعيل الخادم
  static Future<ApiResult<void>> recordCheckOut() async {
    await ApiConfig.load();
    if (ApiConfig.useApi && ApiConfig.baseUrl != null && ApiConfig.baseUrl!.isNotEmpty) {
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
    if (ApiConfig.useApi && ApiConfig.baseUrl != null && ApiConfig.baseUrl!.isNotEmpty) {
      final res = await ApiClient.post('attendance/check-in');
      if (res is ApiFailure<dynamic>) {
        return ApiFailure((res as ApiFailure<dynamic>).message, statusCode: (res as ApiFailure<dynamic>).statusCode);
      }
      return const ApiSuccess(null);
    }
    return const ApiSuccess(null);
  }
}
