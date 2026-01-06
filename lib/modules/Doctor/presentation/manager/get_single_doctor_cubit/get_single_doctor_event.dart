part of 'get_single_doctor_cubit.dart';

@immutable
abstract class GetSingleDoctorEvent {}

class GetDoctorByIdEvent extends GetSingleDoctorEvent {
  final String doctorId;

  GetDoctorByIdEvent(this.doctorId);
}

class ResetSingleDoctorEvent extends GetSingleDoctorEvent {}
