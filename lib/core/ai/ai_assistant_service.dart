import '../api/api_config.dart';
import '../api/api_result.dart';
import '../repositories/ai_repository.dart';

/// إجابات محلية ثنائية اللغة؛ مع تفعيل API تُستخدم خدمة الذكاء الاصطناعي من الخادم.
class AiAssistantService {
  AiAssistantService._();

  static const _fallbackConversationId = 'local-fallback';

  static Future<AiAssistantReply> getResponse(
    String userMessage, {
    required String languageCode,
    String? conversationId,
  }) async {
    await ApiConfig.load();
    final apiOn = ApiConfig.useApi && (ApiConfig.baseUrl?.isNotEmpty ?? false);
    final q = userMessage.trim().toLowerCase();
    final ar = languageCode.startsWith('ar');

    if (q.isEmpty) {
      return AiAssistantReply(
        message: ar ? 'اكتب سؤالاً وسأساعدك.' : 'Ask me anything about the app.',
        conversationId: conversationId ?? _fallbackConversationId,
      );
    }

    if (apiOn) {
      final cloud = await AiRepository.instance.chat(
        message: userMessage.trim(),
        languageCode: languageCode,
        conversationId: conversationId == _fallbackConversationId ? null : conversationId,
      );
      if (cloud case ApiSuccess(:final data)) {
        return AiAssistantReply(
          message: data.reply,
          conversationId: data.conversationId.isNotEmpty
              ? data.conversationId
              : (conversationId ?? _fallbackConversationId),
          provider: data.provider,
          model: data.model,
        );
      }
    }

    await Future.delayed(const Duration(milliseconds: 420));

    final hit = _match(q, ar, apiOn);
    if (hit != null) {
      return AiAssistantReply(
        message: hit,
        conversationId: conversationId ?? _fallbackConversationId,
      );
    }

    return AiAssistantReply(
      message: ar
          ? 'جرّب: إضافة موظف، حضور، إجازات، رواتب، أو التوظيف.'
          : 'Try: add employee, attendance, leave, payroll, or recruitment.',
      conversationId: conversationId ?? _fallbackConversationId,
    );
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

class AiAssistantReply {
  const AiAssistantReply({
    required this.message,
    required this.conversationId,
    this.provider,
    this.model,
  });

  final String message;
  final String conversationId;
  final String? provider;
  final String? model;
}
