import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ocurithm/modules/Clinics/data/model/clinics_model.dart';
import 'package:ocurithm/modules/Clinics/data/repos/clinic_repo.dart';

part 'clinic_actions_state.dart';
part 'clinic_actions_event.dart';

class ClinicActionsCubit extends Bloc<ClinicActionsEvent, ClinicActionsState> {
  final ClinicRepo clinicRepo;

  ClinicActionsCubit(this.clinicRepo) : super(const ClinicActionsState()) {
    on<AddClinicEvent>(_onAddClinic);
    on<UpdateClinicEvent>(_onUpdateClinic);
    on<DeleteClinicEvent>(_onDeleteClinic);
    on<ResetClinicActionsEvent>(_onResetClinicActions);
  }

  static ClinicActionsCubit get(BuildContext context) =>
      BlocProvider.of(context);

  // Add Clinic
  Future<void> _onAddClinic(
      AddClinicEvent event, Emitter<ClinicActionsState> emit) async {
    try {
      emit(state.copyWith(
        state: ClinicActionsStatus.loading,
        actionType: ClinicActionType.add,
      ));

      final result = await clinicRepo.createClinic(clinic: event.clinic);

      if (result.error == null && (result.name != null || result.id != null)) {
        emit(state.copyWith(
          state: ClinicActionsStatus.success,
          actionType: ClinicActionType.add,
          successMessage: 'Clinic Added Successfully',
          clinic: result,
        ));
      } else {
        emit(state.copyWith(
          state: ClinicActionsStatus.error,
          actionType: ClinicActionType.add,
          errorMessage: result.error ?? 'Failed to add clinic',
        ));
      }
    } catch (e) {

      if (e.toString().toLowerCase().contains('request cancelled')) {
        return;
      }
      emit(state.copyWith(
        state: ClinicActionsStatus.error,
        actionType: ClinicActionType.add,
        errorMessage: e.toString(),
      ));
    }
  }

  // Update Clinic
  Future<void> _onUpdateClinic(
      UpdateClinicEvent event, Emitter<ClinicActionsState> emit) async {
    try {
      emit(state.copyWith(
        state: ClinicActionsStatus.loading,
        actionType: ClinicActionType.update,
      ));

      final result = await clinicRepo.updateClinic(
        id: event.clinicId,
        clinic: event.clinic,
      );

      if (result.error == null && (result.name != null || result.id != null)) {
        emit(state.copyWith(
          state: ClinicActionsStatus.success,
          actionType: ClinicActionType.update,
          successMessage: 'Clinic Updated Successfully',
          clinic: result,
        ));
      } else {
        emit(state.copyWith(
          state: ClinicActionsStatus.error,
          actionType: ClinicActionType.update,
          errorMessage: result.error ?? 'Failed to update clinic',
        ));
      }
    } catch (e) {

      if (e.toString().toLowerCase().contains('request cancelled')) {
        return;
      }
      emit(state.copyWith(
        state: ClinicActionsStatus.error,
        actionType: ClinicActionType.update,
        errorMessage: e.toString(),
      ));
    }
  }

  // Delete Clinic
  Future<void> _onDeleteClinic(
      DeleteClinicEvent event, Emitter<ClinicActionsState> emit) async {
    try {
      emit(state.copyWith(
        state: ClinicActionsStatus.loading,
        actionType: ClinicActionType.delete,
      ));

      final result = await clinicRepo.deleteClinic(id: event.clinicId);

      if (result.error == null && result.message != null) {
        emit(state.copyWith(
          state: ClinicActionsStatus.success,
          actionType: ClinicActionType.delete,
          successMessage: result.message,
        ));
      } else {
        emit(state.copyWith(
          state: ClinicActionsStatus.error,
          actionType: ClinicActionType.delete,
          errorMessage: result.error ?? 'Failed to delete clinic',
        ));
      }
    } catch (e) {

      if (e.toString().toLowerCase().contains('request cancelled')) {
        return;
      }
      emit(state.copyWith(
        state: ClinicActionsStatus.error,
        actionType: ClinicActionType.delete,
        errorMessage: e.toString(),
      ));
    }
  }

  // Reset Clinic Actions
  Future<void> _onResetClinicActions(
      ResetClinicActionsEvent event, Emitter<ClinicActionsState> emit) async {
    emit(const ClinicActionsState());
  }
}
