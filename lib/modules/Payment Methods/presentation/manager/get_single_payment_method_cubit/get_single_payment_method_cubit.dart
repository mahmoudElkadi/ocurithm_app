import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';

import '../../../data/model/payment_method_model.dart';
import '../../../data/repos/payment_method_repo.dart';

part 'get_single_payment_method_event.dart';
part 'get_single_payment_method_state.dart';

/// Cubit for fetching a single payment method by ID
class GetSinglePaymentMethodCubit
    extends Bloc<GetSinglePaymentMethodEvent, GetSinglePaymentMethodState> {
  final PaymentMethodRepo paymentMethodRepo;

  GetSinglePaymentMethodCubit(this.paymentMethodRepo)
      : super(const GetSinglePaymentMethodState()) {
    on<GetPaymentMethodByIdEvent>(_onGetPaymentMethodById);
    on<ResetSinglePaymentMethodEvent>(_onResetSinglePaymentMethod);
  }

  /// Fetch a single payment method by ID
  Future<void> _onGetPaymentMethodById(
    GetPaymentMethodByIdEvent event,
    Emitter<GetSinglePaymentMethodState> emit,
  ) async {
    emit(state.copyWith(
      status: SinglePaymentMethodStatus.loading,
      errorMessage: null,
    ));

    try {
      // Check internet connection
      final hasConnection = await InternetConnection().hasInternetAccess;
      if (!hasConnection) {
        emit(state.copyWith(
          status: SinglePaymentMethodStatus.noConnection,
          errorMessage: 'No internet connection',
        ));
        return;
      }

      // Fetch payment method
      final result = await paymentMethodRepo.getPaymentMethod(
        id: event.paymentMethodId,
      );

      if (result.error == null) {
        emit(state.copyWith(
          status: SinglePaymentMethodStatus.success,
          paymentMethod: result,
        ));
      } else {
        emit(state.copyWith(
          status: SinglePaymentMethodStatus.error,
          errorMessage: result.error ?? 'Failed to load payment method',
        ));
      }
    } catch (e) {
      emit(state.copyWith(
        status: SinglePaymentMethodStatus.error,
        errorMessage: 'An error occurred: ${e.toString()}',
      ));
    }
  }

  /// Reset the state
  void _onResetSinglePaymentMethod(
    ResetSinglePaymentMethodEvent event,
    Emitter<GetSinglePaymentMethodState> emit,
  ) {
    emit(const GetSinglePaymentMethodState());
  }
}
