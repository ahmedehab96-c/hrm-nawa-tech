import 'dart:convert';

import 'package:http/http.dart' as http;

import '../auth/auth_session.dart';
import '../session/token_store.dart';
import '../utils/jwt_util.dart';
import 'api_config.dart';
import 'api_error_parser.dart';
import 'api_localized.dart';
import 'api_result.dart';

/// عميل HTTP للاتصال بـ Laravel API مع دعم Bearer token
class ApiClient {
  ApiClient._();

  static Future<ApiResult<http.Response>> get(String path, {Map<String, String>? headers}) async {
    return _request('GET', path, headers: headers);
  }

  static Future<ApiResult<http.Response>> post(
    String path, {
    Map<String, String>? headers,
    Object? body,
  }) async {
    return _request('POST', path, headers: headers, body: body);
  }

  static Future<ApiResult<http.Response>> put(
    String path, {
    Map<String, String>? headers,
    Object? body,
  }) async {
    return _request('PUT', path, headers: headers, body: body);
  }

  static Future<ApiResult<http.Response>> patch(
    String path, {
    Map<String, String>? headers,
    Object? body,
  }) async {
    return _request('PATCH', path, headers: headers, body: body);
  }

  static Future<ApiResult<http.Response>> delete(String path, {Map<String, String>? headers}) async {
    return _request('DELETE', path, headers: headers);
  }

  /// Unsigned GET for signed email-verification links (no Bearer token).
  static Future<ApiResult<http.Response>> getPublic(
    String path, {
    Map<String, String>? queryParameters,
  }) async {
    final base = ApiConfig.url(path);
    if (base.isEmpty) {
      return ApiFailure(ApiLocalized.strings.apiBaseUrlMissing, statusCode: 0);
    }

    final uri = Uri.parse(base).replace(
      queryParameters: queryParameters?.isNotEmpty == true ? queryParameters : null,
    );

    try {
      final response = await http.get(
        uri,
        headers: const {
          'Accept': 'application/json',
        },
      );

      if (response.statusCode >= 200 && response.statusCode < 300) {
        return ApiSuccess(response);
      }

      var message = ApiLocalized.strings.apiErrorServer;
      try {
        final map = jsonDecode(response.body) as Map<String, dynamic>?;
        if (map?['message'] != null) {
          message = map!['message'].toString();
        }
      } catch (_) {
        if (response.body.isNotEmpty) {
          message = response.body;
        }
      }

      return ApiFailure(message, statusCode: response.statusCode);
    } catch (e) {
      return ApiFailure(
        ApiLocalized.strings.apiErrorConnection(e.toString()),
        statusCode: 0,
      );
    }
  }

  static Future<ApiResult<http.Response>> _request(
    String method,
    String path, {
    Map<String, String>? headers,
    Object? body,
  }) async {
    final url = ApiConfig.url(path);
    if (url.isEmpty) {
      return ApiFailure(ApiLocalized.strings.apiBaseUrlMissing, statusCode: 0);
    }

    var token = await TokenStore.getToken();
    final authFreePath = path == 'login' || path == 'register';
    if (!authFreePath &&
        token != null &&
        token.isNotEmpty &&
        isJwtExpired(token)) {
      await TokenStore.clear();
      await AuthSession.instance.syncFromStorage();
      return ApiFailure(ApiLocalized.strings.sessionExpired, statusCode: 401);
    }

    final h = <String, String>{
      'Accept': 'application/json',
      'Content-Type': 'application/json',
      if (!authFreePath && token != null && token.isNotEmpty)
        'Authorization': 'Bearer $token',
      ...?headers,
    };

    try {
      http.Response response;
      switch (method) {
        case 'GET':
          response = await http.get(Uri.parse(url), headers: h);
          break;
        case 'POST':
          response = await http.post(
            Uri.parse(url),
            headers: h,
            body: body is String ? body : (body != null ? jsonEncode(body) : null),
          );
          break;
        case 'PUT':
          response = await http.put(
            Uri.parse(url),
            headers: h,
            body: body is String ? body : (body != null ? jsonEncode(body) : null),
          );
          break;
        case 'PATCH':
          response = await http.patch(
            Uri.parse(url),
            headers: h,
            body: body is String ? body : (body != null ? jsonEncode(body) : null),
          );
          break;
        case 'DELETE':
          response = await http.delete(Uri.parse(url), headers: h);
          break;
        default:
          return ApiFailure(
            '${ApiLocalized.strings.apiErrorServer}: $method',
            statusCode: 0,
          );
      }

      if (response.statusCode >= 200 && response.statusCode < 300) {
        return ApiSuccess(response);
      }

      if (response.statusCode == 401) {
        await TokenStore.clear();
        await AuthSession.instance.syncFromStorage();
      }

      var message = parseLaravelErrorMessage(response.body) ??
          ApiLocalized.strings.apiErrorServer;
      String? code;
      try {
        final map = jsonDecode(response.body) as Map<String, dynamic>?;
        code = map?['code']?.toString();
        if (message == ApiLocalized.strings.apiErrorServer) {
          if (map?['error'] != null) message = map!['error'].toString();
          if (response.body.isNotEmpty && map == null) message = response.body;
        }
      } catch (_) {
        if (response.body.isNotEmpty &&
            message == ApiLocalized.strings.apiErrorServer) {
          message = response.body;
        }
      }
      if (code == 'trial_expired') {
        message = ApiLocalized.strings.trialExpiredBanner;
      }
      if (code == 'email_unverified') {
        message = ApiLocalized.strings.emailUnverifiedBanner;
      }
      if (code == 'employee_limit_reached') {
        message = ApiLocalized.strings.employeeLimitReached;
      }
      return ApiFailure(message, statusCode: response.statusCode, code: code);
    } catch (e) {
      return ApiFailure(
        ApiLocalized.strings.apiErrorConnection(e.toString()),
        statusCode: 0,
      );
    }
  }
}
