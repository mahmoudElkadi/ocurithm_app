part of 'examination_type_actions_cubit.dart';

/// Status enum for examination type actions
enum ExaminationTypeActionStatus {
  initial,
  loading,
  success,
  error,
  noConnection,
}

/// Type of action being performed
enum ExaminationTypeActionType {
  add,
  update,
  delete,
  none,
}

/// State for ExaminationTypeActionsCubit
class ExaminationTypeActionsState {
  final ExaminationTypeActionStatus status;
  final ExaminationTypeActionType actionType;
  final String? successMessage;
  final String? errorMessage;

  const ExaminationTypeActionsState({
    this.status = ExaminationTypeActionStatus.initial,
    this.actionType = ExaminationTypeActionType.none,
    this.successMessage,
    this.errorMessage,
  });

  ExaminationTypeActionsState copyWith({
    ExaminationTypeActionStatus? status,
    ExaminationTypeActionType? actionType,
    String? successMessage,
    String? errorMessage,
  }) {
    return ExaminationTypeActionsState(
      status: status ?? this.status,
      actionType: actionType ?? this.actionType,
      successMessage: successMessage,
      errorMessage: errorMessage,
    );
  }

  bool get isInitial => status == ExaminationTypeActionStatus.initial;
  bool get isLoading => status == ExaminationTypeActionStatus.loading;
  bool get isSuccess => status == ExaminationTypeActionStatus.success;
  bool get isError => status == ExaminationTypeActionStatus.error;
  bool get noConnection => status == ExaminationTypeActionStatus.noConnection;

  bool get isAddSuccess =>
      status == ExaminationTypeActionStatus.success &&
      actionType == ExaminationTypeActionType.add;

  bool get isUpdateSuccess =>
      status == ExaminationTypeActionStatus.success &&
      actionType == ExaminationTypeActionType.update;

  bool get isDeleteSuccess =>
      status == ExaminationTypeActionStatus.success &&
      actionType == ExaminationTypeActionType.delete;

  bool get isAddError =>
      status == ExaminationTypeActionStatus.error &&
      actionType == ExaminationTypeActionType.add;

  bool get isUpdateError =>
      status == ExaminationTypeActionStatus.error &&
      actionType == ExaminationTypeActionType.update;

  bool get isDeleteError =>
      status == ExaminationTypeActionStatus.error &&
      actionType == ExaminationTypeActionType.delete;
}
