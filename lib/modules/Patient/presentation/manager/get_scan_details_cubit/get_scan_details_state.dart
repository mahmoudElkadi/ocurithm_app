part of 'get_scan_details_cubit.dart';

enum GetScanDetailsStatus { initial, loading, success, error, noConnection }

class GetScanDetailsState {
  final GetScanDetailsStatus state;
  final ScanRecord? scanRecord;
  final String? errorMessage;

  const GetScanDetailsState({
    this.state = GetScanDetailsStatus.initial,
    this.scanRecord,
    this.errorMessage,
  });

  GetScanDetailsState copyWith({
    GetScanDetailsStatus? state,
    ScanRecord? scanRecord,
    String? errorMessage,
  }) {
    return GetScanDetailsState(
      state: state ?? this.state,
      scanRecord: scanRecord ?? this.scanRecord,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}
