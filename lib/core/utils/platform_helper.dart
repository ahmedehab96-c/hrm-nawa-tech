import 'package:flutter/foundation.dart';

/// Determines if app is running as Web Admin or Mobile Employee
class PlatformHelper {
  static bool get isWeb => kIsWeb;

  static bool get isMobile =>
      !kIsWeb &&
      (defaultTargetPlatform == TargetPlatform.android ||
          defaultTargetPlatform == TargetPlatform.iOS);

  /// Web = Admin Dashboard, Mobile = Employee App
  static bool get isAdminApp => isWeb;

  static bool get isEmployeeApp => isMobile;
}
