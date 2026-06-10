import '../api/api_config.dart';

/// عند تفعيل «استخدام الخادم» لا يُشترط الواي فاي لتسجيل الحضور (مناسب للاختبار والربط مع API).
Future<bool> requireCompanyWifiForAttendance() async {
  await ApiConfig.load();
  if (ApiConfig.useApi && ApiConfig.baseUrl != null && ApiConfig.baseUrl!.isNotEmpty) {
    return false;
  }
  return true;
}
