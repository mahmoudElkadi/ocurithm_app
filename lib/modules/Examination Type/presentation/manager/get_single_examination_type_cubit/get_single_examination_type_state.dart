part of 'get_single_examination_type_cubit.dart';

/// Status enum for single examination type fetch
enum SingleExaminationTypeStatus {
  initial,
  loading,
  success,
  error,
  noConnection,
}

/// State for GetSingleExaminationTypeCubit
class GetSingleExaminationTypeState {
  final SingleExaminationTypeStatus status;
  final ExaminationType? examinationType;
  final String? errorMessage;

  const GetSingleExaminationTypeState({
    this.status = SingleExaminationTypeStatus.initial,
    this.examinationType,
    this.errorMessage,
  });

  GetSingleExaminationTypeState copyWith({
    SingleExaminationTypeStatus? status,
    ExaminationType? examinationType,
    String? errorMessage,
  }) {
    return GetSingleExaminationTypeState(
      status: status ?? this.status,
      examinationType: examinationType ?? this.examinationType,
      errorMessage: errorMessage,
    );
  }

  bool get isInitial => status == SingleExaminationTypeStatus.initial;
  bool get isLoading => status == SingleExaminationTypeStatus.loading;
  bool get isSuccess => status == SingleExaminationTypeStatus.success;
  bool get isError => status == SingleExaminationTypeStatus.error;
  bool get noConnection => status == SingleExaminationTypeStatus.noConnection;
}
