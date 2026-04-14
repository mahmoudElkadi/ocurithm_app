part of 'category_actions_cubit.dart';

abstract class CategoryActionsEvent {}

class AddCategoryEvent extends CategoryActionsEvent {
  final String name;
  final String clinicId;
  final String? description;
  final String? image;
  final bool? isActive;

  AddCategoryEvent({
    required this.name,
    required this.clinicId,
    this.description,
    this.image,
    this.isActive,
  });
}

class UpdateCategoryEvent extends CategoryActionsEvent {
  final String id;
  final String? name;
  final String? clinicId;
  final String? description;
  final String? image;
  final bool? isActive;

  UpdateCategoryEvent({
    required this.id,
    this.name,
    this.clinicId,
    this.description,
    this.image,
    this.isActive,
  });
}

class DeleteCategoryEvent extends CategoryActionsEvent {
  final String id;

  DeleteCategoryEvent(this.id);
}

class ResetCategoryActionsEvent extends CategoryActionsEvent {}
