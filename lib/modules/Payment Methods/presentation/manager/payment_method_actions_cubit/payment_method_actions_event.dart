part of 'payment_method_actions_cubit.dart';

/// Events for PaymentMethodActionsCubit
abstract class PaymentMethodActionsEvent {
  const PaymentMethodActionsEvent();
}

/// Event to add a new payment method
class AddPaymentMethodEvent extends PaymentMethodActionsEvent {
  final PaymentMethod paymentMethod;

  const AddPaymentMethodEvent(this.paymentMethod);
}

/// Event to update an existing payment method
class UpdatePaymentMethodEvent extends PaymentMethodActionsEvent {
  final String paymentMethodId;
  final PaymentMethod paymentMethod;

  const UpdatePaymentMethodEvent({
    required this.paymentMethodId,
    required this.paymentMethod,
  });
}

/// Event to delete a payment method
class DeletePaymentMethodEvent extends PaymentMethodActionsEvent {
  final String paymentMethodId;

  const DeletePaymentMethodEvent(this.paymentMethodId);
}

/// Event to reset the actions state
class ResetPaymentMethodActionsEvent extends PaymentMethodActionsEvent {
  const ResetPaymentMethodActionsEvent();
}
