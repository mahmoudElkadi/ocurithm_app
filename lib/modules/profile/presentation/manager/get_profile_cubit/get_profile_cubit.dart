import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../data/models/profile_models.dart';
import '../../../data/repos/profile_repo.dart';

part 'get_profile_state.dart';
part 'get_profile_event.dart';

class GetProfileCubit extends Bloc<GetProfileEvent, GetProfileState> {
  final ProfileRepo profileRepo;

  GetProfileCubit(this.profileRepo) : super(const GetProfileState()) {
    on<FetchProfileEvent>(_onFetchProfile);
    on<UpdateProfileSuccessEvent>(_onUpdateProfileSuccess);
  }

  void _onUpdateProfileSuccess(
      UpdateProfileSuccessEvent event, Emitter<GetProfileState> emit) {
    emit(state.copyWith(profile: event.profile));
  }

  static GetProfileCubit get(BuildContext context) => BlocProvider.of(context);

  Future<void> _onFetchProfile(
      FetchProfileEvent event, Emitter<GetProfileState> emit) async {
    try {
      emit(state.copyWith(state: GetProfileStatus.loading));

      final result = await profileRepo.getProfile();

      if (result.success && result.data != null) {
        emit(state.copyWith(
          state: GetProfileStatus.success,
          profile: result.data,
        ));
      } else {
        emit(state.copyWith(
          state: GetProfileStatus.error,
          errorMessage: result.message ?? 'Failed to fetch profile',
        ));
      }
    } catch (e) {
      log('EEERRR '+ e.toString());
      if (e.toString().toLowerCase().contains('no internet connection')) {
        emit(state.copyWith(
          state: GetProfileStatus.noConnection,
          errorMessage: e.toString(),
        ));
        return;
      }
      emit(state.copyWith(
        state: GetProfileStatus.error,
        errorMessage: e.toString(),
      ));
    }
  }
}
