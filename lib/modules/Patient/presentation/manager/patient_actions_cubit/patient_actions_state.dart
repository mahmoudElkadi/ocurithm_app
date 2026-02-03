part of 'patient_actions_cubit.dart';

enum PatientActionsStatus { initial, loading, success, error, noConnection }

enum PatientActionType { add, update, delete, none }

extension PatientActionsStatusX on PatientActionsState {
  bool get isInitial => state == PatientActionsStatus.initial;
  bool get isLoading => state == PatientActionsStatus.loading;
  bool get isSuccess => state == PatientActionsStatus.success;
  bool get isError => state == PatientActionsStatus.error;
  bool get noConnection => state == PatientActionsStatus.noConnection;

  bool get isAddSuccess =>
      state == PatientActionsStatus.success &&
      actionType == PatientActionType.add;
  bool get isUpdateSuccess =>
      state == PatientActionsStatus.success &&
      actionType == PatientActionType.update;
  bool get isDeleteSuccess =>
      state == PatientActionsStatus.success &&
      actionType == PatientActionType.delete;

  bool get isAddError =>
      state == PatientActionsStatus.error &&
      actionType == PatientActionType.add;
  bool get isUpdateError =>
      state == PatientActionsStatus.error &&
      actionType == PatientActionType.update;
  bool get isDeleteError =>
      state == PatientActionsStatus.error &&
      actionType == PatientActionType.delete;
}

@immutable
class PatientActionsState {
  final PatientActionsStatus state;
  final PatientActionType actionType;
  final String? errorMessage;
  final String? successMessage;
  final Patient? patient;

  const PatientActionsState({
    this.state = PatientActionsStatus.initial,
    this.actionType = PatientActionType.none,
    this.errorMessage,
    this.successMessage,
    this.patient,
  });

  PatientActionsState copyWith({
    PatientActionsStatus? state,
    PatientActionType? actionType,
    String? errorMessage,
    String? successMessage,
    Patient? patient,
  }) {
    return PatientActionsState(
      state: state ?? this.state,
      actionType: actionType ?? this.actionType,
      errorMessage: errorMessage ?? this.errorMessage,
      successMessage: successMessage ?? this.successMessage,
      patient: patient ?? this.patient,
    );
  }
}
