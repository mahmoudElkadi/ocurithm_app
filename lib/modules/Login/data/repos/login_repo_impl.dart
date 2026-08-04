import '../../../../../core/api/api_handler.dart';
import '../../../../core/api/api_constants.dart';
import '../model/login_response.dart';
import 'login_repo.dart';

class LoginRepoImpl extends LoginRepo {
  @override
  Future<LoginModel> loginUser(
      {required String username,
      required String password,
      bool? rememberMe}) async {
    final url = "${ApiConstants.baseUrl}${ApiConstants.login}";
    Map<String, dynamic> data = {
      "username": username,
      "password": password,
      "rememberMe": rememberMe
    };

    final result = await ApiHandler().post<LoginModel>(
      url,
      data: data,
      fromJson: (json) => LoginModel.fromJson(json),
    );

    if (result.success && result.data != null) {
      return result.data!;
    } else {
      throw Exception(result.message ?? "Failed to Login");
    }
  }

  @override
  Future<void> logout({required String refreshToken}) async {
    await ApiHandler().post(
      ApiConstants.logout,
      data: {"refreshToken": refreshToken},
    );
    // Best-effort: the caller clears local state regardless of the result.
  }

  @override
  Future<void> logoutAll() async {
    await ApiHandler().post(ApiConstants.logoutAll);
  }

  @override
  Future<LoginModel> getMe() async {
    final result = await ApiHandler().get<LoginModel>(
      ApiConstants.me,
      fromJson: (json) => LoginModel(
        accessToken: null,
        refreshToken: null,
        expiresIn: null,
        user: User.fromJson(json),
      ),
    );

    if (result.success && result.data != null) {
      return result.data!;
    } else {
      throw Exception(result.message ?? "Failed to get user data");
    }
  }
}
