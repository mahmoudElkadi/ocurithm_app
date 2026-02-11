import '../model/login_response.dart';

abstract class LoginRepo {
  Future<LoginModel> loginUser({required String username, required String password, bool? rememberMe});
  Future<LoginModel> getMe();
}
