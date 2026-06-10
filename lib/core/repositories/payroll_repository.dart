import 'dart:convert';

import '../api/api_client.dart';
import '../api/api_config.dart';
import '../api/api_localized.dart';
import '../api/api_result.dart';
import 'employees_repository.dart' show PagedResult;

class PayslipItem {
  PayslipItem({
    required this.employeeId,
    required this.employeeName,
    required this.baseSalary,
    required this.allowances,
    required this.deductions,
    required this.netSalary,
    required this.status,
  });

  final String employeeId;
  final String employeeName;
  final String baseSalary;
  final String allowances;
  final String deductions;
  final String netSalary;
  final String status;
}

class PayrollRepository {
  static PayslipItem _fromMap(Map<String, dynamic> m) => PayslipItem(
        employeeId: m['employee_id']?.toString() ?? m['id']?.toString() ?? '',
        employeeName: m['employee_name']?.toString() ?? m['name']?.toString() ?? '',
        baseSalary: m['base_salary']?.toString() ?? m['salary']?.toString() ?? '0',
        allowances: m['allowances']?.toString() ?? '0',
        deductions: m['deductions']?.toString() ?? '0',
        netSalary: m['net_salary']?.toString() ?? m['net']?.toString() ?? '0',
        status: m['status']?.toString() ?? 'processed',
      );

  static Future<ApiResult<PagedResult<PayslipItem>>> getPayrollPaged(
    String month, {
    int page = 1,
    int perPage = 20,
  }) async {
    await ApiConfig.load();
    if (ApiConfig.useApi && ApiConfig.baseUrl != null && ApiConfig.baseUrl!.isNotEmpty) {
      final res = await ApiClient.get('payroll?month=$month&page=$page&per_page=$perPage');
      if (res is ApiFailure<dynamic>) {
        return ApiFailure((res as ApiFailure<dynamic>).message, statusCode: (res as ApiFailure<dynamic>).statusCode);
      }
      try {
        final decoded = jsonDecode((res as ApiSuccess).data.body) as Map<String, dynamic>;
        final list = decoded['data'] as List<dynamic>? ?? [];
        final meta = decoded['meta'] as Map<String, dynamic>? ?? {};
        final items = list.map((e) => _fromMap(e as Map<String, dynamic>)).toList();
        return ApiSuccess(PagedResult(
          items: items,
          currentPage: (meta['current_page'] as num?)?.toInt() ?? 1,
          lastPage: (meta['last_page'] as num?)?.toInt() ?? 1,
          total: (meta['total'] as num?)?.toInt() ?? items.length,
        ));
      } catch (e) {
        return ApiFailure(ApiLocalized.strings.apiErrorPayroll(e.toString()));
      }
    }
    return ApiFailure(ApiLocalized.strings.apiErrorPayroll('API disabled'));
  }

  /// للتوافق مع الشاشات التي تحتاج القائمة كاملة (payslip detail)
  static Future<ApiResult<List<PayslipItem>>> getPayroll(String month) async {
    final res = await getPayrollPaged(month, page: 1, perPage: 100);
    return switch (res) {
      ApiFailure(:final message, :final statusCode) => ApiFailure(message, statusCode: statusCode),
      ApiSuccess(:final data) => ApiSuccess(data.items),
    };
  }

  static Future<ApiResult<void>> generatePayroll(String month) async {
    await ApiConfig.load();
    if (ApiConfig.useApi && ApiConfig.baseUrl != null && ApiConfig.baseUrl!.isNotEmpty) {
      final res = await ApiClient.post('payroll/generate', body: {'month': month});
      if (res is ApiFailure<dynamic>) {
        return ApiFailure(
          (res as ApiFailure<dynamic>).message,
          statusCode: (res as ApiFailure<dynamic>).statusCode,
        );
      }
      return const ApiSuccess(null);
    }
    return ApiFailure(ApiLocalized.strings.apiErrorPayroll('API disabled'));
  }
}
