import 'dart:io';

import 'package:hrm_saas/features/employee/auth/data/device_token_repository.dart';

/// Registers a push token with the API when available.
/// Wire Firebase Messaging later; for now supports `PUSH_TOKEN` dart-define for testing.
class DeviceTokenService {
  const DeviceTokenService._();

  static Future<void> registerIfAvailable() async {
    const token = String.fromEnvironment('PUSH_TOKEN', defaultValue: '');
    if (token.isEmpty) {
      return;
    }

    final platform = Platform.isIOS
        ? 'ios'
        : Platform.isAndroid
            ? 'android'
            : 'unknown';

    await DeviceTokenRepository.register(token: token, platform: platform);
  }
}
