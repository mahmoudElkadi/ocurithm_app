part of 'profile_actions_cubit.dart';

@immutable
abstract class ProfileActionsEvent {}

class UpdateProfileEvent extends ProfileActionsEvent {
  final String? name;
  final String? email;
  final String? phone;
  final String? image;
  final bool removeImage;

  UpdateProfileEvent({
    this.name,
    this.email,
    this.phone,
    this.image,
    this.removeImage = false,
  });
}

class ChangePasswordEvent extends ProfileActionsEvent {
  final String currentPassword;
  final String newPassword;
  final String confirmPassword;

  ChangePasswordEvent({
    required this.currentPassword,
    required this.newPassword,
    required this.confirmPassword,
  });
}

class ResetProfileActionsEvent extends ProfileActionsEvent {}
