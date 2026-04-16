part of 'purchase_order_actions_cubit.dart';

abstract class PurchaseOrderActionsEvent {}

class CreatePOEvent extends PurchaseOrderActionsEvent {
  final CreatePurchaseOrderRequest request;
  CreatePOEvent(this.request);
}

class DeletePOEvent extends PurchaseOrderActionsEvent {
  final String id;
  DeletePOEvent(this.id);
}

class GetPODetailsEvent extends PurchaseOrderActionsEvent {
  final String id;
  GetPODetailsEvent(this.id);
}
