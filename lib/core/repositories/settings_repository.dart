import 'dart:convert';

import '../api/api_client.dart';
import '../api/api_config.dart';
import '../api/api_result.dart';

class CompanySettings {
  CompanySettings({
    required this.id,
    required this.name,
    this.email,
    this.phone,
    this.address,
    this.wifiSsid,
    this.status,
  });

  final String id;
  final String name;
  final String? email;
  final String? phone;
  final String? address;
  final String? wifiSsid;
  final String? status;

  factory CompanySettings.fromJson(Map<String, dynamic> json) => CompanySettings(
        id: json['id']?.toString() ?? '',
        name: json['name']?.toString() ?? '',
        email: json['email']?.toString(),
        phone: json['phone']?.toString(),
        address: json['address']?.toString(),
        wifiSsid: json['wifi_ssid']?.toString(),
        status: json['status']?.toString(),
      );

  static CompanySettings get demo => CompanySettings(
        id: '1',
        name: 'شركة النموذج',
        email: 'info@company.com',
        phone: '+966 50 123 4567',
        address: 'الرياض، المملكة العربية السعودية',
        wifiSsid: '',
        status: 'active',
      );
}

class SettingsRepository {
  SettingsRepository._();
  static final instance = SettingsRepository._();

  Future<ApiResult<CompanySettings>> getSettings() async {
    if (!ApiConfig.useApi) return ApiSuccess(CompanySettings.demo);

    final res = await ApiClient.get('company');
    return switch (res) {
      ApiFailure(:final message, :final statusCode) =>
        ApiFailure(message, statusCode: statusCode),
      ApiSuccess(:final data) => () {
          try {
            final map = jsonDecode(data.body);
            final raw = map is Map<String, dynamic>
                ? (map['data'] as Map<String, dynamic>? ?? map)
                : map as Map<String, dynamic>;
            return ApiSuccess(CompanySettings.fromJson(raw));
          } catch (e) {
            return ApiFailure<CompanySettings>('Could not parse settings: $e');
          }
        }(),
    };
  }

  Future<ApiResult<CompanySettings>> saveSettings({
    String? name,
    String? email,
    String? phone,
    String? address,
    String? wifiSsid,
  }) async {
    if (!ApiConfig.useApi) return ApiSuccess(CompanySettings.demo);

    final body = <String, dynamic>{};
    if (name != null && name.isNotEmpty) body['name'] = name;
    if (email != null) body['email'] = email;
    if (phone != null) body['phone'] = phone;
    if (address != null) body['address'] = address;
    if (wifiSsid != null) body['wifi_ssid'] = wifiSsid;

    final res = await ApiClient.put('company', body: body);
    return switch (res) {
      ApiFailure(:final message, :final statusCode) =>
        ApiFailure(message, statusCode: statusCode),
      ApiSuccess(:final data) => () {
          try {
            final map = jsonDecode(data.body) as Map<String, dynamic>;
            final raw = map['data'] as Map<String, dynamic>? ?? map;
            return ApiSuccess(CompanySettings.fromJson(raw));
          } catch (e) {
            return ApiSuccess(CompanySettings.demo);
          }
        }(),
    };
  }
}
