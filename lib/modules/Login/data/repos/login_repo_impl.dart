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

    if (result.data != null) {
      return result.data!;
    } else {
      throw Exception(result.message ?? "Failed to Login");
    }
  }
}
