part of 'order_actions_bloc.dart';

abstract class OrderActionsEvent {}

class CreateOrderEvent extends OrderActionsEvent {
  final List<Map<String, dynamic>> items;
  final String? branch;
  final String? doctor;
  final String? clinic;
  CreateOrderEvent({required this.items, this.branch, this.doctor, this.clinic});
}

class UpdateOrderEvent extends OrderActionsEvent {
  final String id;
  final List<Map<String, dynamic>> items;
  final String? branch;
  final String? doctor;
  final String? clinic;
  UpdateOrderEvent({required this.id, required this.items, this.branch, this.doctor, this.clinic});
}

class CancelOrderEvent extends OrderActionsEvent {
  final String id;
  CancelOrderEvent(this.id);
}
