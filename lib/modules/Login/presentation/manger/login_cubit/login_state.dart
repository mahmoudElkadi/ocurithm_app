part of 'login_cubit.dart';

enum LoginStatus { initial, loading, success, error }

extension LoginStatusX on LoginState {
  bool get isInitial => status == LoginStatus.initial;
  bool get isLoading => status == LoginStatus.loading;
  bool get isSuccess => status == LoginStatus.success;
  bool get isError => status == LoginStatus.error;
}

@immutable
class LoginState {
  final LoginStatus status;
  final String? errorMessage;
  final bool obscureText;
  final LoginModel? loginModel;

  const LoginState({
    this.status = LoginStatus.initial,
    this.errorMessage,
    this.obscureText = true,
    this.loginModel,
  });

  LoginState copyWith({
    LoginStatus? status,
    String? errorMessage,
    bool? obscureText,
    LoginModel? loginModel,
  }) {
    return LoginState(
      status: status ?? this.status,
      errorMessage: errorMessage ?? this.errorMessage,
      obscureText: obscureText ?? this.obscureText,
      loginModel: loginModel ?? this.loginModel,
    );
  }
}
