import 'dart:convert';

import 'package:hrm_saas/core/api/api_client.dart';
import 'package:hrm_saas/core/api/api_config.dart';
import 'package:hrm_saas/core/api/api_enabled.dart';
import 'package:hrm_saas/core/api/api_localized.dart';
import 'package:hrm_saas/core/api/api_result.dart';

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
  final bool? appLoginEnabled;

  factory EmployeeItem.fromJson(Map<String, dynamic> json) {
    return EmployeeItem(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      department: json['department']?.toString(),
      position: json['position']?.toString(),
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
      appLoginEnabled: json['app_login_enabled'] == true
          ? true
          : (json['app_login_enabled'] == false ? false : null),
    );
  }
}

class EmployeesRepository {
  static const Map<String, String> _demoEmployee = {
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
  };

  /// GET `/employees/me` — employee self profile.
  static Future<ApiResult<EmployeeItem>> getMyEmployee() async {
    await ApiConfig.load();
    if (isApiEnabled) {
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
    return ApiSuccess(EmployeeItem.fromJson(_demoEmployee));
  }
}
