part of 'payment_method_actions_cubit.dart';

/// Status enum for payment method actions
enum PaymentMethodActionStatus {
  initial,
  loading,
  success,
  error,
  noConnection,
}

/// Type of action being performed
enum PaymentMethodActionType {
  add,
  update,
  delete,
  none,
}

/// State for PaymentMethodActionsCubit
class PaymentMethodActionsState {
  final PaymentMethodActionStatus status;
  final PaymentMethodActionType actionType;
  final String? successMessage;
  final String? errorMessage;

  const PaymentMethodActionsState({
    this.status = PaymentMethodActionStatus.initial,
    this.actionType = PaymentMethodActionType.none,
    this.successMessage,
    this.errorMessage,
  });

  PaymentMethodActionsState copyWith({
    PaymentMethodActionStatus? status,
    PaymentMethodActionType? actionType,
    String? successMessage,
    String? errorMessage,
  }) {
    return PaymentMethodActionsState(
      status: status ?? this.status,
      actionType: actionType ?? this.actionType,
      successMessage: successMessage,
      errorMessage: errorMessage,
    );
  }

  bool get isInitial => status == PaymentMethodActionStatus.initial;
  bool get isLoading => status == PaymentMethodActionStatus.loading;
  bool get isSuccess => status == PaymentMethodActionStatus.success;
  bool get isError => status == PaymentMethodActionStatus.error;
  bool get noConnection => status == PaymentMethodActionStatus.noConnection;

  bool get isAddSuccess =>
      status == PaymentMethodActionStatus.success &&
      actionType == PaymentMethodActionType.add;

  bool get isUpdateSuccess =>
      status == PaymentMethodActionStatus.success &&
      actionType == PaymentMethodActionType.update;

  bool get isDeleteSuccess =>
      status == PaymentMethodActionStatus.success &&
      actionType == PaymentMethodActionType.delete;

  bool get isAddError =>
      status == PaymentMethodActionStatus.error &&
      actionType == PaymentMethodActionType.add;

  bool get isUpdateError =>
      status == PaymentMethodActionStatus.error &&
      actionType == PaymentMethodActionType.update;

  bool get isDeleteError =>
      status == PaymentMethodActionStatus.error &&
      actionType == PaymentMethodActionType.delete;
}
