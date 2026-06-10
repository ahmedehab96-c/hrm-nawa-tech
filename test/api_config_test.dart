import 'package:flutter_test/flutter_test.dart';
import 'package:hrm_saas/core/api/api_config.dart';

void main() {
  group('ApiConfig.validateBaseUrl', () {
    test('allows empty or null', () {
      expect(ApiConfig.validateBaseUrl(null), isNull);
      expect(ApiConfig.validateBaseUrl(''), isNull);
      expect(ApiConfig.validateBaseUrl('   '), isNull);
    });

    test('allows https', () {
      expect(ApiConfig.validateBaseUrl('https://api.example.com/api'), isNull);
    });

    test('allows http on localhost and dev hosts', () {
      expect(ApiConfig.validateBaseUrl('http://localhost:8000/api'), isNull);
      expect(ApiConfig.validateBaseUrl('http://127.0.0.1/api'), isNull);
      expect(ApiConfig.validateBaseUrl('http://10.0.2.2/api'), isNull);
      expect(ApiConfig.validateBaseUrl('http://myapp.local/api'), isNull);
    });

    test('rejects http on public hosts', () {
      expect(ApiConfig.validateBaseUrl('http://api.example.com/api'), 'needs_https');
    });

    test('rejects invalid URLs', () {
      expect(ApiConfig.validateBaseUrl('not-a-url'), 'invalid');
      expect(ApiConfig.validateBaseUrl('ftp://x.com'), 'invalid');
    });
  });
}
