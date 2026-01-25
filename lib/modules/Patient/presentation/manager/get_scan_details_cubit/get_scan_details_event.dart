part of 'get_scan_details_cubit.dart';

abstract class GetScanDetailsEvent {}

class FetchScanDetailsEvent extends GetScanDetailsEvent {
  final String patientId;
  final String scanId;

  FetchScanDetailsEvent({required this.patientId, required this.scanId});
}
