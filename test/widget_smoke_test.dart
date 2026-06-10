import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hrm_saas/core/utils/text_direction_helper.dart';

void main() {
  test('textDirectionForLocale follows language', () {
    expect(textDirectionForLocale(const Locale('ar')), TextDirection.rtl);
    expect(textDirectionForLocale(const Locale('en')), TextDirection.ltr);
  });
}
