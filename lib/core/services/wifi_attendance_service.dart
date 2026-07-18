import 'package:network_info_plus/network_info_plus.dart';

/// خدمة التحقق من الواي فاي لتسجيل الحضور
/// يسجل الحضور فقط عند الاتصال بشبكة الشركة
class WifiAttendanceService {
  static const String _defaultCompanyWifi = 'Company_Office';
  static String _companyWifiSsid = _defaultCompanyWifi;

  static final NetworkInfo _networkInfo = NetworkInfo();

  /// تعيين اسم شبكة الواي فاي الخاصة بالشركة (من الإعدادات)
  static void setCompanyWifiSsid(String ssid) {
    _companyWifiSsid = ssid.isNotEmpty ? _normalizeSsid(ssid) : _defaultCompanyWifi;
  }

  /// تهيئة اسم الشبكة من الإعدادات (يُستدعى عند بدء التطبيق)
  static void initFromConfig(String? ssid) {
    if (ssid != null && ssid.isNotEmpty) {
      setCompanyWifiSsid(ssid);
    }
  }

  /// اسم شبكة الشركة الحالية
  static String get companyWifiSsid => _companyWifiSsid;

  /// تطبيع اسم الشبكة (إزالة علامات الاقتباس التي يضيفها أندرويد)
  static String _normalizeSsid(String ssid) {
    return ssid.replaceAll('"', '').trim();
  }

  /// الحصول على اسم الشبكة الحالية
  static Future<String?> getCurrentWifiName() async {
    try {
      final name = await _networkInfo.getWifiName();
      return name != null ? _normalizeSsid(name) : null;
    } catch (_) {
      return null;
    }
  }

  /// التحقق من الاتصال بشبكة الشركة
  static Future<bool> isOnCompanyWifi() async {
    try {
      final currentSsid = await getCurrentWifiName();
      if (currentSsid == null || currentSsid.isEmpty) return false;
      return _normalizeSsid(currentSsid) == _companyWifiSsid;
    } catch (_) {
      return false;
    }
  }

  /// التحقق قبل تسجيل الحضور/الخروج
  /// يرجع true إذا كان بالإمكان التسجيل
  static Future<WifiCheckResult> canRecordAttendance() async {
    try {
      final currentSsid = await getCurrentWifiName();
      if (currentSsid == null || currentSsid.isEmpty) {
        return WifiCheckResult(
          success: false,
          message: 'يجب الاتصال بشبكة الواي فاي الخاصة بالشركة لتسجيل الحضور',
        );
      }
      final normalized = _normalizeSsid(currentSsid);
      if (normalized != _companyWifiSsid) {
        return WifiCheckResult(
          success: false,
          wifiName: currentSsid,
          message: 'يجب الاتصال بشبكة الشركة "$_companyWifiSsid" لتسجيل الحضور. الشبكة الحالية: $currentSsid',
        );
      }
      return WifiCheckResult(success: true, wifiName: currentSsid);
    } catch (e) {
      return WifiCheckResult(
        success: false,
        message: 'تعذر التحقق من شبكة الواي فاي: $e',
      );
    }
  }
}

class WifiCheckResult {
  final bool success;
  final String? wifiName;
  final String? message;

  WifiCheckResult({
    required this.success,
    this.wifiName,
    this.message,
  });
}
