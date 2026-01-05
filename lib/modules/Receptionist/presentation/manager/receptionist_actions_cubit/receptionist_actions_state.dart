part of 'receptionist_actions_cubit.dart';

enum ReceptionistActionType { add, update, delete, none }

enum ReceptionistActionsStatus {
  initial,
  loading,
  success,
  error,
  noConnection
}

extension ReceptionistActionsStatusX on ReceptionistActionsState {
  bool get isInitial => state == ReceptionistActionsStatus.initial;

  bool get isLoading => state == ReceptionistActionsStatus.loading;

  bool get isSuccess => state == ReceptionistActionsStatus.success;

  bool get isError => state == ReceptionistActionsStatus.error;

  bool get noConnection => state == ReceptionistActionsStatus.noConnection;

  // Add action states
  bool get isAddLoading =>
      state == ReceptionistActionsStatus.loading &&
      actionType == ReceptionistActionType.add;

  bool get isAddSuccess =>
      state == ReceptionistActionsStatus.success &&
      actionType == ReceptionistActionType.add;

  bool get isAddError =>
      state == ReceptionistActionsStatus.error &&
      actionType == ReceptionistActionType.add;

  // Update action states
  bool get isUpdateLoading =>
      state == ReceptionistActionsStatus.loading &&
      actionType == ReceptionistActionType.update;

  bool get isUpdateSuccess =>
      state == ReceptionistActionsStatus.success &&
      actionType == ReceptionistActionType.update;

  bool get isUpdateError =>
      state == ReceptionistActionsStatus.error &&
      actionType == ReceptionistActionType.update;

  // Delete action states
  bool get isDeleteLoading =>
      state == ReceptionistActionsStatus.loading &&
      actionType == ReceptionistActionType.delete;

  bool get isDeleteSuccess =>
      state == ReceptionistActionsStatus.success &&
      actionType == ReceptionistActionType.delete;

  bool get isDeleteError =>
      state == ReceptionistActionsStatus.error &&
      actionType == ReceptionistActionType.delete;
}

@immutable
class ReceptionistActionsState {
  final ReceptionistActionsStatus state;
  final ReceptionistActionType actionType;
  final String? errorMessage;
  final String? successMessage;
  final AddReceptionistsModel? receptionist;

  const ReceptionistActionsState({
    this.state = ReceptionistActionsStatus.initial,
    this.actionType = ReceptionistActionType.none,
    this.errorMessage,
    this.successMessage,
    this.receptionist,
  });

  ReceptionistActionsState copyWith({
    ReceptionistActionsStatus? state,
    ReceptionistActionType? actionType,
    String? errorMessage,
    String? successMessage,
    AddReceptionistsModel? receptionist,
  }) {
    return ReceptionistActionsState(
      state: state ?? this.state,
      actionType: actionType ?? this.actionType,
      errorMessage: errorMessage ?? this.errorMessage,
      successMessage: successMessage ?? this.successMessage,
      receptionist: receptionist ?? this.receptionist,
    );
  }
}
