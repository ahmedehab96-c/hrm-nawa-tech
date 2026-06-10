import 'api_config.dart';

Future<String?> currentUserDisplayName() async {
  final u = await ApiConfig.getUser();
  if (u == null) return null;
  return u['name']?.toString() ?? u['email']?.toString();
}
