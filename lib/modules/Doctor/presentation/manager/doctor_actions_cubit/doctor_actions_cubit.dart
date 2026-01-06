import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ocurithm/modules/Doctor/data/model/doctor_model.dart';
import 'package:ocurithm/modules/Doctor/data/repos/doctor_repo.dart';

part 'doctor_actions_state.dart';
part 'doctor_actions_event.dart';

/// Cubit for handling doctor actions (add, update, delete)
/// Follows the clean architecture pattern used in Branch and Clinic modules
class DoctorActionsCubit extends Bloc<DoctorActionsEvent, DoctorActionsState> {
  final DoctorRepo doctorRepo;

  DoctorActionsCubit(this.doctorRepo) : super(const DoctorActionsState()) {
    on<AddDoctorEvent>(_onAddDoctor);
    on<UpdateDoctorEvent>(_onUpdateDoctor);
    on<DeleteDoctorEvent>(_onDeleteDoctor);
    on<ResetDoctorActionsEvent>(_onResetDoctorActions);
  }

  static DoctorActionsCubit get(BuildContext context) =>
      BlocProvider.of(context);

  // Add Doctor
  Future<void> _onAddDoctor(
      AddDoctorEvent event, Emitter<DoctorActionsState> emit) async {
    try {
      emit(state.copyWith(
        state: DoctorActionsStatus.loading,
        actionType: DoctorActionType.add,
      ));

      final result = await doctorRepo.createDoctor(doctor: event.doctor);

      if (result.error == null && (result.name != null || result.id != null)) {
        emit(state.copyWith(
          state: DoctorActionsStatus.success,
          actionType: DoctorActionType.add,
          successMessage: 'Doctor Added Successfully',
          doctor: result,
        ));
      } else {
        emit(state.copyWith(
          state: DoctorActionsStatus.error,
          actionType: DoctorActionType.add,
          errorMessage: result.error ?? 'Failed to add doctor',
        ));
      }
    } catch (e) {
      if (e.toString().toLowerCase().contains('no internet connection')) {
        emit(state.copyWith(
          state: DoctorActionsStatus.noConnection,
          actionType: DoctorActionType.add,
          errorMessage: e.toString(),
        ));
        return;
      }
      if (e.toString().toLowerCase().contains('request cancelled')) {
        return;
      }
      emit(state.copyWith(
        state: DoctorActionsStatus.error,
        actionType: DoctorActionType.add,
        errorMessage: e.toString(),
      ));
    }
  }

  // Update Doctor
  Future<void> _onUpdateDoctor(
      UpdateDoctorEvent event, Emitter<DoctorActionsState> emit) async {
    try {
      emit(state.copyWith(
        state: DoctorActionsStatus.loading,
        actionType: DoctorActionType.update,
      ));

      final result = await doctorRepo.updateDoctor(
        id: event.doctorId,
        doctor: event.doctor,
      );

      if (result.error == null && (result.name != null || result.id != null)) {
        emit(state.copyWith(
          state: DoctorActionsStatus.success,
          actionType: DoctorActionType.update,
          successMessage: 'Doctor Updated Successfully',
          doctor: result,
        ));
      } else {
        emit(state.copyWith(
          state: DoctorActionsStatus.error,
          actionType: DoctorActionType.update,
          errorMessage: result.error ?? 'Failed to update doctor',
        ));
      }
    } catch (e) {
      if (e.toString().toLowerCase().contains('no internet connection')) {
        emit(state.copyWith(
          state: DoctorActionsStatus.noConnection,
          actionType: DoctorActionType.update,
          errorMessage: e.toString(),
        ));
        return;
      }
      if (e.toString().toLowerCase().contains('request cancelled')) {
        return;
      }
      emit(state.copyWith(
        state: DoctorActionsStatus.error,
        actionType: DoctorActionType.update,
        errorMessage: e.toString(),
      ));
    }
  }

  // Delete Doctor
  Future<void> _onDeleteDoctor(
      DeleteDoctorEvent event, Emitter<DoctorActionsState> emit) async {
    try {
      emit(state.copyWith(
        state: DoctorActionsStatus.loading,
        actionType: DoctorActionType.delete,
      ));

      final result = await doctorRepo.deleteDoctor(id: event.doctorId);

      if (result.error == null && result.message != null) {
        emit(state.copyWith(
          state: DoctorActionsStatus.success,
          actionType: DoctorActionType.delete,
          successMessage: result.message,
        ));
      } else {
        emit(state.copyWith(
          state: DoctorActionsStatus.error,
          actionType: DoctorActionType.delete,
          errorMessage: result.error ?? 'Failed to delete doctor',
        ));
      }
    } catch (e) {
      if (e.toString().toLowerCase().contains('no internet connection')) {
        emit(state.copyWith(
          state: DoctorActionsStatus.noConnection,
          actionType: DoctorActionType.delete,
          errorMessage: e.toString(),
        ));
        return;
      }
      if (e.toString().toLowerCase().contains('request cancelled')) {
        return;
      }
      emit(state.copyWith(
        state: DoctorActionsStatus.error,
        actionType: DoctorActionType.delete,
        errorMessage: e.toString(),
      ));
    }
  }

  // Reset Doctor Actions
  Future<void> _onResetDoctorActions(
      ResetDoctorActionsEvent event, Emitter<DoctorActionsState> emit) async {
    emit(const DoctorActionsState());
  }
}
