import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';

import '../../../data/model/payment_method_model.dart';
import '../../../data/repos/payment_method_repo.dart';

part 'payment_method_actions_event.dart';
part 'payment_method_actions_state.dart';

/// Cubit for payment method actions (add, update, delete)
class PaymentMethodActionsCubit
    extends Bloc<PaymentMethodActionsEvent, PaymentMethodActionsState> {
  final PaymentMethodRepo paymentMethodRepo;

  PaymentMethodActionsCubit(this.paymentMethodRepo)
      : super(const PaymentMethodActionsState()) {
    on<AddPaymentMethodEvent>(_onAddPaymentMethod);
    on<UpdatePaymentMethodEvent>(_onUpdatePaymentMethod);
    on<DeletePaymentMethodEvent>(_onDeletePaymentMethod);
    on<ResetPaymentMethodActionsEvent>(_onResetActions);
  }

  /// Add a new payment method
  Future<void> _onAddPaymentMethod(
    AddPaymentMethodEvent event,
    Emitter<PaymentMethodActionsState> emit,
  ) async {
    emit(state.copyWith(
      status: PaymentMethodActionStatus.loading,
      actionType: PaymentMethodActionType.add,
    ));

    try {
      // Create payment method
      await paymentMethodRepo.createPaymentMethod(
        paymentMethod: event.paymentMethod,
      );

      emit(state.copyWith(
        status: PaymentMethodActionStatus.success,
        successMessage: 'Payment method added successfully',
      ));
    } catch (e) {
      if (e.toString().toLowerCase().contains('no internet connection')) {
        emit(state.copyWith(
          status: PaymentMethodActionStatus.noConnection,
          errorMessage: e.toString(),
        ));
      } else {
        emit(state.copyWith(
          status: PaymentMethodActionStatus.error,
          errorMessage: e.toString(),
        ));
      }
    }
  }

  /// Update an existing payment method
  Future<void> _onUpdatePaymentMethod(
    UpdatePaymentMethodEvent event,
    Emitter<PaymentMethodActionsState> emit,
  ) async {
    emit(state.copyWith(
      status: PaymentMethodActionStatus.loading,
      actionType: PaymentMethodActionType.update,
    ));

    try {
      // Update payment method
      await paymentMethodRepo.updatePaymentMethod(
        id: event.paymentMethodId,
        paymentMethod: event.paymentMethod,
      );

      emit(state.copyWith(
        status: PaymentMethodActionStatus.success,
        successMessage: 'Payment method updated successfully',
      ));
    } catch (e) {
      if (e.toString().toLowerCase().contains('no internet connection')) {
        emit(state.copyWith(
          status: PaymentMethodActionStatus.noConnection,
          errorMessage: e.toString(),
        ));
      } else {
        emit(state.copyWith(
          status: PaymentMethodActionStatus.error,
          errorMessage: e.toString(),
        ));
      }
    }
  }

  /// Delete a payment method
  Future<void> _onDeletePaymentMethod(
    DeletePaymentMethodEvent event,
    Emitter<PaymentMethodActionsState> emit,
  ) async {
    emit(state.copyWith(
      status: PaymentMethodActionStatus.loading,
      actionType: PaymentMethodActionType.delete,
    ));

    try {
      // Delete payment method
      final result = await paymentMethodRepo.deletePaymentMethod(
        id: event.paymentMethodId,
      );

      emit(state.copyWith(
        status: PaymentMethodActionStatus.success,
        successMessage:
            (result is Map && result.containsKey('message')) ? result['message'] : 'Deleted successfully',
      ));
    } catch (e) {
      if (e.toString().toLowerCase().contains('no internet connection')) {
        emit(state.copyWith(
          status: PaymentMethodActionStatus.noConnection,
          errorMessage: e.toString(),
        ));
      } else {
        emit(state.copyWith(
          status: PaymentMethodActionStatus.error,
          errorMessage: e.toString(),
        ));
      }
    }
  }

  /// Reset actions state
  void _onResetActions(
    ResetPaymentMethodActionsEvent event,
    Emitter<PaymentMethodActionsState> emit,
  ) {
    emit(const PaymentMethodActionsState());
  }
}
