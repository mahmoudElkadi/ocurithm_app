import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:ocurithm/core/Network/shared.dart';

import '../../../../../Main/presentation/views/main_view.dart';
import '../../../../../core/utils/colors.dart';
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
    try {
      var response = await loginRepo.loginUser(username: username, password: password, rememberMe: true);

      if (response.message == "Logged in successfully") {
        if (response.user != null) {
          await CacheHelper.saveUser("user", response.user!);
          await CacheHelper.saveString(key: "token", value: response.token);
        }
        List<String>? capabilities = CacheHelper.getUser("user")!.capabilities.map((obj) => obj.name).cast<String>().toList();
        await CacheHelper.saveStringList(key: "capabilities", value: capabilities);
        Get.to(() => const MainView());
        isLoading = false;
        emit(LoginUserSuccess());
      } else if (response.message != null) {
        _showPopup(context, "${response.message}", "Login Failed");
        isLoading = false;
        emit(LoginUserFailed());
      } else {
        isLoading = false;
        _showPopup(context, "Login Failed", "Please check your credentials");
        emit(LoginUserFailed());
      }
    } catch (e) {
      isLoading = false;
      _showPopup(context, "Error", "An error occurred during login");
      emit(LoginUserFailed());
    }
  }

  void _showPopup(BuildContext context, String title, String content) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.0),
          ),
          elevation: 10,
          backgroundColor: Colors.transparent,
          child: Container(
            padding: EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 10,
                  spreadRadius: 5,
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Icon for the popup
                Icon(
                  Icons.error_outline,
                  color: Colorz.primaryColor,
                  size: 50,
                ),
                SizedBox(height: 20),
                // Title
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colorz.primaryColor,
                  ),
                ),
                SizedBox(height: 10),
                // Content
                Text(
                  content,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[700],
                  ),
                ),
                SizedBox(height: 20),
                // Close button
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop(); // Close the dialog
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colorz.primaryColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    padding: EdgeInsets.symmetric(horizontal: 30, vertical: 12),
                  ),
                  child: Text(
                    "OK",
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
