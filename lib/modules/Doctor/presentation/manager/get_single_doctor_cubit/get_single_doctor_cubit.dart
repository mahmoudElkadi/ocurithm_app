import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ocurithm/modules/Doctor/data/model/doctor_model.dart';
import 'package:ocurithm/modules/Doctor/data/repos/doctor_repo.dart';

part 'get_single_doctor_state.dart';
part 'get_single_doctor_event.dart';

/// Cubit for fetching a single doctor by ID
/// Used in edit and view modes
class GetSingleDoctorCubit
    extends Bloc<GetSingleDoctorEvent, GetSingleDoctorState> {
  final DoctorRepo doctorRepo;

  GetSingleDoctorCubit(this.doctorRepo) : super(const GetSingleDoctorState()) {
    on<GetDoctorByIdEvent>(_onGetDoctorById);
    on<ResetSingleDoctorEvent>(_onResetSingleDoctor);
  }

  static GetSingleDoctorCubit get(BuildContext context) =>
      BlocProvider.of(context);

  // Get Doctor by ID
  Future<void> _onGetDoctorById(
      GetDoctorByIdEvent event, Emitter<GetSingleDoctorState> emit) async {
    try {
      emit(state.copyWith(state: GetSingleDoctorStatus.loading));

      final doctor = await doctorRepo.getDoctor(id: event.doctorId);

      if (doctor.error == null) {
        emit(state.copyWith(
          state: GetSingleDoctorStatus.success,
          doctor: doctor,
        ));
      } else {
        emit(state.copyWith(
          state: GetSingleDoctorStatus.error,
          errorMessage: doctor.error ?? 'Failed to load doctor',
        ));
      }
    } catch (e) {
      if (e.toString().toLowerCase().contains('no internet connection')) {
        emit(state.copyWith(
          state: GetSingleDoctorStatus.noConnection,
          errorMessage: e.toString(),
        ));
        return;
      }
      if (e.toString().toLowerCase().contains('request cancelled')) {
        return;
      }
      emit(state.copyWith(
        state: GetSingleDoctorStatus.error,
        errorMessage: e.toString(),
      ));
    }
  }

  // Reset Single Doctor
  Future<void> _onResetSingleDoctor(
      ResetSingleDoctorEvent event, Emitter<GetSingleDoctorState> emit) async {
    emit(const GetSingleDoctorState());
  }
}
