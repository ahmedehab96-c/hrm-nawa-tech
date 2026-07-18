import 'package:flutter_test/flutter_test.dart';
import 'package:hrm_saas/core/session/token_store.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
  });

  test('stores and reads user as JSON booleans', () async {
    await TokenStore.setUser({
      'email': 'a@b.com',
      'email_verified': false,
      'role': 'employee',
    });
    final user = await TokenStore.getUser();
    expect(user?['email'], 'a@b.com');
    expect(user?['email_verified'], false);
    expect(user?['role'], 'employee');
  });

  test('migrates legacy pipe-encoded user', () async {
    SharedPreferences.setMockInitialValues({
      'auth_user': 'email:old@x.com|role:employee|email_verified:true',
    });
    final user = await TokenStore.getUser();
    expect(user?['email'], 'old@x.com');
    expect(user?['role'], 'employee');
    expect(user?['email_verified'], 'true');
  });

  test('clear removes token and user prefs', () async {
    await TokenStore.setUser({'email': 'x@y.com'});
    await TokenStore.clear();
    expect(await TokenStore.getUser(), isNull);
  });
}
