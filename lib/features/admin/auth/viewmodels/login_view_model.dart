import '../../../../core/api/api_result.dart';
import '../../../../core/auth/user_role.dart';
import '../../../../core/mvvm/view_model.dart';
import '../../../../core/repositories/auth_repository.dart';

class LoginResult {
  const LoginResult._({this.homeRoute, this.errorMessage});

  final String? homeRoute;
  final String? errorMessage;

  bool get isSuccess => homeRoute != null;

  factory LoginResult.success(String homeRoute) =>
      LoginResult._(homeRoute: homeRoute);

  factory LoginResult.failure(String message) =>
      LoginResult._(errorMessage: message);
}

/// ViewModel for admin / platform web login.
class LoginViewModel extends ViewModel {
  bool isLoading = false;
  bool obscurePassword = true;

  void toggleObscurePassword() {
    update(() => obscurePassword = !obscurePassword);
  }

  Future<LoginResult> submit({
    required String email,
    required String password,
  }) async {
    update(() => isLoading = true);
    final result = await AuthRepository.login(
      email,
      password,
      surface: LoginSurface.webAdmin,
    );
    if (isDisposed) return LoginResult.failure('');

    update(() => isLoading = false);

    if (result is ApiSuccess<Map<String, dynamic>>) {
      final user = result.data['user'] as Map<String, dynamic>? ?? {};
      final role = user['role']?.toString();
      return LoginResult.success(UserRole.webHomeFor(role));
    }

    return LoginResult.failure((result as ApiFailure<dynamic>).message);
  }
}
