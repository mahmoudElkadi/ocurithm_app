part of 'get_patient_examinations_cubit.dart';

enum GetPatientExaminationsStatus { initial, loading, success, error }

class GetPatientExaminationsState {
  final GetPatientExaminationsStatus status;
  final Examinations? examinations;
  final String? errorMessage;

  const GetPatientExaminationsState({
    this.status = GetPatientExaminationsStatus.initial,
    this.examinations,
    this.errorMessage,
  });

  bool get isLoading => status == GetPatientExaminationsStatus.loading;
  bool get isSuccess => status == GetPatientExaminationsStatus.success;
  bool get isError => status == GetPatientExaminationsStatus.error;
}
