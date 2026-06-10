import 'dart:convert';

/// استخراج رسالة خطأ من استجابة Laravel (message أو errors).
String? parseLaravelErrorMessage(String body) {
  if (body.isEmpty) return null;
  try {
    final decoded = jsonDecode(body);
    if (decoded is! Map<String, dynamic>) return null;
    if (decoded['message'] != null) {
      final m = decoded['message'].toString();
      if (m.isNotEmpty) return m;
    }
    final errs = decoded['errors'];
    if (errs is Map) {
      for (final v in errs.values) {
        if (v is List && v.isNotEmpty) return v.first.toString();
        if (v != null) return v.toString();
      }
    }
  } catch (_) {}
  return null;
}
