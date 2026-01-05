import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ocurithm/modules/Receptionist/data/models/add_reception_model.dart';
import 'package:ocurithm/modules/Receptionist/data/repos/receptionist_repo.dart';

import '../../../data/models/receptionists_model.dart';

part 'get_single_receptionist_state.dart';
part 'get_single_receptionist_event.dart';

/// Cubit for fetching a single receptionist by ID
/// Used in edit and view modes
class GetSingleReceptionistCubit
    extends Bloc<GetSingleReceptionistEvent, GetSingleReceptionistState> {
  final ReceptionistRepo receptionistRepo;

  GetSingleReceptionistCubit(this.receptionistRepo)
      : super(const GetSingleReceptionistState()) {
    on<GetReceptionistByIdEvent>(_onGetReceptionistById);
    on<ResetSingleReceptionistEvent>(_onResetSingleReceptionist);
  }

  static GetSingleReceptionistCubit get(BuildContext context) =>
      BlocProvider.of(context);

  // Get Receptionist by ID
  Future<void> _onGetReceptionistById(GetReceptionistByIdEvent event,
      Emitter<GetSingleReceptionistState> emit) async {
    try {
      emit(state.copyWith(state: GetSingleReceptionistStatus.loading));

      final receptionist =
          await receptionistRepo.getReceptionist(id: event.receptionistId);

      if (receptionist.error == null) {
        emit(state.copyWith(
          state: GetSingleReceptionistStatus.success,
          receptionist: receptionist,
        ));
      } else {
        emit(state.copyWith(
          state: GetSingleReceptionistStatus.error,
          errorMessage: receptionist.error ?? 'Failed to load receptionist',
        ));
      }
    } catch (e) {
      if (e.toString().toLowerCase().contains('no internet connection')) {
        emit(state.copyWith(
          state: GetSingleReceptionistStatus.noConnection,
          errorMessage: e.toString(),
        ));
        return;
      }
      if (e.toString().toLowerCase().contains('request cancelled')) {
        return;
      }
      emit(state.copyWith(
        state: GetSingleReceptionistStatus.error,
        errorMessage: e.toString(),
      ));
    }
  }

  // Reset Single Receptionist
  Future<void> _onResetSingleReceptionist(ResetSingleReceptionistEvent event,
      Emitter<GetSingleReceptionistState> emit) async {
    emit(const GetSingleReceptionistState());
  }
}
