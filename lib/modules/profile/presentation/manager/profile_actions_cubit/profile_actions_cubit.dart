import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../data/models/profile_models.dart';
import '../../../data/repos/profile_repo.dart';

part 'profile_actions_state.dart';
part 'profile_actions_event.dart';

class ProfileActionsCubit
    extends Bloc<ProfileActionsEvent, ProfileActionsState> {
  final ProfileRepo profileRepo;

  ProfileActionsCubit(this.profileRepo) : super(const ProfileActionsState()) {
    on<UpdateProfileEvent>(_onUpdateProfile);
    on<ChangePasswordEvent>(_onChangePassword);
    on<ResetProfileActionsEvent>(_onResetProfileActions);
  }

  static ProfileActionsCubit get(BuildContext context) =>
      BlocProvider.of(context);

  Future<void> _onUpdateProfile(
      UpdateProfileEvent event, Emitter<ProfileActionsState> emit) async {
    try {
      emit(state.copyWith(
        state: ProfileActionsStatus.loading,
        actionType: ProfileActionType.updateProfile,
      ));

      final result = await profileRepo.updateProfile(
        name: event.name,
        email: event.email,
        phone: event.phone,
      );

      if (result.success) {
        emit(state.copyWith(
          state: ProfileActionsStatus.success,
          actionType: ProfileActionType.updateProfile,
          successMessage: 'Profile Updated Successfully',
          profile: result.data,
        ));
      } else {
        emit(state.copyWith(
          state: ProfileActionsStatus.error,
          actionType: ProfileActionType.updateProfile,
          errorMessage: result.message ?? 'Failed to update profile',
        ));
      }
    } catch (e) {
      if (e.toString().toLowerCase().contains('no internet connection')) {
        emit(state.copyWith(
          state: ProfileActionsStatus.noConnection,
          actionType: ProfileActionType.updateProfile,
          errorMessage: e.toString(),
        ));
        return;
      }
      emit(state.copyWith(
        state: ProfileActionsStatus.error,
        actionType: ProfileActionType.updateProfile,
        errorMessage: e.toString(),
      ));
    }
  }

  Future<void> _onChangePassword(
      ChangePasswordEvent event, Emitter<ProfileActionsState> emit) async {
    try {
      emit(state.copyWith(
        state: ProfileActionsStatus.loading,
        actionType: ProfileActionType.changePassword,
      ));

      final result = await profileRepo.changePassword(
        currentPassword: event.currentPassword,
        newPassword: event.newPassword,
        confirmPassword: event.confirmPassword,
      );

      if (result.success) {
        emit(state.copyWith(
          state: ProfileActionsStatus.success,
          actionType: ProfileActionType.changePassword,
          successMessage: 'Password Changed Successfully',
        ));
      } else {
        emit(state.copyWith(
          state: ProfileActionsStatus.error,
          actionType: ProfileActionType.changePassword,
          errorMessage: result.message ?? 'Failed to change password',
        ));
      }
    } catch (e) {
      if (e.toString().toLowerCase().contains('no internet connection')) {
        emit(state.copyWith(
          state: ProfileActionsStatus.noConnection,
          actionType: ProfileActionType.changePassword, 
          errorMessage: e.toString(),
        ));
        return;
      }
      emit(state.copyWith(
        state: ProfileActionsStatus.error,
        actionType: ProfileActionType.changePassword,
        errorMessage: e.toString(),
      ));
    }
  }

  Future<void> _onResetProfileActions(
      ResetProfileActionsEvent event, Emitter<ProfileActionsState> emit) async {
    emit(const ProfileActionsState());
  }
}
