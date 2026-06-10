import 'package:flutter/material.dart';

TextDirection textDirectionForLocale(Locale locale) {
  return locale.languageCode == 'ar' ? TextDirection.rtl : TextDirection.ltr;
}

TextDirection textDirectionForContext(BuildContext context) {
  return textDirectionForLocale(Localizations.localeOf(context));
}
