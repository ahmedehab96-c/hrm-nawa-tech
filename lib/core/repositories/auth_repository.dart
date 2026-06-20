import 'dart:convert';

import '../api/api_client.dart';
import '../api/api_config.dart';
import '../api/api_localized.dart';
import '../api/api_result.dart';
import '../auth/auth_session.dart';
import '../auth/user_role.dart';
import '../saas/company_context.dart';
import 'settings_repository.dart';

class AuthRepository {
  /// تسجيل الدخول — POST `login` (نسبة لـ base URL الذي ينتهي بـ `/api/`)
  /// [surface]: ويب للإدارة فقط، موبايل لحسابات الموظف (`role == employee`).
  static Future<ApiResult<Map<String, dynamic>>> login(
    String email,
    String password, {
    required LoginSurface surface,
  }) async {
    await ApiConfig.load();
    final l10n = ApiLocalized.strings;
    if (ApiConfig.useApi && ApiConfig.baseUrl != null && ApiConfig.baseUrl!.isNotEmpty) {
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
        if (surface == LoginSurface.webAdmin && UserRole.isEmployeeRole(role)) {
          await logout();
          return ApiFailure(l10n.loginUseMobileForEmployee);
        }
        if (surface == LoginSurface.mobileEmployee && !UserRole.isEmployeeRole(role)) {
          await logout();
          return ApiFailure(l10n.loginUseWebForAdmin);
        }
        user = Map<String, dynamic>.from(user);
        await ApiConfig.setUser(user);
        await AuthSession.instance.syncFromStorage();
        await CompanyContext.instance.load(force: true);
        return ApiSuccess({'token': token, 'user': user});
      } catch (e) {
        return ApiFailure(l10n.apiReadResponseFailed(e.toString()));
      }
    }
    await ApiConfig.setToken('mock_token');
    final mockRole = surface == LoginSurface.mobileEmployee
        ? UserRole.employee
        : UserRole.companyAdmin;
    final mockUser = {'email': email, 'name': l10n.demoUserName, 'role': mockRole};
    await ApiConfig.setUser(mockUser);
    await AuthSession.instance.syncFromStorage();
    CompanyContext.instance.apply(CompanySettings.demo);
    return ApiSuccess({
      'token': 'mock_token',
      'user': mockUser,
    });
  }

  /// تسجيل شركة — POST `register` (يتوافق مع Laravel Breeze/Jetstream الشائع)
  static Future<ApiResult<Map<String, dynamic>>> register({
    required String companyName,
    required String email,
    required String password,
  }) async {
    await ApiConfig.load();
    final l10n = ApiLocalized.strings;
    if (ApiConfig.useApi && ApiConfig.baseUrl != null && ApiConfig.baseUrl!.isNotEmpty) {
      final res = await ApiClient.post(
        'register',
        body: {
          'name': companyName,
          'company_name': companyName,
          'email': email,
          'password': password,
          'password_confirmation': password,
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
        if (map == null) return ApiFailure(l10n.apiInvalidResponse);
        final token = map['token'] as String? ?? map['access_token'] as String?;
        if (token != null && token.isNotEmpty) {
          await ApiConfig.setToken(token);
          final user = Map<String, dynamic>.from(
            map['user'] as Map<String, dynamic>? ?? {'email': email, 'name': companyName},
          );
          user.putIfAbsent('role', () => UserRole.companyAdmin);
          await ApiConfig.setUser(user);
          await AuthSession.instance.syncFromStorage();
          await CompanyContext.instance.load(force: true);
          return ApiSuccess({'token': token, 'user': user});
        }
        return ApiSuccess({'registered': true, 'user': map['user']});
      } catch (e) {
        return ApiFailure(l10n.apiReadResponseFailed(e.toString()));
      }
    }
    await ApiConfig.setToken('mock_token');
    await ApiConfig.setUser({
      'email': email,
      'name': companyName,
      'role': UserRole.companyAdmin,
    });
    await AuthSession.instance.syncFromStorage();
    return ApiSuccess({
      'token': 'mock_token',
      'user': {'email': email, 'name': companyName, 'role': UserRole.companyAdmin},
    });
  }

  /// إرسال رابط إعادة تعيين كلمة المرور — POST `forgot-password`
  static Future<ApiResult<String>> forgotPassword(String email) async {
    await ApiConfig.load();
    if (!ApiConfig.useApi || ApiConfig.baseUrl == null || ApiConfig.baseUrl!.isEmpty) {
      // في وضع الديمو نُعيد نجاحاً مباشرة
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
    if (ApiConfig.useApi && ApiConfig.baseUrl != null && ApiConfig.baseUrl!.isNotEmpty) {
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
