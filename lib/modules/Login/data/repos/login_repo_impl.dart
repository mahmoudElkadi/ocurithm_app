import 'dart:developer';

import 'package:ocurithm/core/utils/config.dart';
import 'package:ocurithm/modules/Login/data/model/login_response.dart';

import '../../../../core/Network/dio_handler.dart';
import 'login_repo.dart';

class LoginRepoImpl extends LoginRepo {
  @override
  Future<LoginModel> loginUser({required String username, required String password, bool? rememberMe}) async {
    final url = "${Config.baseUrl}${Config.login}";
    Map<String, dynamic> data = {"username": username, "password": password, "rememberMe": rememberMe};
    log(url.toString());
    final result = await ApiService.request<LoginModel>(
      url: url,
      data: data,
      method: 'POST',
      showError: true,
      fromJson: (json) => LoginModel.fromJson(json),
    );

    if (result != null) {
      return result;
    } else {
      throw Exception("Failed to Login");
    }
  }
}
