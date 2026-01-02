part of 'clinic_actions_cubit.dart';

@immutable
abstract class ClinicActionsEvent {}

class AddClinicEvent extends ClinicActionsEvent {
  final Clinic clinic;

  AddClinicEvent(this.clinic);
}

class UpdateClinicEvent extends ClinicActionsEvent {
  final String clinicId;
  final Clinic clinic;

  UpdateClinicEvent({required this.clinicId, required this.clinic});
}

class DeleteClinicEvent extends ClinicActionsEvent {
  final String clinicId;

  DeleteClinicEvent(this.clinicId);
}

class ResetClinicActionsEvent extends ClinicActionsEvent {}
