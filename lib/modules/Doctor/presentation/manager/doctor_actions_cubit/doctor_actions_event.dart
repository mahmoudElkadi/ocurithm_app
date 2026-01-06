part of 'doctor_actions_cubit.dart';

@immutable
abstract class DoctorActionsEvent {}

class AddDoctorEvent extends DoctorActionsEvent {
  final Doctor doctor;

  AddDoctorEvent(this.doctor);
}

class UpdateDoctorEvent extends DoctorActionsEvent {
  final String doctorId;
  final Doctor doctor;

  UpdateDoctorEvent({
    required this.doctorId,
    required this.doctor,
  });
}

class DeleteDoctorEvent extends DoctorActionsEvent {
  final String doctorId;

  DeleteDoctorEvent(this.doctorId);
}

class ResetDoctorActionsEvent extends DoctorActionsEvent {}
