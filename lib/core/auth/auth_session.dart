import 'package:flutter/foundation.dart';

import '../api/api_config.dart';

/// يُحدَّث عند تسجيل الدخول/الخروج أو 401 لإعادة تقييم [GoRouter.redirect].
class AuthSession extends ChangeNotifier {
  AuthSession._();
  static final AuthSession instance = AuthSession._();

  bool _hasSession = false;
  bool get hasSession => _hasSession;

  void setHasSession(bool value) {
    if (_hasSession == value) return;
    _hasSession = value;
    notifyListeners();
  }

  Future<void> syncFromStorage() async {
    final t = await ApiConfig.getToken();
    final next = t != null && t.isNotEmpty;
    if (_hasSession == next) return;
    _hasSession = next;
    notifyListeners();
  }

  void notifyEnvironmentChanged() => notifyListeners();
}
