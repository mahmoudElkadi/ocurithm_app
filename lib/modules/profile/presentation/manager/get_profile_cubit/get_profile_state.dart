part of 'get_profile_cubit.dart';

enum GetProfileStatus { initial, loading, success, error, noConnection }

extension GetProfileStatusX on GetProfileState {
  bool get isInitial => state == GetProfileStatus.initial;
  bool get isLoading => state == GetProfileStatus.loading;
  bool get isSuccess => state == GetProfileStatus.success;
  bool get isError => state == GetProfileStatus.error;
  bool get noConnection => state == GetProfileStatus.noConnection;
}

@immutable
class GetProfileState {
  final GetProfileStatus state;
  final String? errorMessage;
  final ProfileModel? profile;

  const GetProfileState({
    this.state = GetProfileStatus.initial,
    this.errorMessage,
    this.profile,
  });

  GetProfileState copyWith({
    GetProfileStatus? state,
    String? errorMessage,
    ProfileModel? profile,
  }) {
    return GetProfileState(
      state: state ?? this.state,
      errorMessage: errorMessage ?? this.errorMessage,
      profile: profile ?? this.profile,
    );
  }
}
