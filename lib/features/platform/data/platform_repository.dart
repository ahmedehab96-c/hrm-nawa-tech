import 'dart:convert';

import '../../../core/api/api_client.dart';
import '../../../core/api/api_config.dart';
import '../../../core/api/api_localized.dart';
import '../../../core/api/api_result.dart';
import '../models/platform_models.dart';

/// Model / data layer for platform (super_admin) APIs.
class PlatformRepository {
  const PlatformRepository();

  Future<ApiResult<PlatformOverview>> overview() async {
    await ApiConfig.load();
    final l10n = ApiLocalized.strings;
    final res = await ApiClient.get('platform/overview');
    if (res is ApiFailure<dynamic>) {
      return ApiFailure(
        (res as ApiFailure<dynamic>).message,
        statusCode: (res as ApiFailure<dynamic>).statusCode,
      );
    }
    try {
      final map = jsonDecode((res as ApiSuccess).data.body) as Map<String, dynamic>;
      return ApiSuccess(PlatformOverview.fromJson(map));
    } catch (e) {
      return ApiFailure(l10n.apiReadResponseFailed(e.toString()));
    }
  }

  Future<ApiResult<List<PlatformCompany>>> companies({
    String? status,
    String? plan,
    String? search,
  }) async {
    await ApiConfig.load();
    final l10n = ApiLocalized.strings;
    final q = <String, String>{};
    if (status != null && status.isNotEmpty) q['status'] = status;
    if (plan != null && plan.isNotEmpty) q['plan'] = plan;
    if (search != null && search.isNotEmpty) q['search'] = search;
    final query = q.isEmpty
        ? ''
        : '?${q.entries.map((e) => '${Uri.encodeQueryComponent(e.key)}=${Uri.encodeQueryComponent(e.value)}').join('&')}';
    final res = await ApiClient.get('platform/companies$query');
    if (res is ApiFailure<dynamic>) {
      return ApiFailure(
        (res as ApiFailure<dynamic>).message,
        statusCode: (res as ApiFailure<dynamic>).statusCode,
      );
    }
    try {
      final map = jsonDecode((res as ApiSuccess).data.body) as Map<String, dynamic>;
      final list = (map['data'] as List? ?? [])
          .whereType<Map>()
          .map((e) => PlatformCompany.fromJson(Map<String, dynamic>.from(e)))
          .toList();
      return ApiSuccess(list);
    } catch (e) {
      return ApiFailure(l10n.apiReadResponseFailed(e.toString()));
    }
  }

  Future<ApiResult<PlatformCompany>> updateCompany(
    String id, {
    String? status,
    String? plan,
    int? extendTrialDays,
  }) async {
    await ApiConfig.load();
    final l10n = ApiLocalized.strings;
    final body = <String, dynamic>{};
    if (status != null) body['status'] = status;
    if (plan != null) body['plan'] = plan;
    if (extendTrialDays != null) body['extend_trial_days'] = extendTrialDays;
    final res = await ApiClient.put('platform/companies/$id', body: body);
    if (res is ApiFailure<dynamic>) {
      return ApiFailure(
        (res as ApiFailure<dynamic>).message,
        statusCode: (res as ApiFailure<dynamic>).statusCode,
      );
    }
    try {
      final map = jsonDecode((res as ApiSuccess).data.body) as Map<String, dynamic>;
      final data = Map<String, dynamic>.from(map['data'] as Map? ?? map);
      return ApiSuccess(PlatformCompany.fromJson(data));
    } catch (e) {
      return ApiFailure(l10n.apiReadResponseFailed(e.toString()));
    }
  }

  Future<ApiResult<Map<String, dynamic>>> activatePlanManual(
    String companyId,
    String plan,
  ) async {
    await ApiConfig.load();
    final l10n = ApiLocalized.strings;
    final res = await ApiClient.post(
      'platform/companies/$companyId/checkout',
      body: {'plan': plan, 'provider': 'manual'},
    );
    if (res is ApiFailure<dynamic>) {
      return ApiFailure(
        (res as ApiFailure<dynamic>).message,
        statusCode: (res as ApiFailure<dynamic>).statusCode,
      );
    }
    try {
      final map = jsonDecode((res as ApiSuccess).data.body) as Map<String, dynamic>;
      return ApiSuccess(map);
    } catch (e) {
      return ApiFailure(l10n.apiReadResponseFailed(e.toString()));
    }
  }
}
