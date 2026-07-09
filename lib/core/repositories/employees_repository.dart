import 'dart:convert';

import '../api/api_client.dart';
import '../api/api_config.dart';
import '../api/api_localized.dart';
import '../api/api_result.dart';

class EmployeeItem {
  EmployeeItem({
    required this.id,
    required this.name,
    required this.email,
    this.department,
    this.position,
    this.active = true,
    this.phone,
    this.insuranceType,
    this.insurancePolicyNumber,
    this.birthDate,
    this.hireDate,
    this.coverageStart,
    this.coverageEnd,
    this.baseSalary,
    this.allowances,
    this.deductions,
    this.appLoginEnabled,
  });

  final String id;
  final String name;
  final String email;
  final String? department;
  final String? position;
  final bool active;
  final String? phone;
  final String? insuranceType;
  final String? insurancePolicyNumber;
  final String? birthDate;
  final String? hireDate;
  final String? coverageStart;
  final String? coverageEnd;
  final String? baseSalary;
  final String? allowances;
  final String? deductions;
  /// من الـ API: `app_login_enabled` — هل يوجد حساب دخول للتطبيق (يُدار من الأدمن).
  final bool? appLoginEnabled;

  factory EmployeeItem.fromJson(Map<String, dynamic> json) {
    return EmployeeItem(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? json['full_name']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      department: json['department']?.toString(),
      position: json['position']?.toString() ?? json['job_title']?.toString(),
      active: json['is_active'] != false,
      phone: json['phone']?.toString(),
      insuranceType: json['insurance_type']?.toString(),
      insurancePolicyNumber: json['insurance_policy_number']?.toString(),
      birthDate: json['birth_date']?.toString(),
      hireDate: json['hire_date']?.toString(),
      coverageStart: json['coverage_start']?.toString(),
      coverageEnd: json['coverage_end']?.toString(),
      baseSalary: json['base_salary']?.toString(),
      allowances: json['allowances']?.toString(),
      deductions: json['deductions']?.toString(),
      appLoginEnabled: json['app_login_enabled'] == true ? true : (json['app_login_enabled'] == false ? false : null),
    );
  }
}

class PagedResult<T> {
  const PagedResult({
    required this.items,
    required this.currentPage,
    required this.lastPage,
    required this.total,
  });

  final List<T> items;
  final int currentPage;
  final int lastPage;
  final int total;

  bool get hasMore => currentPage < lastPage;
}

class EmployeesRepository {
  static const List<Map<String, String>> _demoEmployees = [
    {
      'id': '1',
      'name': 'Mohamed Ahmed',
      'email': 'emp01@demo.com',
      'department': 'Sales',
      'position': 'Sales coordinator',
      'phone': '+966501000001',
      'hire_date': '2024-01-01',
      'base_salary': '6000',
      'allowances': '800',
      'deductions': '200',
    },
    {
      'id': '2',
      'name': 'Sara Ali',
      'email': 'emp02@demo.com',
      'department': 'Finance',
      'position': 'Accountant',
      'phone': '+966501000002',
      'hire_date': '2024-02-01',
      'base_salary': '5200',
      'allowances': '600',
      'deductions': '180',
    },
    {
      'id': '3',
      'name': 'Khalid Hassan',
      'email': 'emp03@demo.com',
      'department': 'IT',
      'position': 'Developer',
      'phone': '+966501000003',
      'hire_date': '2023-11-01',
      'base_salary': '7200',
      'allowances': '1000',
      'deductions': '250',
    },
  ];

  /// إرجاع قائمة مرقّمة مع دعم البحث والفلترة
  static Future<ApiResult<PagedResult<EmployeeItem>>> getEmployeesPaged({
    int page = 1,
    int perPage = 20,
    String? search,
    String? department,
  }) async {
    await ApiConfig.load();
    if (ApiConfig.useApi && ApiConfig.baseUrl != null && ApiConfig.baseUrl!.isNotEmpty) {
      final params = StringBuffer('employees?page=$page&per_page=$perPage');
      if (search != null && search.isNotEmpty) params.write('&search=${Uri.encodeComponent(search)}');
      if (department != null && department.isNotEmpty) params.write('&department=${Uri.encodeComponent(department)}');

      final res = await ApiClient.get(params.toString());
      if (res is ApiFailure<dynamic>) {
        return ApiFailure((res as ApiFailure<dynamic>).message, statusCode: (res as ApiFailure<dynamic>).statusCode);
      }
      try {
        final decoded = jsonDecode((res as ApiSuccess).data.body) as Map<String, dynamic>;
        final list = decoded['data'] as List<dynamic>? ?? [];
        final meta = decoded['meta'] as Map<String, dynamic>? ?? {};
        final items = list.map((e) => EmployeeItem.fromJson(e as Map<String, dynamic>)).toList();
        return ApiSuccess(PagedResult(
          items: items,
          currentPage: (meta['current_page'] as num?)?.toInt() ?? 1,
          lastPage: (meta['last_page'] as num?)?.toInt() ?? 1,
          total: (meta['total'] as num?)?.toInt() ?? items.length,
        ));
      } catch (e) {
        return ApiFailure(ApiLocalized.strings.apiErrorEmployeesList(e.toString()));
      }
    }
    final allItems = _demoEmployees.map(EmployeeItem.fromJson).toList();
    final filtered = allItems.where((e) {
      final bySearch = search == null ||
          search.isEmpty ||
          e.name.toLowerCase().contains(search.toLowerCase()) ||
          e.email.toLowerCase().contains(search.toLowerCase());
      final byDepartment = department == null ||
          department.isEmpty ||
          (e.department ?? '').toLowerCase() == department.toLowerCase();
      return bySearch && byDepartment;
    }).toList();
    final start = (page - 1) * perPage;
    final end = (start + perPage).clamp(0, filtered.length);
    final pageItems =
        start >= filtered.length ? <EmployeeItem>[] : filtered.sublist(start, end);
    return ApiSuccess(
      PagedResult(
        items: pageItems,
        currentPage: page,
        lastPage: (filtered.length / perPage).ceil().clamp(1, 9999),
        total: filtered.length,
      ),
    );
  }

  /// للتوافق مع الأجزاء التي تحتاج القائمة الكاملة (employee form, etc.)
  static Future<ApiResult<List<EmployeeItem>>> getEmployees() async {
    final res = await getEmployeesPaged(page: 1, perPage: 100);
    return switch (res) {
      ApiFailure(:final message, :final statusCode) => ApiFailure(message, statusCode: statusCode),
      ApiSuccess(:final data) => ApiSuccess(data.items),
    };
  }

  static Future<ApiResult<EmployeeItem>> getEmployee(String id) async {
    await ApiConfig.load();
    if (ApiConfig.useApi && ApiConfig.baseUrl != null && ApiConfig.baseUrl!.isNotEmpty) {
      final res = await ApiClient.get('employees/$id');
      if (res is ApiFailure<dynamic>) return ApiFailure((res as ApiFailure<dynamic>).message, statusCode: (res as ApiFailure<dynamic>).statusCode);
      try {
        final map = jsonDecode((res as ApiSuccess).data.body) as Map<String, dynamic>?;
        if (map != null) {
          final data = map['data'] as Map<String, dynamic>? ?? map;
          return ApiSuccess(EmployeeItem.fromJson(data));
        }
      } catch (e) {
        return ApiFailure(ApiLocalized.strings.apiErrorEmployeeDetail(e.toString()));
      }
    }
    for (final item in _demoEmployees.map(EmployeeItem.fromJson)) {
      if (item.id == id) return ApiSuccess(item);
    }
    return ApiFailure(ApiLocalized.strings.apiErrorEmployeeDetail('Employee not found'));
  }

  /// GET `/employees/me` — الموظف يحمّل بياناته الذاتية من نفس الـ Company.
  static Future<ApiResult<EmployeeItem>> getMyEmployee() async {
    await ApiConfig.load();
    if (ApiConfig.useApi && ApiConfig.baseUrl != null && ApiConfig.baseUrl!.isNotEmpty) {
      final res = await ApiClient.get('employees/me');
      if (res is ApiFailure<dynamic>) {
        return ApiFailure(
          (res as ApiFailure<dynamic>).message,
          statusCode: (res as ApiFailure<dynamic>).statusCode,
        );
      }
      try {
        final map = jsonDecode((res as ApiSuccess).data.body) as Map<String, dynamic>?;
        if (map != null) {
          final data = map['data'] as Map<String, dynamic>? ?? map;
          return ApiSuccess(EmployeeItem.fromJson(data));
        }
      } catch (e) {
        return ApiFailure(ApiLocalized.strings.apiErrorEmployeeDetail(e.toString()));
      }
    }
    return ApiSuccess(EmployeeItem.fromJson(_demoEmployees.first));
  }

  static Future<ApiResult<void>> createEmployee(Map<String, dynamic> data) async {
    await ApiConfig.load();
    if (ApiConfig.useApi && ApiConfig.baseUrl != null && ApiConfig.baseUrl!.isNotEmpty) {
      final res = await ApiClient.post('employees', body: data);
      if (res is ApiFailure<dynamic>) return ApiFailure((res as ApiFailure<dynamic>).message, statusCode: (res as ApiFailure<dynamic>).statusCode);
      return const ApiSuccess(null);
    }
    return const ApiSuccess(null);
  }

  static Future<ApiResult<void>> updateEmployee(String id, Map<String, dynamic> data) async {
    await ApiConfig.load();
    if (ApiConfig.useApi && ApiConfig.baseUrl != null && ApiConfig.baseUrl!.isNotEmpty) {
      final res = await ApiClient.put('employees/$id', body: data);
      if (res is ApiFailure<dynamic>) return ApiFailure((res as ApiFailure<dynamic>).message, statusCode: (res as ApiFailure<dynamic>).statusCode);
      return const ApiSuccess(null);
    }
    return const ApiSuccess(null);
  }

  static Future<ApiResult<void>> deleteEmployee(String id) async {
    await ApiConfig.load();
    if (ApiConfig.useApi && ApiConfig.baseUrl != null && ApiConfig.baseUrl!.isNotEmpty) {
      final res = await ApiClient.delete('employees/$id');
      if (res is ApiFailure<dynamic>) {
        return ApiFailure(
          (res as ApiFailure<dynamic>).message,
          statusCode: (res as ApiFailure<dynamic>).statusCode,
        );
      }
      return const ApiSuccess(null);
    }
    return const ApiSuccess(null);
  }

  /// تمكين/تعطيل دخول التطبيق أو تغيير كلمة المرور — POST `employees/{id}/app-access` (Sanctum، أدمن).
  static Future<ApiResult<void>> setEmployeeAppAccess(
    String id, {
    required bool enabled,
    String? password,
    String? passwordConfirmation,
  }) async {
    await ApiConfig.load();
    final l10n = ApiLocalized.strings;
    if (ApiConfig.useApi && ApiConfig.baseUrl != null && ApiConfig.baseUrl!.isNotEmpty) {
      final body = <String, dynamic>{'enabled': enabled};
      if (enabled) {
        if (password == null ||
            passwordConfirmation == null ||
            password.isEmpty ||
            password != passwordConfirmation) {
          return ApiFailure(l10n.appAccessPasswordMismatch);
        }
        body['password'] = password;
        body['password_confirmation'] = passwordConfirmation;
      }
      final res = await ApiClient.post('employees/$id/app-access', body: body);
      if (res is ApiFailure<dynamic>) {
        return ApiFailure(
          (res as ApiFailure<dynamic>).message,
          statusCode: (res as ApiFailure<dynamic>).statusCode,
        );
      }
      return const ApiSuccess(null);
    }
    return const ApiSuccess(null);
  }
}
