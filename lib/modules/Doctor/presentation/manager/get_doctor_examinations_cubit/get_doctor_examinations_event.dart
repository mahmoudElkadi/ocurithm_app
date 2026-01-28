part of 'get_doctor_examinations_cubit.dart';

@immutable
abstract class GetDoctorExaminationsEvent {}

class FetchExaminationsEvent extends GetDoctorExaminationsEvent {
  final bool refresh;
  FetchExaminationsEvent({this.refresh = false});
}

class SetDoctorIdEvent extends GetDoctorExaminationsEvent {
  final String doctorId;
  SetDoctorIdEvent(this.doctorId);
}

class SetPageEvent extends GetDoctorExaminationsEvent {
  final int page;
  SetPageEvent(this.page);
}

class SetFiltersEvent extends GetDoctorExaminationsEvent {
  final String? patientId;
  final String? startDate;
  final String? endDate;

  SetFiltersEvent({this.patientId, this.startDate, this.endDate});
}

class ResetFiltersEvent extends GetDoctorExaminationsEvent {}
