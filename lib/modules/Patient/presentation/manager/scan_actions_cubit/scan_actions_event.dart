part of 'scan_actions_cubit.dart';

@immutable
abstract class ScanActionsEvent {}

class CreateScanRecordEvent extends ScanActionsEvent {
  final String patientId;
  final String doctorId;
  final String comment;
  final String scanDate;
  final List<String> files;
  final String? eye;
  final List<String>? investigations;

  CreateScanRecordEvent({
    required this.patientId,
    required this.doctorId,
    required this.comment,
    required this.scanDate,
    required this.files,
    this.eye,
    this.investigations,
  });
}

class DeleteScanEvent extends ScanActionsEvent {
  final String patientId;
  final String scanId;

  DeleteScanEvent({required this.patientId, required this.scanId});
}

class EditScanFileEvent extends ScanActionsEvent {
  final String patientId;
  final String scanId;
  final String fileId;
  final String newKey;

  EditScanFileEvent({
    required this.patientId,
    required this.scanId,
    required this.fileId,
    required this.newKey,
  });
}

class RestoreScanFileEvent extends ScanActionsEvent {
  final String patientId;
  final String scanId;
  final String fileId;

  RestoreScanFileEvent({
    required this.patientId,
    required this.scanId,
    required this.fileId,
  });
}
