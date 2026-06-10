import '../api/api_config.dart';
import '../saas/subscription_controller.dart';

/// إجابات محلية ثنائية اللغاء؛ طبقة Enterprise جاهزة لاحقاً لربط LLM عبر الخادم فقط (لا تضع مفاتيح في التطبيق).
class AiAssistantService {
  AiAssistantService._();

  static Future<String> getResponse(
    String userMessage, {
    required String languageCode,
  }) async {
    await Future.delayed(const Duration(milliseconds: 420));
    await ApiConfig.load();
    final apiOn = ApiConfig.useApi && (ApiConfig.baseUrl?.isNotEmpty ?? false);
    final q = userMessage.trim().toLowerCase();
    final ar = languageCode.startsWith('ar');

    if (q.isEmpty) {
      return ar ? 'اكتب سؤالاً وسأساعدك.' : 'Ask me anything about the app.';
    }

    final hit = _match(q, ar, apiOn);
    if (hit != null) return hit;

    if (SubscriptionController.instance.aiCloudFeaturesEnabled) {
      return ar
          ? 'وضع المؤسسات: يمكن ربط نموذج لغوي عبر الـ API الخاص بك لاحقاً.'
          : 'Enterprise: plug in an LLM via your own API when ready.';
    }
    return ar
        ? 'جرّب: إضافة موظف، حضور، إجازات، رواتب، أو اشتراك.'
        : 'Try: add employee, attendance, leave, payroll, or subscription.';
  }

  static String? _match(String q, bool ar, bool apiOn) {
    String r(String a, String e) => ar ? a : e;

    if ((q.contains('موظف') && (q.contains('إضافة') || q.contains('اضافة'))) ||
        (q.contains('employee') && q.contains('add'))) {
      return r(
        'الموظفون ← إضافة موظف، ثم احفظ.',
        'Employees → Add employee, then Save.',
      );
    }
    if (q.contains('حضور') || q.contains('attendance')) {
      return r(
        'الحضور: جدول يومي.${apiOn ? ' البيانات من الخادم.' : ' الآن بيانات تجريبية.'}',
        'Attendance: daily grid.${apiOn ? ' Live API.' : ' Demo data.'}',
      );
    }
    if (q.contains('إجاز') || q.contains('اجاز') || q.contains('leave')) {
      return r('إجازات الإدارة للموافقة؛ الموظف يقدّم من التطبيق.', 'Admins approve leave; employees request in the app.');
    }
    if (q.contains('راتب') || q.contains('رواتب') || q.contains('payroll')) {
      return r('الرواتب حسب الشهر.', 'Payroll is month-based.');
    }
    if (q.contains('اشتراك') || q.contains('سعر') || q.contains('subscription') || q.contains('billing')) {
      return r(
        'الخطط من الإعدادات ← الاشتراك. الدفع الحقيقي يُفعّل لاحقاً.',
        'Plans under Settings → Subscription. Real billing comes later.',
      );
    }
    if (q.contains('مرحب') || q.contains('اهلا') || q.contains('hello')) {
      return r('مرحباً! كيف أساعدك في Nawa Tech HRM؟', 'Hi! How can I help with Nawa Tech HRM?');
    }
    return null;
  }
}
