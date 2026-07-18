import '../api/api_config.dart';

/// يُحدد ما إذا كان يجب فرض شرط الواي فاي لتسجيل الحضور.
///
/// السلوك الحالي:
/// - وضع الخادم (Server Mode): الحضور يُسجَّل عبر API وتُطبَّق القيود
///   من جانب الخادم (مثل موقع GPS أو SSID). لذا لا يُشترط الواي فاي
///   من جانب التطبيق لتجنب الازدواجية.
/// - وضع Demo: يُشترط الواي فاي لتجربة التحقق المحلي.
///
/// ملاحظة: إذا أُريد فرض SSID من جانب الخادم، أرسل اسم الشبكة في
/// طلب /attendance/check-in وتحقق منه في AttendanceController.
Future<bool> requireCompanyWifiForAttendance() async {
  await ApiConfig.load();
  // في وضع الخادم يتولى Backend التحقق من الموقع/الشبكة
  if (ApiConfig.useApi && ApiConfig.baseUrl != null && ApiConfig.baseUrl!.isNotEmpty) {
    return false;
  }
  // في وضع Demo يُطبَّق التحقق المحلي بالواي فاي
  return true;
}
