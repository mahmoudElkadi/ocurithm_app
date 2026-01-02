part of 'get_single_payment_method_cubit.dart';

/// Events for GetSinglePaymentMethodCubit
abstract class GetSinglePaymentMethodEvent {
  const GetSinglePaymentMethodEvent();
}

/// Event to get a single payment method by ID
class GetPaymentMethodByIdEvent extends GetSinglePaymentMethodEvent {
  final String paymentMethodId;

  const GetPaymentMethodByIdEvent(this.paymentMethodId);
}

/// Event to reset the single payment method state
class ResetSinglePaymentMethodEvent extends GetSinglePaymentMethodEvent {
  const ResetSinglePaymentMethodEvent();
}
