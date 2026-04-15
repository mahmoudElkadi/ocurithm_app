part of 'product_actions_cubit.dart';

@immutable
abstract class ProductActionsEvent {}

class CreateProductEvent extends ProductActionsEvent {
  final String name;
  final num price;
  final String subCategory;
  final String? clinic;
  final String? description;
  final String? image;
  final String? sku;
  final bool? isActive;

  CreateProductEvent({
    required this.name,
    required this.price,
    required this.subCategory,
    this.clinic,
    this.description,
    this.image,
    this.sku,
    this.isActive,
  });
}

class UpdateProductEvent extends ProductActionsEvent {
  final String id;
  final String? name;
  final num? price;
  final String? subCategory;
  final String? description;
  final String? image;
  final String? sku;
  final bool? isActive;

  UpdateProductEvent({
    required this.id,
    this.name,
    this.price,
    this.subCategory,
    this.description,
    this.image,
    this.sku,
    this.isActive,
  });
}

class DeleteProductEvent extends ProductActionsEvent {
  final String id;

  DeleteProductEvent(this.id);
}
