enum AccountActionsStatus { initial, loading, success, failure }

class AccountActionsState {
  final AccountActionsStatus status;
  final String? errorMessage;
  final String? successMessage;

  AccountActionsState({
    required this.status,
    this.errorMessage,
    this.successMessage,
  });

  factory AccountActionsState.initial() {
    return AccountActionsState(status: AccountActionsStatus.initial);
  }

  AccountActionsState copyWith({
    AccountActionsStatus? status,
    String? errorMessage,
    String? successMessage,
  }) {
    return AccountActionsState(
      status: status ?? this.status,
      errorMessage: errorMessage ?? this.errorMessage,
      successMessage: successMessage ?? this.successMessage,
    );
  }
}
