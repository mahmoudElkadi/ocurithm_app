part of 'get_patient_scans_cubit.dart';

abstract class GetPatientScansEvent {}

class FetchPatientScansEvent extends GetPatientScansEvent {
  final String patientId;
  final int? page;
  final String? doctorId;
  final String? fromDate;
  final String? toDate;

  FetchPatientScansEvent({
    required this.patientId,
    this.page,
    this.doctorId,
    this.fromDate,
    this.toDate,
  });
}

class ResetFiltersEvent extends GetPatientScansEvent {
  final String patientId;
  ResetFiltersEvent({required this.patientId});
}
