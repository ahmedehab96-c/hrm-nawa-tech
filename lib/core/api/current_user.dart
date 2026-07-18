import '../session/token_store.dart';

Future<String?> currentUserDisplayName() async {
  final u = await TokenStore.getUser();
  if (u == null) return null;
  return u['name']?.toString() ?? u['email']?.toString();
}
