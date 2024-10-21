import 'dart:convert';
import 'dart:developer';
import 'dart:ui';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:ocurithm/core/utils/config.dart';
import '../../../../core/Network/shared.dart';
import '../model/login_response.dart';
import 'login_repo.dart';

class LoginRepoImpl implements LoginRepo {
  @override
  Future<dynamic> loginUser(String username, String password) async {
    try {
      Map<String, String> body = {
        "username": username,
        "password": password,
      };

      var uri = Uri.parse("${Config.baseUrl}login");

      http.Response response = await http.post(uri, body: body);
      log(response.body);

      if (response.statusCode == 200) {
        String? token = LoginModel.fromJson(jsonDecode(response.body)).token;

        String? role =
            LoginModel.fromJson(jsonDecode(response.body)).user!.role;

        String? name =
            LoginModel.fromJson(jsonDecode(response.body)).user!.fullName;
        String? userId =
            LoginModel.fromJson(jsonDecode(response.body)).user!.userId;

        String? branch =
            LoginModel.fromJson(jsonDecode(response.body)).user!.branch;

        await CacheHelper.saveString(key: "token", value: token);
        await CacheHelper.saveString(key: "role", value: role);
        await CacheHelper.saveString(key: "name", value: name);
        await CacheHelper.saveString(key: "id", value: userId);
        if (role == "doctor") {
          await CacheHelper.saveBoolean(key: "arabic", value: false);
          Get.updateLocale(const Locale('en'));
        }
        if (branch != null) {
          await CacheHelper.saveString(key: "branch", value: branch);
        }
        log("token: $token");
        return 0;
      } else if (response.statusCode == 401) {
        return LoginModel.fromJson(jsonDecode(response.body)).message;
      } else {
        return 1;
      }
    } catch (e) {
      throw Exception(e);
    }
    return 1;
  }
}
