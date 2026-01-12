part of 'examination_actions_cubit.dart';

enum ExaminationActionsStatus { initial, loading, success, error, noConnection }

class ExaminationActionsState {
  final ExaminationActionsStatus status;
  final String? error;
  final String? message;
  final dynamic result; // Can hold returned object if needed

  const ExaminationActionsState({
    this.status = ExaminationActionsStatus.initial,
    this.error,
    this.message,
    this.result,
  });

  ExaminationActionsState copyWith({
    ExaminationActionsStatus? status,
    String? error,
    String? message,
    dynamic result,
  }) {
    return ExaminationActionsState(
      status: status ?? this.status,
      error: error,
      message: message ?? this.message,
      result: result ?? this.result,
    );
  }
}
