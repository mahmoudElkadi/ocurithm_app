part of 'get_single_payment_method_cubit.dart';

/// Status enum for single payment method fetch
enum SinglePaymentMethodStatus {
  initial,
  loading,
  success,
  error,
  noConnection,
}

/// State for GetSinglePaymentMethodCubit
class GetSinglePaymentMethodState {
  final SinglePaymentMethodStatus status;
  final PaymentMethod? paymentMethod;
  final String? errorMessage;

  const GetSinglePaymentMethodState({
    this.status = SinglePaymentMethodStatus.initial,
    this.paymentMethod,
    this.errorMessage,
  });

  GetSinglePaymentMethodState copyWith({
    SinglePaymentMethodStatus? status,
    PaymentMethod? paymentMethod,
    String? errorMessage,
  }) {
    return GetSinglePaymentMethodState(
      status: status ?? this.status,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      errorMessage: errorMessage,
    );
  }

  bool get isInitial => status == SinglePaymentMethodStatus.initial;
  bool get isLoading => status == SinglePaymentMethodStatus.loading;
  bool get isSuccess => status == SinglePaymentMethodStatus.success;
  bool get isError => status == SinglePaymentMethodStatus.error;
  bool get noConnection => status == SinglePaymentMethodStatus.noConnection;
}
