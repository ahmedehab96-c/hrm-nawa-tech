import 'package:hrm_saas/core/api/api_config.dart';
import 'package:hrm_saas/core/api/api_enabled.dart';
import 'package:hrm_saas/core/api/api_result.dart';
import 'package:hrm_saas/features/employee/assistant/ai_repository.dart';

/// Local bilingual fallbacks; when API is on, uses Laravel AI chat.
/// Cloud AI remains gated by backend middleware (`ai.enabled` / rollout / quota).
class AiAssistantService {
  AiAssistantService._();

  /// Product gate for the employee AI assistant. Enabled by default now that AI
  /// is activated; the cloud provider stays gated server-side by the company's
  /// `ai.enabled` / rollout / quota middleware, so this only controls the UI.
  /// Override at build time with `--dart-define=ENABLE_EMPLOYEE_AI=false`.
  static const bool featureEnabled = bool.fromEnvironment(
    'ENABLE_EMPLOYEE_AI',
    defaultValue: true,
  );

  static const _fallbackConversationId = 'local-fallback';

  static Future<AiAssistantReply> getResponse(
    String userMessage, {
    required String languageCode,
    String? conversationId,
  }) async {
    await ApiConfig.load();
    if (!featureEnabled) {
      return AiAssistantReply(
        message: languageCode == 'ar'
            ? 'المساعد الذكي غير مفعّل حالياً في هذا الإصدار.'
            : 'The AI assistant is not enabled in this build yet.',
        conversationId: conversationId ?? _fallbackConversationId,
      );
    }

    if (isApiEnabled) {
      final result = await AiRepository.instance.chat(
        message: userMessage,
        languageCode: languageCode,
        conversationId: conversationId,
      );
      if (result is ApiSuccess<AiChatReply>) {
        return AiAssistantReply(
          message: result.data.reply,
          conversationId: result.data.conversationId,
        );
      }
      if (result is ApiFailure<AiChatReply>) {
        return AiAssistantReply(
          message: result.message,
          conversationId: conversationId ?? _fallbackConversationId,
        );
      }
    }

    return AiAssistantReply(
      message: _localFallback(userMessage, languageCode),
      conversationId: conversationId ?? _fallbackConversationId,
    );
  }

  static String _localFallback(String userMessage, String languageCode) {
    final q = userMessage.toLowerCase();
    final ar = languageCode == 'ar';
    if (q.contains('leave') || q.contains('إجاز')) {
      return ar
          ? 'يمكنك طلب إجازة من تبويب الإجازات، ومتابعة حالتها من نفس الشاشة.'
          : 'You can request leave from the Leave tab and track its status there.';
    }
    if (q.contains('attend') || q.contains('حضور')) {
      return ar
          ? 'سجّل الحضور من الرئيسية أو تبويب الحضور عند الاتصال بشبكة الشركة.'
          : 'Record attendance from Home or the Attendance tab when on company Wi‑Fi.';
    }
    if (q.contains('pay') || q.contains('راتب') || q.contains('payslip')) {
      return ar
          ? 'قسائم الراتب متاحة في تبويب الراتب.'
          : 'Payslips are available in the Payroll tab.';
    }
    return ar
        ? 'اسأل عن الحضور أو الإجازات أو الراتب لأرشدك داخل تطبيق الموظف.'
        : 'Ask about attendance, leave, or payroll for guidance in the employee app.';
  }
}

class AiAssistantReply {
  const AiAssistantReply({
    required this.message,
    required this.conversationId,
  });

  final String message;
  final String conversationId;
}
