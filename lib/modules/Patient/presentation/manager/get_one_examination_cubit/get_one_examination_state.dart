part of 'get_one_examination_cubit.dart';

enum GetOneExaminationStatus { initial, loading, success, error }

class GetOneExaminationState {
  final GetOneExaminationStatus status;
  final ExaminationModel? examination;
  final String? errorMessage;

  const GetOneExaminationState({
    this.status = GetOneExaminationStatus.initial,
    this.examination,
    this.errorMessage,
  });

  bool get isLoading => status == GetOneExaminationStatus.loading;
  bool get isSuccess => status == GetOneExaminationStatus.success;
  bool get isError => status == GetOneExaminationStatus.error;
}
