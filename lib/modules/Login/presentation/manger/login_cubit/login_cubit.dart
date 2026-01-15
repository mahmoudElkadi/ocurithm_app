import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../../core/Network/shared.dart';
import '../../../data/model/login_response.dart';
import '../../../data/repos/login_repo.dart';

part 'login_state.dart';
part 'login_event.dart';

class LoginCubit extends Bloc<LoginEvent, LoginState> {
  final LoginRepo loginRepo;

  LoginCubit(this.loginRepo) : super(const LoginState()) {
    on<LoginUserEvent>(_onLoginUser);
    on<ToggleObscureTextEvent>(_onToggleObscureText);
  }

  static LoginCubit get(context) => BlocProvider.of(context);

  Future<void> _onLoginUser(
      LoginUserEvent event, Emitter<LoginState> emit) async {
    emit(state.copyWith(status: LoginStatus.loading));
    try {
      final response = await loginRepo.loginUser(
        username: event.username,
        password: event.password,
        rememberMe: event.rememberMe,
      );

        if (response.user != null) {
          await CacheHelper.saveUser("user", response.user!);
          await CacheHelper.saveString(key: "token", value: response.accessToken);
          await CacheHelper.saveString(key: "refreshToken", value: response.refreshToken);
        }

        if (response.user?.capabilities != null) {
          await CacheHelper.saveStringList(
              key: "capabilities", value: response.user!.capabilities);
        }

        emit(state.copyWith(status: LoginStatus.success, loginModel: response));

    } catch (e) {
      emit(state.copyWith(
          status: LoginStatus.error, errorMessage: e.toString()));
    }
  }

  void _onToggleObscureText(
      ToggleObscureTextEvent event, Emitter<LoginState> emit) {
    emit(state.copyWith(obscureText: !state.obscureText));
  }
}
