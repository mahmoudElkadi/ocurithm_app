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
      // Fetch payment method
      final result = await paymentMethodRepo.getPaymentMethod(
        id: event.paymentMethodId,
      );

      emit(state.copyWith(
        status: SinglePaymentMethodStatus.success,
        paymentMethod: result,
      ));
    } catch (e) {
      if (e.toString().toLowerCase().contains('no internet connection')) {
        emit(state.copyWith(
          status: SinglePaymentMethodStatus.noConnection,
          errorMessage: e.toString(),
        ));
      } else {
        emit(state.copyWith(
          status: SinglePaymentMethodStatus.error,
          errorMessage: e.toString(),
        ));
      }
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
