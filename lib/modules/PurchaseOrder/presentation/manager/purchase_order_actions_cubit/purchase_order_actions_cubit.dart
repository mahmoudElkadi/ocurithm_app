import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../data/models/purchase_order_model.dart';
import '../../../data/repos/purchase_order_repo.dart';

part 'purchase_order_actions_event.dart';
part 'purchase_order_actions_state.dart';

class PurchaseOrderActionsCubit extends Bloc<PurchaseOrderActionsEvent, PurchaseOrderActionsState> {
  final PurchaseOrderRepo _purchaseOrderRepo;

  PurchaseOrderActionsCubit(this._purchaseOrderRepo) : super(const PurchaseOrderActionsState()) {
    on<CreatePOEvent>(_onCreatePO);
    on<DeletePOEvent>(_onDeletePO);
    on<GetPODetailsEvent>(_onGetPODetails);
  }

  Future<void> _onCreatePO(
      CreatePOEvent event, Emitter<PurchaseOrderActionsState> emit) async {
    emit(state.copyWith(status: PurchaseOrderActionsStatus.loading));
    try {
      final details = await _purchaseOrderRepo.createPurchaseOrder(event.request);
      emit(state.copyWith(
        status: PurchaseOrderActionsStatus.success,
        successMessage: 'Purchase Order created successfully',
        orderDetails: details,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: PurchaseOrderActionsStatus.error,
        errorMessage: e.toString(),
      ));
    }
  }

  Future<void> _onDeletePO(
      DeletePOEvent event, Emitter<PurchaseOrderActionsState> emit) async {
    emit(state.copyWith(status: PurchaseOrderActionsStatus.loading, actingId: event.id));
    try {
      await _purchaseOrderRepo.deletePurchaseOrder(event.id);
      emit(state.copyWith(
        status: PurchaseOrderActionsStatus.success,
        successMessage: 'Purchase Order deleted successfully',
        actingId: event.id,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: PurchaseOrderActionsStatus.error,
        errorMessage: e.toString(),
      ));
    }
  }

  Future<void> _onGetPODetails(
      GetPODetailsEvent event, Emitter<PurchaseOrderActionsState> emit) async {
    emit(state.copyWith(status: PurchaseOrderActionsStatus.loading));
    try {
      final details = await _purchaseOrderRepo.getPurchaseOrderById(event.id);
      emit(state.copyWith(
        status: PurchaseOrderActionsStatus.success,
        orderDetails: details,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: PurchaseOrderActionsStatus.error,
        errorMessage: e.toString(),
      ));
    }
  }
}
