import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ocurithm/modules/Clinics/data/model/clinics_model.dart';
import 'package:ocurithm/modules/Clinics/data/repos/clinic_repo.dart';

part 'get_single_clinic_state.dart';
part 'get_single_clinic_event.dart';

class GetSingleClinicCubit
    extends Bloc<GetSingleClinicEvent, GetSingleClinicState> {
  final ClinicRepo clinicRepo;

  GetSingleClinicCubit(this.clinicRepo) : super(GetSingleClinicState()) {
    on<GetClinicByIdEvent>(_onGetClinicById);
    on<ResetSingleClinicEvent>(_onResetSingleClinic);
  }

  static GetSingleClinicCubit get(BuildContext context) =>
      BlocProvider.of(context);

  // Get Single Clinic by ID
  Future<void> _onGetClinicById(
      GetClinicByIdEvent event, Emitter<GetSingleClinicState> emit) async {
    try {
      emit(state.copyWith(state: GetSingleClinicStatus.loading));

      final clinic = await clinicRepo.getClinic(id: event.clinicId);

      emit(
          state.copyWith(state: GetSingleClinicStatus.success, clinic: clinic));
    } catch (e) {
      if (e.toString().toLowerCase().contains('no internet connection')) {
        emit(state.copyWith(
            state: GetSingleClinicStatus.noConnection,
            errorMessage: e.toString()));
        return;
      }
      if (e.toString().toLowerCase().contains('request cancelled')) {
        return;
      }
      emit(state.copyWith(
          state: GetSingleClinicStatus.error, errorMessage: e.toString()));
    }
  }

  // Reset Single Clinic
  Future<void> _onResetSingleClinic(
      ResetSingleClinicEvent event, Emitter<GetSingleClinicState> emit) async {
    emit(GetSingleClinicState());
  }
}
