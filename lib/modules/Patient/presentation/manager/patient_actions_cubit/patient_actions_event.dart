part of 'patient_actions_cubit.dart';

@immutable
abstract class PatientActionsEvent {}

class AddPatientEvent extends PatientActionsEvent {
  final Patient patient;

  AddPatientEvent(this.patient);
}

class UpdatePatientEvent extends PatientActionsEvent {
  final String patientId;
  final Patient patient;

  UpdatePatientEvent(this.patientId, this.patient);
}

class DeletePatientEvent extends PatientActionsEvent {
  final String patientId;

  DeletePatientEvent(this.patientId);
}

class TransferPatientEvent extends PatientActionsEvent {
  final String sourceId;
  final String targetId;
  final bool deleteSource;

  TransferPatientEvent({
    required this.sourceId,
    required this.targetId,
    required this.deleteSource,
  });
}

class ResetPatientActionsEvent extends PatientActionsEvent {}

class CheckDuplicateNameEvent extends PatientActionsEvent {
  final String name;

  CheckDuplicateNameEvent(this.name);
}
