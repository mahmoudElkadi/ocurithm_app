part of 'sub_category_actions_cubit.dart';

abstract class SubCategoryActionsEvent {}

class AddSubCategoryEvent extends SubCategoryActionsEvent {
  final String name;
  final String clinicId;
  final String categoryId;
  final String? description;
  final String? image;
  final bool? isActive;

  AddSubCategoryEvent({
    required this.name,
    required this.clinicId,
    required this.categoryId,
    this.description,
    this.image,
    this.isActive,
  });
}

class UpdateSubCategoryEvent extends SubCategoryActionsEvent {
  final String id;
  final String? name;
  final String? clinicId;
  final String? categoryId;
  final String? description;
  final String? image;
  final bool? isActive;

  UpdateSubCategoryEvent({
    required this.id,
    this.name,
    this.clinicId,
    this.categoryId,
    this.description,
    this.image,
    this.isActive,
  });
}

class DeleteSubCategoryEvent extends SubCategoryActionsEvent {
  final String id;

  DeleteSubCategoryEvent(this.id);
}

class ResetSubCategoryActionsEvent extends SubCategoryActionsEvent {}
