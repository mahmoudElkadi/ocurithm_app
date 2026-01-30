part of 'profile_actions_cubit.dart';

enum ProfileActionsStatus { initial, loading, success, error, noConnection }

enum ProfileActionType { none, updateProfile, changePassword }

extension ProfileActionsStatusX on ProfileActionsState {
  bool get isInitial => state == ProfileActionsStatus.initial;
  bool get isLoading => state == ProfileActionsStatus.loading;
  bool get isSuccess => state == ProfileActionsStatus.success;
  bool get isError => state == ProfileActionsStatus.error;
  bool get noConnection => state == ProfileActionsStatus.noConnection;
}

@immutable
class ProfileActionsState {
  final ProfileActionsStatus state;
  final ProfileActionType actionType;
  final String? errorMessage;
  final String? successMessage;

  const ProfileActionsState({
    this.state = ProfileActionsStatus.initial,
    this.actionType = ProfileActionType.none,
    this.errorMessage,
    this.successMessage,
    this.profile,
  });

  final ProfileModel? profile;

  ProfileActionsState copyWith({
    ProfileActionsStatus? state,
    ProfileActionType? actionType,
    String? errorMessage,
    String? successMessage,
    ProfileModel? profile,
  }) {
    return ProfileActionsState(
      state: state ?? this.state,
      actionType: actionType ?? this.actionType,
      errorMessage: errorMessage ?? this.errorMessage,
      successMessage: successMessage ?? this.successMessage,
      profile: profile ?? this.profile,
    );
  }
}
