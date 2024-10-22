import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:ocurithm/core/Network/shared.dart';
import 'package:ocurithm/core/utils/colors.dart';

import '../../../../../Main/presentation/views/main_view.dart';
import '../../../data/repos/login_repo.dart';
import 'login_state.dart';

class LoginCubit extends Cubit<LoginState> {
  LoginCubit(this.loginRepo) : super(LoginInitial());

  static LoginCubit get(context) => BlocProvider.of(context);

  LoginRepo loginRepo;

  bool _obscureText = true;

  bool get obscureText => _obscureText;

  set obscureText(bool newState) {
    _obscureText = newState;
    emit(ObscureText());
  }

  bool isLoading = false;

  void loading() {
    isLoading = true;
    emit(LoadingSuccess());
  }

  userLogin({context, required String username, required String password}) async {
    isLoading = true;
    emit(LoginUserLoading());

    var response = await loginRepo.loginUser(username: username, password: password, rememberMe: true);

    if (response.message == "Logged in successfully") {
      if (response.user != null) {
        await CacheHelper.saveUser("user", response.user!);
        await CacheHelper.saveString(key: "token", value: response.token);
        log("login user: ${CacheHelper.getUser("user")?.name}");
      }
      Get.to(() => MainView(capabilities: CacheHelper.getUser("user")?.capabilities ?? []));
      isLoading = false;
    } else if (response.message != null) {
      Get.snackbar("${response.message}", "Login Failed",
          colorText: Colors.white, backgroundColor: Colors.red, icon: Icon(Icons.add_alert, color: Colorz.white));
      isLoading = false;
    } else {
      isLoading = false;
      Get.snackbar("Login Failed", "Please check your credentials",
          colorText: Colors.white,
          backgroundColor: Colors.red,
          icon: Icon(
            Icons.add_alert,
            color: Colorz.white,
          ));
    }

    // loginRepo.loginUser(username, password).then((response) {
    //   log("in success: $response");
    //
    //   if (response == 0) {
    //     if (CacheHelper.getData(key: "role") == "receptionist") {
    //       //   Get.off(() => const MainView());
    //     } else {
    //       //    Get.off(() => const HomeView());
    //     }
    //   } else if (response != 1) {
    //     isLoading = false;
    //     Get.snackbar(response.toString(), "signIn Failed", colorText: Colors.white, backgroundColor: Colors.red, icon: const Icon(Icons.add_alert));
    //   } else {
    //     isLoading = false;
    //
    //     Get.snackbar("sign In Failed", "Please check your credentials",
    //         colorText: Colors.white, backgroundColor: Colors.red, icon: const Icon(Icons.add_alert));
    //   }
    emit(LoginUserSuccess());
  }
}
