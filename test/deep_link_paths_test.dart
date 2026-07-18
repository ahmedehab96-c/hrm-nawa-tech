import 'package:flutter_test/flutter_test.dart';
import 'package:hrm_saas/core/services/deep_link_paths.dart';

void main() {
  group('DeepLinkPaths', () {
    test('maps custom scheme reset link', () {
      final path = DeepLinkPaths.fromUri(
        Uri.parse('nawatechhrm://reset-password?token=abc123&email=user%40demo.com'),
      );

      expect(path, '/reset-password?token=abc123&email=user%40demo.com');
    });

    test('maps https reset link', () {
      final path = DeepLinkPaths.fromUri(
        Uri.parse('https://app.nawatech.com/reset-password?token=tok&email=emp%40demo.com'),
      );

      expect(path, '/reset-password?token=tok&email=emp%40demo.com');
    });

    test('maps custom scheme verify email link', () {
      final path = DeepLinkPaths.fromUri(
        Uri.parse(
          'nawatechhrm://verify-email?id=5&hash=abc&expires=123&signature=sig',
        ),
      );

      expect(
        path,
        '/verify-email?id=5&hash=abc&expires=123&signature=sig',
      );
    });

    test('maps https verify email API link', () {
      final path = DeepLinkPaths.fromUri(
        Uri.parse(
          'https://app.nawatech.com/api/email/verify/5/abc?expires=123&signature=sig',
        ),
      );

      expect(
        path,
        '/verify-email?id=5&hash=abc&expires=123&signature=sig',
      );
    });

    test('returns null when token or email missing', () {
      expect(
        DeepLinkPaths.fromUri(Uri.parse('nawatechhrm://reset-password?token=only')),
        isNull,
      );
      expect(
        DeepLinkPaths.fromUri(Uri.parse('nawatechhrm://login')),
        isNull,
      );
    });
  });
}
