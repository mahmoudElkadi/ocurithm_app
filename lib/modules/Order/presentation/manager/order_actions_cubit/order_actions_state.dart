part of 'order_actions_bloc.dart';

enum OrderActionsStatus { initial, loading, success, error }

class OrderActionsState {
  final OrderActionsStatus status;
  final Order? order;
  final String? errorMessage;

  const OrderActionsState({
    this.status = OrderActionsStatus.initial,
    this.order,
    this.errorMessage,
  });

  OrderActionsState copyWith({
    OrderActionsStatus? status,
    Order? order,
    String? errorMessage,
  }) {
    return OrderActionsState(
      status: status ?? this.status,
      order: order ?? this.order,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}
