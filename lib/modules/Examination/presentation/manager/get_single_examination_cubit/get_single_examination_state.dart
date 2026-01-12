part of 'get_single_examination_cubit.dart';

abstract class GetSingleExaminationState {}

class GetSingleExaminationInitial extends GetSingleExaminationState {}

class GetSingleExaminationLoading extends GetSingleExaminationState {}

class GetSingleExaminationSuccess extends GetSingleExaminationState {
  final SavedExaminationModel examination;
  GetSingleExaminationSuccess(this.examination);
}

class GetSingleExaminationError extends GetSingleExaminationState {
  final String error;
  GetSingleExaminationError(this.error);
}
