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
      // Check internet connection
      final hasConnection = await InternetConnection().hasInternetAccess;
      if (!hasConnection) {
        emit(state.copyWith(
          status: PaymentMethodActionStatus.noConnection,
          errorMessage: 'No internet connection',
        ));
        return;
      }

      // Create payment method
      final result = await paymentMethodRepo.createPaymentMethod(
        paymentMethod: event.paymentMethod,
      );

      if (result.error == null && (result.title != null || result.id != null)) {
        emit(state.copyWith(
          status: PaymentMethodActionStatus.success,
          successMessage: 'Payment method added successfully',
        ));
      } else {
        emit(state.copyWith(
          status: PaymentMethodActionStatus.error,
          errorMessage: result.error ?? 'Failed to add payment method',
        ));
      }
    } catch (e) {
      emit(state.copyWith(
        status: PaymentMethodActionStatus.error,
        errorMessage: 'An error occurred: ${e.toString()}',
      ));
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
      // Check internet connection
      final hasConnection = await InternetConnection().hasInternetAccess;
      if (!hasConnection) {
        emit(state.copyWith(
          status: PaymentMethodActionStatus.noConnection,
          errorMessage: 'No internet connection',
        ));
        return;
      }

      // Update payment method
      final result = await paymentMethodRepo.updatePaymentMethod(
        id: event.paymentMethodId,
        paymentMethod: event.paymentMethod,
      );

      if (result.error == null && (result.title != null || result.id != null)) {
        emit(state.copyWith(
          status: PaymentMethodActionStatus.success,
          successMessage: 'Payment method updated successfully',
        ));
      } else {
        emit(state.copyWith(
          status: PaymentMethodActionStatus.error,
          errorMessage: result.error ?? 'Failed to update payment method',
        ));
      }
    } catch (e) {
      emit(state.copyWith(
        status: PaymentMethodActionStatus.error,
        errorMessage: 'An error occurred: ${e.toString()}',
      ));
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
      // Check internet connection
      final hasConnection = await InternetConnection().hasInternetAccess;
      if (!hasConnection) {
        emit(state.copyWith(
          status: PaymentMethodActionStatus.noConnection,
          errorMessage: 'No internet connection',
        ));
        return;
      }

      // Delete payment method
      final result = await paymentMethodRepo.deletePaymentMethod(
        id: event.paymentMethodId,
      );

      if (result.error == null && result.message != null) {
        emit(state.copyWith(
          status: PaymentMethodActionStatus.success,
          successMessage: result.message,
        ));
      } else {
        emit(state.copyWith(
          status: PaymentMethodActionStatus.error,
          errorMessage: result.error ?? 'Failed to delete payment method',
        ));
      }
    } catch (e) {
      emit(state.copyWith(
        status: PaymentMethodActionStatus.error,
        errorMessage: 'An error occurred: ${e.toString()}',
      ));
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
