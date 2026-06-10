import 'package:flutter_test/flutter_test.dart';
import 'package:hrm_saas/core/repositories/settings_repository.dart';
import 'package:hrm_saas/core/api/api_result.dart';

void main() {
  group('CompanySettings.fromJson', () {
    test('parses all fields correctly', () {
      final json = {
        'id': 1,
        'name': 'Test Corp',
        'email': 'info@corp.com',
        'phone': '+966501234567',
        'address': 'Riyadh',
        'wifi_ssid': 'Corp_WiFi',
        'status': 'active',
      };
      final s = CompanySettings.fromJson(json);
      expect(s.id, '1');
      expect(s.name, 'Test Corp');
      expect(s.email, 'info@corp.com');
      expect(s.wifiSsid, 'Corp_WiFi');
      expect(s.status, 'active');
    });

    test('handles null optional fields', () {
      final s = CompanySettings.fromJson({'id': 2, 'name': 'Min Corp'});
      expect(s.email, isNull);
      expect(s.phone, isNull);
      expect(s.address, isNull);
      expect(s.wifiSsid, isNull);
    });

    test('id is always converted to string', () {
      final s = CompanySettings.fromJson({'id': 99, 'name': 'X'});
      expect(s.id, '99');
    });
  });

  group('CompanySettings.demo', () {
    test('demo has required fields', () {
      final demo = CompanySettings.demo;
      expect(demo.id, isNotEmpty);
      expect(demo.name, isNotEmpty);
      expect(demo.status, 'active');
    });
  });

  group('SettingsRepository demo mode', () {
    test('getSettings returns demo when API disabled', () async {
      final result = await SettingsRepository.instance.getSettings();
      expect(result, isA<ApiSuccess<CompanySettings>>());
      final s = (result as ApiSuccess<CompanySettings>).data;
      expect(s.name, isNotEmpty);
    });

    test('saveSettings returns demo when API disabled', () async {
      final result = await SettingsRepository.instance.saveSettings(name: 'New Name');
      expect(result, isA<ApiSuccess<CompanySettings>>());
    });
  });
}
