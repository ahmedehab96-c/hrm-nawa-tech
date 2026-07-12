import '../locale/locale_controller.dart';
import '../../l10n/app_strings.dart';

/// ترجمة رسائل الطبقة [ApiClient] والمستودعات دون الحاجة إلى [BuildContext].
class ApiLocalized {
  ApiLocalized._();

  static AppStrings get strings =>
      lookupAppStrings(LocaleController.instance.locale);
}
