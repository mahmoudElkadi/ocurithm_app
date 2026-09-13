part of 'save_reason_actions_cubit.dart';

enum SaveReasonActionStatus {
  initial,
  loading,
  success,
  error,
  noConnection,
}

enum SaveReasonActionType {
  add,
  update,
  delete,
  none,
}

class SaveReasonActionsState {
  final SaveReasonActionStatus status;
  final SaveReasonActionType actionType;
  final String? successMessage;
  final String? errorMessage;

  const SaveReasonActionsState({
    this.status = SaveReasonActionStatus.initial,
    this.actionType = SaveReasonActionType.none,
    this.successMessage,
    this.errorMessage,
  });

  SaveReasonActionsState copyWith({
    SaveReasonActionStatus? status,
    SaveReasonActionType? actionType,
    String? successMessage,
    String? errorMessage,
  }) {
    return SaveReasonActionsState(
      status: status ?? this.status,
      actionType: actionType ?? this.actionType,
      successMessage: successMessage,
      errorMessage: errorMessage,
    );
  }

  bool get isInitial => status == SaveReasonActionStatus.initial;
  bool get isLoading => status == SaveReasonActionStatus.loading;
  bool get isSuccess => status == SaveReasonActionStatus.success;
  bool get isError => status == SaveReasonActionStatus.error;
  bool get noConnection => status == SaveReasonActionStatus.noConnection;
}
