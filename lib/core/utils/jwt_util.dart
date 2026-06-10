import 'dart:convert';

/// يتحقق من انتهاء صلاحية JWT إن وُجد حقل [exp] في الـ payload.
bool isJwtExpired(String token) {
  final parts = token.split('.');
  if (parts.length != 3) return false;
  try {
    var s = parts[1].replaceAll('-', '+').replaceAll('_', '/');
    switch (s.length % 4) {
      case 2:
        s += '==';
        break;
      case 3:
        s += '=';
        break;
      case 1:
        return false;
    }
    final map = jsonDecode(utf8.decode(base64.decode(s))) as Map<String, dynamic>?;
    final exp = map?['exp'];
    final nowMs = DateTime.now().millisecondsSinceEpoch;
    if (exp is int) {
      return nowMs >= exp * 1000;
    }
    if (exp is num) {
      return nowMs >= exp * 1000;
    }
  } catch (_) {}
  return false;
}
