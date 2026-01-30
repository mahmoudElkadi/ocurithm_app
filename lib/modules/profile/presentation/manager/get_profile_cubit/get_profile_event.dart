part of 'get_profile_cubit.dart';

@immutable
abstract class GetProfileEvent {}

class FetchProfileEvent extends GetProfileEvent {}

class UpdateProfileSuccessEvent extends GetProfileEvent {
  final ProfileModel profile;
  UpdateProfileSuccessEvent(this.profile);
}
