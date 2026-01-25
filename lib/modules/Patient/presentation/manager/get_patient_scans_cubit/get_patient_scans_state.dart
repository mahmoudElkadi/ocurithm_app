part of 'get_patient_scans_cubit.dart';

enum GetPatientScansStatus { initial, loading, success, error, noConnection }

class GetPatientScansState {
  final GetPatientScansStatus state;
  final ScanRecordsModel? scanRecords;
  final String? errorMessage;
  final int currentPage;
  final String? doctorId;
  final String? fromDate;
  final String? toDate;

  const GetPatientScansState({
    this.state = GetPatientScansStatus.initial,
    this.scanRecords,
    this.errorMessage,
    this.currentPage = 1,
    this.doctorId,
    this.fromDate,
    this.toDate,
  });

  GetPatientScansState copyWith({
    GetPatientScansStatus? state,
    ScanRecordsModel? scanRecords,
    String? errorMessage,
    int? currentPage,
    String? doctorId,
    String? fromDate,
    String? toDate,
    bool clearDoctorId = false,
    bool clearFromDate = false,
    bool clearToDate = false,
  }) {
    return GetPatientScansState(
      state: state ?? this.state,
      scanRecords: scanRecords ?? this.scanRecords,
      errorMessage: errorMessage ?? this.errorMessage,
      currentPage: currentPage ?? this.currentPage,
      doctorId: clearDoctorId ? null : (doctorId ?? this.doctorId),
      fromDate: clearFromDate ? null : (fromDate ?? this.fromDate),
      toDate: clearToDate ? null : (toDate ?? this.toDate),
    );
  }
}
