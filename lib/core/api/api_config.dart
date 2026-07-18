import 'dart:io' show Platform;

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../session/token_store.dart';

/// إعدادات ربط التطبيق بخادم Laravel API (URL + demo/API mode فقط).
/// التوكن وبيانات المستخدم في [TokenStore].
class ApiConfig {
  static const _keyBaseUrl = 'api_base_url';
  static const _keyUseApi = 'api_use_server';

  /// Public portfolio API (Render). Override with `--dart-define=API_BASE_URL=...`.
  static const liveDemoBaseUrl = 'https://hrm-nawa-api.onrender.com/api';

  static String? _baseUrl;
  static bool _useApi = false;

  static String? get baseUrl => _baseUrl;
  static bool get useApi => _useApi;

  static Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    _baseUrl = prefs.getString(_keyBaseUrl);
    _useApi = prefs.getBool(_keyUseApi) ?? false;
  }

  /// أول تشغيل على الموبايل في وضع التطوير: ربط تلقائي بـ Laravel المحلي.
  /// With `--dart-define=USE_LIVE_DEMO=true`, force the public Render API (phone + sim).
  static Future<void> applyDebugMobileDefaults() async {
    if (!kDebugMode) return;
    const useLive = bool.fromEnvironment('USE_LIVE_DEMO', defaultValue: false);
    const envUrl = String.fromEnvironment('API_BASE_URL');
    if (useLive) {
      await setBaseUrl(envUrl.isNotEmpty ? envUrl : liveDemoBaseUrl);
      await setUseApi(true);
      return;
    }
    final prefs = await SharedPreferences.getInstance();
    if (prefs.containsKey(_keyBaseUrl) || prefs.containsKey(_keyUseApi)) return;
    if (envUrl.isNotEmpty) {
      await setBaseUrl(envUrl);
      await setUseApi(true);
      return;
    }
    final url = Platform.isAndroid
        ? 'http://10.0.2.2:8000/api'
        : 'http://127.0.0.1:8000/api';
    await setBaseUrl(url);
    await setUseApi(true);
  }

  /// Release defaults to the live demo API so APK/IPA demos work without extra setup.
  /// Override: `--dart-define=API_BASE_URL=https://your-api.example/api`
  static Future<void> applyReleaseDefaults() async {
    const envUrl = String.fromEnvironment('API_BASE_URL');
    final prefs = await SharedPreferences.getInstance();
    final resolved = envUrl.isNotEmpty
        ? envUrl
        : (kReleaseMode ? liveDemoBaseUrl : '');
    if (resolved.isNotEmpty && !prefs.containsKey(_keyBaseUrl)) {
      await setBaseUrl(resolved);
    }
    if (kReleaseMode) {
      final effectiveUrl = _baseUrl ?? resolved;
      if (effectiveUrl.isNotEmpty) {
        await setUseApi(true);
      }
    } else if (resolved.isNotEmpty &&
        !prefs.containsKey(_keyBaseUrl) &&
        !prefs.containsKey(_keyUseApi)) {
      await setBaseUrl(resolved);
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

  // Compatibility facades — prefer TokenStore in new code.
  static Future<String?> getToken() => TokenStore.getToken();
  static Future<void> setToken(String? token) => TokenStore.setToken(token);
  static Future<void> setUser(Map<String, dynamic>? user) => TokenStore.setUser(user);
  static Future<Map<String, dynamic>?> getUser() => TokenStore.getUser();

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
