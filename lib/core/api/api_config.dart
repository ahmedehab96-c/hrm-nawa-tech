import 'dart:io' show Platform;

import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// إعدادات ربط التطبيق بخادم Laravel API
class ApiConfig {
  static const _keyBaseUrl = 'api_base_url';
  static const _keyUseApi = 'api_use_server';
  static const _keyToken = 'auth_token';
  static const _keyUser = 'auth_user';

  static const FlutterSecureStorage _secure = FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
  );

  static String? _baseUrl;
  static bool _useApi = false;

  static String? get baseUrl => _baseUrl;
  static bool get useApi => _useApi;

  static Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    _baseUrl = prefs.getString(_keyBaseUrl);
    _useApi = prefs.getBool(_keyUseApi) ?? false;
  }

  /// أول تشغيل على الويب في وضع التطوير: تفعيل Laravel المحلي دون لمس إعدادات المستخدم إن وُجدت.
  static Future<void> applyDebugWebDefaults() async {
    if (!kDebugMode || !kIsWeb) return;
    final prefs = await SharedPreferences.getInstance();
    final userTouchedBase = prefs.containsKey(_keyBaseUrl);
    final userTouchedUse = prefs.containsKey(_keyUseApi);
    if (userTouchedBase || userTouchedUse) return;
    await setBaseUrl('http://127.0.0.1:8000/api');
    await setUseApi(true);
  }

  /// أول تشغيل على الموبايل في وضع التطوير: ربط تلقائي بـ Laravel المحلي.
  static Future<void> applyDebugMobileDefaults() async {
    if (!kDebugMode || kIsWeb) return;
    final prefs = await SharedPreferences.getInstance();
    if (prefs.containsKey(_keyBaseUrl) || prefs.containsKey(_keyUseApi)) return;
    final url = Platform.isAndroid
        ? 'http://10.0.2.2:8000/api'
        : 'http://127.0.0.1:8000/api';
    await setBaseUrl(url);
    await setUseApi(true);
  }

  /// Production web builds: `--dart-define=API_BASE_URL=/api` or full HTTPS URL.
  static Future<void> applyReleaseDefaults() async {
    const envUrl = String.fromEnvironment('API_BASE_URL');
    final prefs = await SharedPreferences.getInstance();
    if (envUrl.isNotEmpty && !prefs.containsKey(_keyBaseUrl)) {
      await setBaseUrl(envUrl);
    }
    if (kReleaseMode) {
      final effectiveUrl = _baseUrl ?? envUrl;
      if (effectiveUrl.isNotEmpty) {
        await setUseApi(true);
      }
    } else if (envUrl.isNotEmpty &&
        !prefs.containsKey(_keyBaseUrl) &&
        !prefs.containsKey(_keyUseApi)) {
      await setBaseUrl(envUrl);
      await setUseApi(true);
    }
  }

  /// `null` إذا العنوان صالح أو فارغ؛ وإلا رمز: `needs_https` أو `invalid`.
  static String? validateBaseUrl(String? url) {
    final trimmed = url?.trim();
    if (trimmed == null || trimmed.isEmpty) return null;
    if (trimmed.startsWith('/')) return null;
    final uri = Uri.tryParse(trimmed);
    if (uri == null || !uri.hasScheme || uri.host.isEmpty) {
      return 'invalid';
    }
    if (uri.scheme == 'https') return null;
    if (uri.scheme == 'http') {
      final h = uri.host.toLowerCase();
      if (h == 'localhost' ||
          h == '127.0.0.1' ||
          h == '10.0.2.2' ||
          h.endsWith('.local')) {
        return null;
      }
      return 'needs_https';
    }
    return 'invalid';
  }

  static Future<void> setBaseUrl(String? url) async {
    _baseUrl = url?.trim();
    if (_baseUrl != null && _baseUrl!.isNotEmpty) {
      if (!_baseUrl!.endsWith('/')) _baseUrl = '$_baseUrl/';
    } else {
      _baseUrl = null;
    }
    final prefs = await SharedPreferences.getInstance();
    if (_baseUrl == null) {
      await prefs.remove(_keyBaseUrl);
    } else {
      await prefs.setString(_keyBaseUrl, _baseUrl!);
    }
  }

  static Future<void> setUseApi(bool use) async {
    _useApi = use;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyUseApi, _useApi);
  }

  static Future<String?> getToken() async {
    final fromSecure = await _secure.read(key: _keyToken);
    if (fromSecure != null && fromSecure.isNotEmpty) {
      return fromSecure;
    }
    final prefs = await SharedPreferences.getInstance();
    final legacy = prefs.getString(_keyToken);
    if (legacy != null && legacy.isNotEmpty) {
      await _secure.write(key: _keyToken, value: legacy);
      await prefs.remove(_keyToken);
      return legacy;
    }
    return null;
  }

  static Future<void> setToken(String? token) async {
    final prefs = await SharedPreferences.getInstance();
    if (token == null || token.isEmpty) {
      await _secure.delete(key: _keyToken);
      await prefs.remove(_keyToken);
      await prefs.remove(_keyUser);
    } else {
      await _secure.write(key: _keyToken, value: token);
      await prefs.remove(_keyToken);
    }
  }

  static Future<void> setUser(Map<String, dynamic>? user) async {
    final prefs = await SharedPreferences.getInstance();
    if (user == null) {
      await prefs.remove(_keyUser);
    } else {
      await prefs.setString(_keyUser, _encodeUser(user));
    }
  }

  static String _encodeUser(Map<String, dynamic> user) {
    try {
      return user.entries.map((e) => '${e.key}:${e.value}').join('|');
    } catch (_) {
      return '';
    }
  }

  static Future<Map<String, dynamic>?> getUser() async {
    final prefs = await SharedPreferences.getInstance();
    final s = prefs.getString(_keyUser);
    if (s == null || s.isEmpty) return null;
    final map = <String, dynamic>{};
    for (final part in s.split('|')) {
      final idx = part.indexOf(':');
      if (idx > 0) map[part.substring(0, idx)] = part.substring(idx + 1);
    }
    return map.isEmpty ? null : map;
  }

  static String url(String path) {
    var base = _baseUrl ?? '';
    if (base.isEmpty) return '';
    final p = path.startsWith('/') ? path.substring(1) : path;
    if (base.startsWith('/')) {
      final origin = Uri.base.origin;
      if (!base.endsWith('/')) base = '$base/';
      return '$origin$base$p';
    }
    if (!base.endsWith('/')) base = '$base/';
    return '$base$p';
  }
}
