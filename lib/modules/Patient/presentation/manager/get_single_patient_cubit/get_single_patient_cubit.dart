import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ocurithm/modules/Patient/data/model/patients_model.dart';
import 'package:ocurithm/modules/Patient/data/repos/patient_repo.dart';

part 'get_single_patient_state.dart';
part 'get_single_patient_event.dart';

class GetSinglePatientCubit
    extends Bloc<GetSinglePatientEvent, GetSinglePatientState> {
  final PatientRepo patientRepo;

  GetSinglePatientCubit(this.patientRepo)
      : super(const GetSinglePatientState()) {
    on<GetPatientByIdEvent>(_onGetPatientById);
  }

  static GetSinglePatientCubit get(BuildContext context) =>
      BlocProvider.of(context);

  Future<void> _onGetPatientById(
      GetPatientByIdEvent event, Emitter<GetSinglePatientState> emit) async {
    try {
      emit(state.copyWith(state: GetSinglePatientStatus.loading));

      final patient = await patientRepo.getPatient(id: event.id);

      if (patient.id != null) {
        emit(state.copyWith(
          state: GetSinglePatientStatus.success,
          patient: patient,
        ));
      } else {
        emit(state.copyWith(
          state: GetSinglePatientStatus.error,
          errorMessage: patient.error ?? 'Failed to load patient',
        ));
      }
    } catch (e) {
      if (e.toString().toLowerCase().contains('no internet connection')) {
        emit(state.copyWith(
          state: GetSinglePatientStatus.noConnection,
          errorMessage: e.toString(),
        ));
        return;
      }
      emit(state.copyWith(
        state: GetSinglePatientStatus.error,
        errorMessage: e.toString(),
      ));
    }
  }
}
