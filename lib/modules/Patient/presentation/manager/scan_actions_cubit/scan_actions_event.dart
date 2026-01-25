part of 'scan_actions_cubit.dart';

@immutable
abstract class ScanActionsEvent {}

class CreateScanRecordEvent extends ScanActionsEvent {
  final String patientId;
  final String doctorId;
  final String comment;
  final String scanDate;
  final List<String> files;

  CreateScanRecordEvent({
    required this.patientId,
    required this.doctorId,
    required this.comment,
    required this.scanDate,
    required this.files,
  });
}

class DeleteScanEvent extends ScanActionsEvent {
  final String patientId;
  final String scanId;

  DeleteScanEvent({required this.patientId, required this.scanId});
}
