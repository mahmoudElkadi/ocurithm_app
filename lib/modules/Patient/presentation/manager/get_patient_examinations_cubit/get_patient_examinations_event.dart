part of 'get_patient_examinations_cubit.dart';

@immutable
abstract class GetPatientExaminationsEvent {}

class GetExaminationsByPatientIdEvent extends GetPatientExaminationsEvent {
  final String patientId;
  GetExaminationsByPatientIdEvent(this.patientId);
}
