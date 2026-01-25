import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ocurithm/modules/Patient/data/model/scan_records_model.dart';
import 'package:ocurithm/modules/Patient/data/repos/patient_repo.dart';

part 'get_patient_scans_state.dart';
part 'get_patient_scans_event.dart';

class GetPatientScansCubit
    extends Bloc<GetPatientScansEvent, GetPatientScansState> {
  final PatientRepo patientRepo;

  GetPatientScansCubit(this.patientRepo) : super(const GetPatientScansState()) {
    on<FetchPatientScansEvent>(_onFetchPatientScans);
    on<ResetFiltersEvent>(_onResetFilters);
  }

  Future<void> _onFetchPatientScans(
    FetchPatientScansEvent event,
    Emitter<GetPatientScansState> emit,
  ) async {
    try {
      emit(state.copyWith(
        state: GetPatientScansStatus.loading,
        currentPage: event.page ?? state.currentPage,
        doctorId: event.doctorId,
        fromDate: event.fromDate,
        toDate: event.toDate,
      ));

      final scanRecords = await patientRepo.getPatientScans(
        patientId: event.patientId,
        page: event.page ?? state.currentPage,
        doctorId: event.doctorId ?? state.doctorId,
        fromDate: event.fromDate ?? state.fromDate,
        toDate: event.toDate ?? state.toDate,
      );

      emit(state.copyWith(
        state: GetPatientScansStatus.success,
        scanRecords: scanRecords,
        currentPage: event.page ?? state.currentPage,
      ));
    } catch (e) {
      if (e.toString().toLowerCase().contains('no internet connection')) {
        emit(state.copyWith(
          state: GetPatientScansStatus.noConnection,
          errorMessage: e.toString(),
        ));
        return;
      }
      emit(state.copyWith(
        state: GetPatientScansStatus.error,
        errorMessage: e.toString(),
      ));
    }
  }

  Future<void> _onResetFilters(
    ResetFiltersEvent event,
    Emitter<GetPatientScansState> emit,
  ) async {
    emit(state.copyWith(
      clearDoctorId: true,
      clearFromDate: true,
      clearToDate: true,
      currentPage: 1,
    ));

    add(FetchPatientScansEvent(patientId: event.patientId, page: 1));
  }
}
