import 'dart:convert';

import '../api/api_client.dart';
import '../api/api_config.dart';
import '../api/api_localized.dart';
import '../api/api_result.dart';

/// Company-admin billing scaffold (Stripe/Moyasar later).
class BillingRepository {
  const BillingRepository();

  Future<ApiResult<Map<String, dynamic>>> requestCheckout({
    required String plan,
    String provider = 'stripe',
  }) async {
    await ApiConfig.load();
    final l10n = ApiLocalized.strings;
    final res = await ApiClient.post(
      'billing/checkout',
      body: {'plan': plan, 'provider': provider},
    );
    if (res is ApiFailure<dynamic>) {
      return ApiFailure(
        (res as ApiFailure<dynamic>).message,
        statusCode: (res as ApiFailure<dynamic>).statusCode,
        code: (res as ApiFailure<dynamic>).code,
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
