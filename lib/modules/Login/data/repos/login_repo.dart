import '../model/login_response.dart';

abstract class LoginRepo {
  Future<LoginModel> loginUser({required String username, required String password, bool? rememberMe});
  Future<LoginModel> getMe();

  /// Invalidates [refreshToken] server-side. Without this, a manually logged
  /// out session's refresh token stays valid indefinitely — a real risk on
  /// shared clinic devices.
  Future<void> logout({required String refreshToken});

  /// Invalidates every refresh token issued to the current user.
  Future<void> logoutAll();
}
