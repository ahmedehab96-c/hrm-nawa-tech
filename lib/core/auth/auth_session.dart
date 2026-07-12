import 'package:flutter/foundation.dart';

import '../api/api_config.dart';

/// يُحدَّث عند تسجيل الدخول/الخروج أو 401 لإعادة تقييم [GoRouter.redirect].
class AuthSession extends ChangeNotifier {
  AuthSession._();
  static final AuthSession instance = AuthSession._();

  bool _hasSession = false;
  bool get hasSession => _hasSession;

  String? _role;
  String? get role => _role;

  void setHasSession(bool value) {
    if (_hasSession == value) return;
    _hasSession = value;
    if (!value) _role = null;
    notifyListeners();
  }

  Future<void> syncFromStorage() async {
    final t = await ApiConfig.getToken();
    final user = await ApiConfig.getUser();
    final next = t != null && t.isNotEmpty;
    final nextRole = user?['role']?.toString();
    if (_hasSession == next && _role == nextRole) return;
    _hasSession = next;
    _role = next ? nextRole : null;
    notifyListeners();
  }

  void notifyEnvironmentChanged() => notifyListeners();
}
