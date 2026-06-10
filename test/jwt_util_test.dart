import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:hrm_saas/core/utils/jwt_util.dart';

void main() {
  group('isJwtExpired', () {
    test('returns false for non-JWT strings', () {
      expect(isJwtExpired('mock_token'), false);
      expect(isJwtExpired(''), false);
    });

    test('returns true when exp is in the past', () {
      final payload = jsonEncode({'exp': 1});
      final segment = base64Url.encode(utf8.encode(payload)).replaceAll('=', '');
      final token = 'eyJhbGciOiJub25lIn0.$segment.sig';
      expect(isJwtExpired(token), true);
    });

    test('returns false when exp is in the future', () {
      final future = DateTime.now().millisecondsSinceEpoch ~/ 1000 + 3600;
      final payload = jsonEncode({'exp': future});
      var segment = base64Url.encode(utf8.encode(payload));
      segment = segment.replaceAll('=', '');
      final token = 'header.$segment.sig';
      expect(isJwtExpired(token), false);
    });
  });
}
