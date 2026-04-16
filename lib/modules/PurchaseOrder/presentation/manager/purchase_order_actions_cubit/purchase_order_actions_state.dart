part of 'purchase_order_actions_cubit.dart';

enum PurchaseOrderActionsStatus { initial, loading, success, error }

class PurchaseOrderActionsState {
  final PurchaseOrderActionsStatus status;
  final String? successMessage;
  final String? errorMessage;
  final PurchaseOrderDetails? orderDetails;
  final String? actingId;

  const PurchaseOrderActionsState({
    this.status = PurchaseOrderActionsStatus.initial,
    this.successMessage,
    this.errorMessage,
    this.orderDetails,
    this.actingId,
  });

  bool get isLoading => status == PurchaseOrderActionsStatus.loading;
  bool get isSuccess => status == PurchaseOrderActionsStatus.success;
  bool get isError => status == PurchaseOrderActionsStatus.error;

  PurchaseOrderActionsState copyWith({
    PurchaseOrderActionsStatus? status,
    String? successMessage,
    String? errorMessage,
    PurchaseOrderDetails? orderDetails,
    String? actingId,
  }) {
    return PurchaseOrderActionsState(
      status: status ?? this.status,
      successMessage: successMessage ?? this.successMessage,
      errorMessage: errorMessage ?? this.errorMessage,
      orderDetails: orderDetails ?? this.orderDetails,
      actingId: actingId ?? this.actingId,
    );
  }
}
