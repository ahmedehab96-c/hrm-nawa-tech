import 'package:flutter/foundation.dart';

import '../session/token_store.dart';

/// يُحدَّث عند تسجيل الدخول/الخروج أو 401 لإعادة تقييم [GoRouter.redirect].
class AuthSession extends ChangeNotifier {
  AuthSession._();
  static final AuthSession instance = AuthSession._();

  bool _hasSession = false;
  bool get hasSession => _hasSession;

  bool _emailVerified = true;
  bool get emailVerified => _emailVerified;

  String? _role;
  String? get role => _role;

  void setHasSession(bool value, {bool? emailVerified}) {
    if (_hasSession == value && (emailVerified == null || _emailVerified == emailVerified)) {
      return;
    }
    _hasSession = value;
    if (!value) {
      _role = null;
      _emailVerified = true;
    } else if (emailVerified != null) {
      _emailVerified = emailVerified;
    }
    notifyListeners();
  }

  void setEmailVerified(bool value) {
    if (_emailVerified == value) return;
    _emailVerified = value;
    notifyListeners();
  }

  Future<void> syncFromStorage() async {
    final t = await TokenStore.getToken();
    final user = await TokenStore.getUser();
    final next = t != null && t.isNotEmpty;
    final nextRole = user?['role']?.toString();
    final rawVerified = user?['email_verified'];
    final nextVerified = rawVerified == true ||
        rawVerified?.toString().toLowerCase() == 'true';
    if (_hasSession == next && _role == nextRole && _emailVerified == nextVerified) {
      return;
    }
    _hasSession = next;
    _role = next ? nextRole : null;
    _emailVerified = next ? nextVerified : true;
    notifyListeners();
  }

  void notifyEnvironmentChanged() => notifyListeners();
}
