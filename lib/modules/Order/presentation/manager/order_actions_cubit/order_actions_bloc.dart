import 'dart:developer';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../data/models/order_model.dart';
import '../../../data/repos/order_repo.dart';

part 'order_actions_event.dart';
part 'order_actions_state.dart';

class OrderActionsBloc extends Bloc<OrderActionsEvent, OrderActionsState> {
  final OrderRepo _orderRepo;

  OrderActionsBloc(this._orderRepo) : super(const OrderActionsState()) {
    on<CreateOrderEvent>(_onCreateOrder);
    on<UpdateOrderEvent>(_onUpdateOrder);
    on<CancelOrderEvent>(_onCancelOrder);
  }

  Future<void> _onCreateOrder(
      CreateOrderEvent event, Emitter<OrderActionsState> emit) async {
    try {
      emit(state.copyWith(status: OrderActionsStatus.loading));

      final order = await _orderRepo.createOrder(
        items: event.items,
        paymentMethod: event.paymentMethod,
        branch: event.branch,
        doctor: event.doctor,
        clinic: event.clinic,
      );

      emit(state.copyWith(
        status: OrderActionsStatus.success,
        order: order,
      ));
    } catch (e) {
      log(e.toString());
      emit(state.copyWith(
        status: OrderActionsStatus.error,
        errorMessage: e.toString(),
      ));
    }
  }

  Future<void> _onUpdateOrder(
      UpdateOrderEvent event, Emitter<OrderActionsState> emit) async {
    try {
      emit(state.copyWith(status: OrderActionsStatus.loading));

      final order = await _orderRepo.updateOrder(
        event.id,
        items: event.items,
        paymentMethod: event.paymentMethod,
        branch: event.branch,
        doctor: event.doctor,
        clinic: event.clinic,
      );

      emit(state.copyWith(
        status: OrderActionsStatus.success,
        order: order,
      ));
    } catch (e) {
      log(e.toString());
      emit(state.copyWith(
        status: OrderActionsStatus.error,
        errorMessage: e.toString(),
      ));
    }
  }

  Future<void> _onCancelOrder(
      CancelOrderEvent event, Emitter<OrderActionsState> emit) async {
    try {
      emit(state.copyWith(status: OrderActionsStatus.loading));

      final order = await _orderRepo.cancelOrder(event.id);

      emit(state.copyWith(
        status: OrderActionsStatus.success,
        order: order,
      ));
    } catch (e) {
      log(e.toString());
      emit(state.copyWith(
        status: OrderActionsStatus.error,
        errorMessage: e.toString(),
      ));
    }
  }
}
