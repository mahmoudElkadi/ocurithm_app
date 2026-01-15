part of 'login_cubit.dart';

@immutable
abstract class LoginEvent {}

class LoginUserEvent extends LoginEvent {
  final String username;
  final String password;
  final bool rememberMe;

  LoginUserEvent(
      {required this.username, required this.password, this.rememberMe = true});
}

class ToggleObscureTextEvent extends LoginEvent {}
