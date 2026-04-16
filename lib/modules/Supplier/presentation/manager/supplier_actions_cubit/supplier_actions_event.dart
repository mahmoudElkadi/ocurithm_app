part of 'supplier_actions_cubit.dart';

abstract class SupplierActionsEvent {}

class CreateSupplierEvent extends SupplierActionsEvent {
  final String name;
  final String phoneNumber;
  final String? description;
  final String? clinic;
  final bool? isActive;

  CreateSupplierEvent({
    required this.name,
    required this.phoneNumber,
    this.description,
    this.clinic,
    this.isActive,
  });
}

class UpdateSupplierEvent extends SupplierActionsEvent {
  final String id;
  final String? name;
  final String? phoneNumber;
  final String? description;
  final bool? isActive;

  UpdateSupplierEvent({
    required this.id,
    this.name,
    this.phoneNumber,
    this.description,
    this.isActive,
  });
}

class DeleteSupplierEvent extends SupplierActionsEvent {
  final String id;
  DeleteSupplierEvent(this.id);
}
