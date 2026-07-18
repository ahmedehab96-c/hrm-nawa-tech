import 'dart:convert';

import 'package:http/http.dart' as http;

import 'api_result.dart';

/// Shared JSON decoding helpers for Laravel API envelopes.
abstract final class ApiJson {
  static dynamic decodeBody(http.Response response) => jsonDecode(response.body);

  /// Accepts bare list or `{ "data": [...] }`.
  static List<dynamic> listOf(dynamic decoded) {
    if (decoded is List) return decoded;
    if (decoded is Map && decoded['data'] is List) {
      return decoded['data'] as List<dynamic>;
    }
    return const [];
  }

  /// Accepts map or `{ "data": { ... } }`.
  static Map<String, dynamic> mapOf(dynamic decoded) {
    if (decoded is Map<String, dynamic>) {
      final data = decoded['data'];
      if (data is Map<String, dynamic>) return data;
      return decoded;
    }
    return const {};
  }

  static Map<String, dynamic> metaOf(dynamic decoded) {
    if (decoded is Map && decoded['meta'] is Map<String, dynamic>) {
      return decoded['meta'] as Map<String, dynamic>;
    }
    return const {};
  }

  static ApiFailure<T> failureFrom<T>(ApiFailure<dynamic> res) =>
      ApiFailure(res.message, statusCode: res.statusCode);
}
