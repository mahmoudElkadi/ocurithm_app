import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ocurithm/modules/Patient/data/model/scan_records_model.dart';
import 'package:ocurithm/modules/Patient/data/repos/patient_repo.dart';

part 'get_scan_details_state.dart';
part 'get_scan_details_event.dart';

class GetScanDetailsCubit
    extends Bloc<GetScanDetailsEvent, GetScanDetailsState> {
  final PatientRepo patientRepo;

  GetScanDetailsCubit(this.patientRepo) : super(const GetScanDetailsState()) {
    on<FetchScanDetailsEvent>(_onFetchScanDetails);
  }

  Future<void> _onFetchScanDetails(
    FetchScanDetailsEvent event,
    Emitter<GetScanDetailsState> emit,
  ) async {
    try {
      emit(state.copyWith(state: GetScanDetailsStatus.loading));

      final scanRecord = await patientRepo.getScanDetails(
        patientId: event.patientId,
        scanId: event.scanId,
      );

      emit(state.copyWith(
        state: GetScanDetailsStatus.success,
        scanRecord: scanRecord,
      ));
    } catch (e) {
      if (e.toString().toLowerCase().contains('no internet connection')) {
        emit(state.copyWith(
          state: GetScanDetailsStatus.noConnection,
          errorMessage: e.toString(),
        ));
        return;
      }
      emit(state.copyWith(
        state: GetScanDetailsStatus.error,
        errorMessage: e.toString(),
      ));
    }
  }
}
