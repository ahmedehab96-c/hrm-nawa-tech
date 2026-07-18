import 'dart:convert';

import 'package:hrm_saas/core/api/api_client.dart';
import 'package:hrm_saas/core/api/api_config.dart';
import 'package:hrm_saas/core/api/api_enabled.dart';
import 'package:hrm_saas/core/api/api_localized.dart';
import 'package:hrm_saas/core/api/api_result.dart';
import 'package:hrm_saas/core/auth/auth_session.dart';
import 'package:hrm_saas/core/auth/user_role.dart';
import 'package:hrm_saas/core/saas/company_context.dart';
import 'package:hrm_saas/core/repositories/settings_repository.dart';

class AuthRepository {
  /// تسجيل الدخول — POST `login`
  /// تطبيق الموظف يقبل فقط حسابات `role == employee`.
  static Future<ApiResult<Map<String, dynamic>>> login(
    String email,
    String password,
  ) async {
    await ApiConfig.load();
    final l10n = ApiLocalized.strings;
    if (isApiEnabled) {
      final res = await ApiClient.post(
        'login',
        body: {'email': email, 'password': password},
      );
      if (res is ApiFailure<dynamic>) {
        return ApiFailure(
          (res as ApiFailure<dynamic>).message,
          statusCode: (res as ApiFailure<dynamic>).statusCode,
        );
      }
      try {
        final map = jsonDecode((res as ApiSuccess).data.body) as Map<String, dynamic>?;
        if (map == null) return ApiFailure(l10n.apiInvalidResponse);
        final token = map['token'] as String? ?? map['access_token'] as String?;
        if (token == null || token.isEmpty) {
          return ApiFailure(map['message']?.toString() ?? l10n.apiNoTokenReceived);
        }
        await ApiConfig.setToken(token);
        var user = map['user'] as Map<String, dynamic>? ?? map;
        final role = user['role']?.toString();
        if (!UserRole.isEmployeeRole(role)) {
          await logout();
          return ApiFailure(l10n.loginUseWebForAdmin);
        }
        user = Map<String, dynamic>.from(user);
        user['email_verified'] = map['user']?['email_verified'] ?? user['email_verified'] ?? true;
        await ApiConfig.setUser(user);
        await AuthSession.instance.syncFromStorage();
        await CompanyContext.instance.load(force: true);
        return ApiSuccess({'token': token, 'user': user});
      } catch (e) {
        return ApiFailure(l10n.apiReadResponseFailed(e.toString()));
      }
    }
    await ApiConfig.setToken('mock_token');
    final mockUser = {
      'email': email,
      'name': l10n.demoUserName,
      'role': UserRole.employee,
      'email_verified': true,
    };
    await ApiConfig.setUser(mockUser);
    await AuthSession.instance.syncFromStorage();
    CompanyContext.instance.apply(CompanySettings.demo);
    return ApiSuccess({
      'token': 'mock_token',
      'user': mockUser,
    });
  }

  /// إرسال رابط إعادة تعيين كلمة المرور — POST `forgot-password`
  /// إرسال رابط إعادة تعيين كلمة المرور — POST `forgot-password`
  static Future<ApiResult<String>> forgotPassword(String email) async {
    await ApiConfig.load();
    if (!ApiConfig.useApi || ApiConfig.baseUrl == null || ApiConfig.baseUrl!.isEmpty) {
      return const ApiSuccess('Reset link sent (demo).');
    }
    final res = await ApiClient.post(
      'forgot-password',
      body: {'email': email},
    );
    if (res is ApiFailure<dynamic>) {
      return ApiFailure(
        (res as ApiFailure<dynamic>).message,
        statusCode: (res as ApiFailure<dynamic>).statusCode,
      );
    }
    try {
      final map = jsonDecode((res as ApiSuccess).data.body) as Map<String, dynamic>?;
      return ApiSuccess(map?['message']?.toString() ?? 'Reset link sent.');
    } catch (e) {
      return ApiSuccess('Reset link sent.');
    }
  }

  /// جلب حالة المستخدم الحالي — GET `auth/me`
  static Future<ApiResult<Map<String, dynamic>>> fetchCurrentUser() async {
    await ApiConfig.load();
    final l10n = ApiLocalized.strings;
    if (!ApiConfig.useApi || ApiConfig.baseUrl == null || ApiConfig.baseUrl!.isEmpty) {
      final user = await ApiConfig.getUser();
      return ApiSuccess(user ?? {});
    }
    final res = await ApiClient.get('auth/me');
    if (res is ApiFailure<dynamic>) {
      return ApiFailure(
        (res as ApiFailure<dynamic>).message,
        statusCode: (res as ApiFailure<dynamic>).statusCode,
      );
    }
    try {
      final map = jsonDecode((res as ApiSuccess).data.body) as Map<String, dynamic>?;
      final data = map?['data'] as Map<String, dynamic>? ?? {};
      final user = await ApiConfig.getUser();
      final merged = Map<String, dynamic>.from(user ?? {});
      merged.addAll(data);
      await ApiConfig.setUser(merged);
      await AuthSession.instance.syncFromStorage();
      return ApiSuccess(merged);
    } catch (e) {
      return ApiFailure(l10n.apiReadResponseFailed(e.toString()));
    }
  }

  /// تأكيد البريد من رابط موقّع (deep link من البريد)
  static Future<ApiResult<String>> verifyEmailFromLink({
    required String id,
    required String hash,
    String? expires,
    String? signature,
  }) async {
    await ApiConfig.load();
    final l10n = ApiLocalized.strings;
    if (!ApiConfig.useApi || ApiConfig.baseUrl == null || ApiConfig.baseUrl!.isEmpty) {
      return ApiSuccess(l10n.verifyEmailSuccess);
    }

    final query = <String, String>{};
    if (expires != null && expires.isNotEmpty) {
      query['expires'] = expires;
    }
    if (signature != null && signature.isNotEmpty) {
      query['signature'] = signature;
    }

    final res = await ApiClient.getPublic(
      'email/verify/$id/$hash',
      queryParameters: query.isEmpty ? null : query,
    );

    if (res is ApiFailure<dynamic>) {
      return ApiFailure(
        (res as ApiFailure<dynamic>).message,
        statusCode: (res as ApiFailure<dynamic>).statusCode,
      );
    }

    try {
      final map = jsonDecode((res as ApiSuccess).data.body) as Map<String, dynamic>?;
      final user = await ApiConfig.getUser();
      if (user != null) {
        user['email_verified'] = true;
        await ApiConfig.setUser(user);
        await AuthSession.instance.syncFromStorage();
      }
      return ApiSuccess(map?['message']?.toString() ?? l10n.verifyEmailSuccess);
    } catch (e) {
      return ApiSuccess(l10n.verifyEmailSuccess);
    }
  }

  /// إعادة إرسال رابط تأكيد البريد — POST `email/verification-notification`
  static Future<ApiResult<String>> resendVerification() async {
    await ApiConfig.load();
    final l10n = ApiLocalized.strings;
    if (!ApiConfig.useApi || ApiConfig.baseUrl == null || ApiConfig.baseUrl!.isEmpty) {
      return ApiSuccess(l10n.verificationLinkSent);
    }
    final res = await ApiClient.post('email/verification-notification');
    if (res is ApiFailure<dynamic>) {
      return ApiFailure(
        (res as ApiFailure<dynamic>).message,
        statusCode: (res as ApiFailure<dynamic>).statusCode,
      );
    }
    try {
      final map = jsonDecode((res as ApiSuccess).data.body) as Map<String, dynamic>?;
      return ApiSuccess(map?['message']?.toString() ?? l10n.verificationLinkSent);
    } catch (e) {
      return ApiSuccess(l10n.verificationLinkSent);
    }
  }

  /// إعادة تعيين كلمة المرور — POST `reset-password`
  /// يُستخدم عند دعم Deep Links (الرابط من الإيميل يفتح التطبيق مباشرة)
  static Future<ApiResult<String>> resetPassword({
    required String email,
    required String token,
    required String password,
    required String passwordConfirmation,
  }) async {
    await ApiConfig.load();
    if (!ApiConfig.useApi || ApiConfig.baseUrl == null || ApiConfig.baseUrl!.isEmpty) {
      return const ApiSuccess('Password reset (demo).');
    }
    final res = await ApiClient.post(
      'reset-password',
      body: {
        'email': email,
        'token': token,
        'password': password,
        'password_confirmation': passwordConfirmation,
      },
    );
    if (res is ApiFailure<dynamic>) {
      return ApiFailure(
        (res as ApiFailure<dynamic>).message,
        statusCode: (res as ApiFailure<dynamic>).statusCode,
      );
    }
    try {
      final map = jsonDecode((res as ApiSuccess).data.body) as Map<String, dynamic>?;
      return ApiSuccess(map?['message']?.toString() ?? 'Password reset successfully.');
    } catch (e) {
      return const ApiSuccess('Password reset successfully.');
    }
  }

  static Future<void> logout() async {
    // إبطال الـ token على الخادم أولاً (نتجاهل الخطأ إذا انتهت الجلسة)
    if (isApiEnabled) {
      try {
        await ApiClient.post('logout');
      } catch (_) {}
    }
    await ApiConfig.setToken(null);
    await ApiConfig.setUser(null);
    CompanyContext.instance.clear();
    await AuthSession.instance.syncFromStorage();
  }

  static Future<bool> isLoggedIn() async {
    final token = await ApiConfig.getToken();
    return token != null && token.isNotEmpty;
  }
}
