part of 'clinic_actions_cubit.dart';

enum ClinicActionType { add, update, delete, none }

enum ClinicActionsStatus { initial, loading, success, error, noConnection }

extension ClinicActionsStatusX on ClinicActionsState {
  bool get isInitial => state == ClinicActionsStatus.initial;

  bool get isLoading => state == ClinicActionsStatus.loading;

  bool get isSuccess => state == ClinicActionsStatus.success;

  bool get isError => state == ClinicActionsStatus.error;

  bool get noConnection => state == ClinicActionsStatus.noConnection;

  // Add action states
  bool get isAddLoading =>
      state == ClinicActionsStatus.loading &&
      actionType == ClinicActionType.add;

  bool get isAddSuccess =>
      state == ClinicActionsStatus.success &&
      actionType == ClinicActionType.add;

  bool get isAddError =>
      state == ClinicActionsStatus.error && actionType == ClinicActionType.add;

  // Update action states
  bool get isUpdateLoading =>
      state == ClinicActionsStatus.loading &&
      actionType == ClinicActionType.update;

  bool get isUpdateSuccess =>
      state == ClinicActionsStatus.success &&
      actionType == ClinicActionType.update;

  bool get isUpdateError =>
      state == ClinicActionsStatus.error &&
      actionType == ClinicActionType.update;

  // Delete action states
  bool get isDeleteLoading =>
      state == ClinicActionsStatus.loading &&
      actionType == ClinicActionType.delete;

  bool get isDeleteSuccess =>
      state == ClinicActionsStatus.success &&
      actionType == ClinicActionType.delete;

  bool get isDeleteError =>
      state == ClinicActionsStatus.error &&
      actionType == ClinicActionType.delete;
}

@immutable
class ClinicActionsState {
  final ClinicActionsStatus state;
  final ClinicActionType actionType;
  final String? errorMessage;
  final String? successMessage;
  final Clinic? clinic;

  const ClinicActionsState({
    this.state = ClinicActionsStatus.initial,
    this.actionType = ClinicActionType.none,
    this.errorMessage,
    this.successMessage,
    this.clinic,
  });

  ClinicActionsState copyWith({
    ClinicActionsStatus? state,
    ClinicActionType? actionType,
    String? errorMessage,
    String? successMessage,
    Clinic? clinic,
  }) {
    return ClinicActionsState(
      state: state ?? this.state,
      actionType: actionType ?? this.actionType,
      errorMessage: errorMessage ?? this.errorMessage,
      successMessage: successMessage ?? this.successMessage,
      clinic: clinic ?? this.clinic,
    );
  }
}
