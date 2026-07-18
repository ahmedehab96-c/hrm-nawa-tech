import 'package:hrm_saas/core/api/api_client.dart';
import 'package:hrm_saas/core/api/api_config.dart';
import 'package:hrm_saas/core/api/api_result.dart';

class DeviceTokenRepository {
  const DeviceTokenRepository._();

  static Future<ApiResult<void>> register({
    required String token,
    required String platform,
  }) async {
    await ApiConfig.load();
    if (!ApiConfig.useApi || ApiConfig.baseUrl == null || ApiConfig.baseUrl!.isEmpty) {
      return const ApiSuccess(null);
    }

    final res = await ApiClient.post(
      'device-tokens',
      body: {
        'token': token,
        'platform': platform,
      },
    );

    if (res is ApiFailure<dynamic>) {
      return ApiFailure(
        (res as ApiFailure<dynamic>).message,
        statusCode: (res as ApiFailure<dynamic>).statusCode,
      );
    }

    return const ApiSuccess(null);
  }
}
