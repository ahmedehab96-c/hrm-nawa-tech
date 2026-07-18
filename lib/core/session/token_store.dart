import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Secure token + cached user profile (split from [ApiConfig]).
class TokenStore {
  TokenStore._();

  static const _keyToken = 'auth_token';
  static const _keyUser = 'auth_user';

  static const FlutterSecureStorage _secure = FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
  );

  static Future<String?> getToken() async {
    try {
      final fromSecure = await _secure.read(key: _keyToken);
      if (fromSecure != null && fromSecure.isNotEmpty) {
        return fromSecure;
      }
    } on MissingPluginException {
      // Unit tests / unsupported platform — fall through to prefs.
    }
    final prefs = await SharedPreferences.getInstance();
    final legacy = prefs.getString(_keyToken);
    if (legacy != null && legacy.isNotEmpty) {
      try {
        await _secure.write(key: _keyToken, value: legacy);
        await prefs.remove(_keyToken);
      } on MissingPluginException {
        return legacy;
      }
      return legacy;
    }
    return null;
  }

  static Future<void> setToken(String? token) async {
    final prefs = await SharedPreferences.getInstance();
    if (token == null || token.isEmpty) {
      try {
        await _secure.delete(key: _keyToken);
      } on MissingPluginException {
        // ignore in tests
      }
      await prefs.remove(_keyToken);
      await prefs.remove(_keyUser);
    } else {
      try {
        await _secure.write(key: _keyToken, value: token);
        await prefs.remove(_keyToken);
      } on MissingPluginException {
        await prefs.setString(_keyToken, token);
      }
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

  static Future<Map<String, dynamic>?> getUser() async {
    final prefs = await SharedPreferences.getInstance();
    final s = prefs.getString(_keyUser);
    if (s == null || s.isEmpty) return null;
    try {
      if (s.startsWith('{')) {
        final decoded = jsonDecode(s);
        if (decoded is Map<String, dynamic>) return decoded;
      }
      // Legacy key:value|key:value format
      final map = <String, dynamic>{};
      for (final part in s.split('|')) {
        final idx = part.indexOf(':');
        if (idx > 0) map[part.substring(0, idx)] = part.substring(idx + 1);
      }
      return map.isEmpty ? null : map;
    } catch (_) {
      return null;
    }
  }

  static Future<void> clear() async {
    await setToken(null);
  }

  static String _encodeUser(Map<String, dynamic> user) {
    try {
      return jsonEncode(user);
    } catch (_) {
      return '';
    }
  }
}
