import 'dart:convert';

import 'package:hrm_saas/core/api/api_client.dart';
import 'package:hrm_saas/core/api/api_config.dart';
import 'package:hrm_saas/core/api/api_enabled.dart';
import 'package:hrm_saas/core/api/api_localized.dart';
import 'package:hrm_saas/core/api/api_result.dart';
import 'package:hrm_saas/core/api/paged_result.dart';

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
  static List<PayslipItem> _demoPayroll(String month) => [
        PayslipItem(
          employeeId: '1',
          employeeName: 'Mohamed Ahmed',
          baseSalary: '6000',
          allowances: '800',
          deductions: '200',
          netSalary: '6600',
          status: 'processed',
        ),
        PayslipItem(
          employeeId: '2',
          employeeName: 'Sara Ali',
          baseSalary: '5200',
          allowances: '600',
          deductions: '180',
          netSalary: '5620',
          status: 'processed',
        ),
        PayslipItem(
          employeeId: '3',
          employeeName: 'Khalid Hassan',
          baseSalary: '7200',
          allowances: '1000',
          deductions: '250',
          netSalary: '7950',
          status: 'processed',
        ),
      ];

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
    if (isApiEnabled) {
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
    final items = _demoPayroll(month);
    final start = (page - 1) * perPage;
    final end = (start + perPage).clamp(0, items.length);
    final pageItems = start >= items.length ? <PayslipItem>[] : items.sublist(start, end);
    return ApiSuccess(
      PagedResult(
        items: pageItems,
        currentPage: page,
        lastPage: (items.length / perPage).ceil().clamp(1, 9999),
        total: items.length,
      ),
    );
  }

  /// للتوافق مع الشاشات التي تحتاج القائمة كاملة (payslip detail)
  static Future<ApiResult<List<PayslipItem>>> getPayroll(String month) async {
    final res = await getPayrollPaged(month, page: 1, perPage: 100);
    return switch (res) {
      ApiFailure(:final message, :final statusCode) => ApiFailure(message, statusCode: statusCode),
      ApiSuccess(:final data) => ApiSuccess(data.items),
    };
  }
}
