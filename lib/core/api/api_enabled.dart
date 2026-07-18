import 'api_config.dart';

/// True when the app should call the Laravel API (not demo mode).
bool get isApiEnabled =>
    ApiConfig.useApi &&
    ApiConfig.baseUrl != null &&
    ApiConfig.baseUrl!.isNotEmpty;
