import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ocurithm/modules/Patient/data/model/patients_model.dart';
import 'package:ocurithm/modules/Patient/data/repos/patient_repo.dart';

part 'patient_actions_state.dart';
part 'patient_actions_event.dart';

/// Cubit for handling patient actions (add, update, delete)
class PatientActionsCubit
    extends Bloc<PatientActionsEvent, PatientActionsState> {
  final PatientRepo patientRepo;

  PatientActionsCubit(this.patientRepo) : super(const PatientActionsState()) {
    on<AddPatientEvent>(_onAddPatient);
    on<UpdatePatientEvent>(_onUpdatePatient);
    on<DeletePatientEvent>(_onDeletePatient);
    on<ResetPatientActionsEvent>(_onResetPatientActions);
    on<CheckDuplicateNameEvent>(_onCheckDuplicateName);
  }

  static PatientActionsCubit get(BuildContext context) =>
      BlocProvider.of(context);

  // Add Patient
  Future<void> _onAddPatient(
      AddPatientEvent event, Emitter<PatientActionsState> emit) async {
    try {
      emit(state.copyWith(
        state: PatientActionsStatus.loading,
        actionType: PatientActionType.add,
      ));

      final result = await patientRepo.createPatient(patient: event.patient);

      if (result.error == null && (result.name != null || result.id != null)) {
        emit(state.copyWith(
          state: PatientActionsStatus.success,
          actionType: PatientActionType.add,
          successMessage: 'Patient Added Successfully',
          patient: result,
        ));
      } else {
        emit(state.copyWith(
          state: PatientActionsStatus.error,
          actionType: PatientActionType.add,
          errorMessage: result.error ?? 'Failed to add patient',
        ));
      }
    } catch (e) {
      if (e.toString().toLowerCase().contains('no internet connection')) {
        emit(state.copyWith(
          state: PatientActionsStatus.noConnection,
          actionType: PatientActionType.add,
          errorMessage: e.toString(),
        ));
        return;
      }
      if (e.toString().toLowerCase().contains('request cancelled')) {
        return;
      }
      emit(state.copyWith(
        state: PatientActionsStatus.error,
        actionType: PatientActionType.add,
        errorMessage: e.toString(),
      ));
    }
  }

  // Update Patient
  Future<void> _onUpdatePatient(
      UpdatePatientEvent event, Emitter<PatientActionsState> emit) async {
    try {
      emit(state.copyWith(
        state: PatientActionsStatus.loading,
        actionType: PatientActionType.update,
      ));

      final result = await patientRepo.updatePatient(
        id: event.patientId,
        patient: event.patient,
      );

      if (result.error == null && (result.name != null || result.id != null)) {
        emit(state.copyWith(
          state: PatientActionsStatus.success,
          actionType: PatientActionType.update,
          successMessage: 'Patient Updated Successfully',
          patient: result,
        ));
      } else {
        emit(state.copyWith(
          state: PatientActionsStatus.error,
          actionType: PatientActionType.update,
          errorMessage: result.error ?? 'Failed to update patient',
        ));
      }
    } catch (e) {
      if (e.toString().toLowerCase().contains('no internet connection')) {
        emit(state.copyWith(
          state: PatientActionsStatus.noConnection,
          actionType: PatientActionType.update,
          errorMessage: e.toString(),
        ));
        return;
      }
      if (e.toString().toLowerCase().contains('request cancelled')) {
        return;
      }
      emit(state.copyWith(
        state: PatientActionsStatus.error,
        actionType: PatientActionType.update,
        errorMessage: e.toString(),
      ));
    }
  }

  // Delete Patient
  Future<void> _onDeletePatient(
      DeletePatientEvent event, Emitter<PatientActionsState> emit) async {
    try {
      emit(state.copyWith(
        state: PatientActionsStatus.loading,
        actionType: PatientActionType.delete,
      ));

      final result = await patientRepo.deletePatient(id: event.patientId);

      if (result.error == null && result.message != null) {
        emit(state.copyWith(
          state: PatientActionsStatus.success,
          actionType: PatientActionType.delete,
          successMessage: result.message,
        ));
      } else {
        emit(state.copyWith(
          state: PatientActionsStatus.error,
          actionType: PatientActionType.delete,
          errorMessage: result.error ?? 'Failed to delete patient',
        ));
      }
    } catch (e) {
      if (e.toString().toLowerCase().contains('no internet connection')) {
        emit(state.copyWith(
          state: PatientActionsStatus.noConnection,
          actionType: PatientActionType.delete,
          errorMessage: e.toString(),
        ));
        return;
      }
      if (e.toString().toLowerCase().contains('request cancelled')) {
        return;
      }
      emit(state.copyWith(
        state: PatientActionsStatus.error,
        actionType: PatientActionType.delete,
        errorMessage: e.toString(),
      ));
    }
  }

  // Reset Actions
  Future<void> _onResetPatientActions(
      ResetPatientActionsEvent event, Emitter<PatientActionsState> emit) async {
    emit(const PatientActionsState());
  }

  // Check Duplicate Name
  Future<void> _onCheckDuplicateName(
      CheckDuplicateNameEvent event, Emitter<PatientActionsState> emit) async {
    if (event.name.trim().isEmpty) {
      emit(state.copyWith(
        isNameDuplicate: false,
        isCheckingDuplicateName: false,
      ));
      return;
    }

    try {
      emit(state.copyWith(isCheckingDuplicateName: true));

      final isDuplicate = await patientRepo.checkDuplicateName(name: event.name);

      emit(state.copyWith(
        isNameDuplicate: isDuplicate,
        isCheckingDuplicateName: false,
      ));
    } catch (e) {
      emit(state.copyWith(
        isNameDuplicate: false,
        isCheckingDuplicateName: false,
      ));
    }
  }
}
