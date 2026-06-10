import '../locale/locale_controller.dart';
import '../../l10n/app_localizations.dart';

/// ترجمة رسائل الطبقة [ApiClient] والمستودعات دون الحاجة إلى [BuildContext].
class ApiLocalized {
  ApiLocalized._();

  static AppLocalizations get strings =>
      lookupAppLocalizations(LocaleController.instance.locale);
}
