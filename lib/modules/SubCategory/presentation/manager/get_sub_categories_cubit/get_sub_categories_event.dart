part of 'get_sub_categories_cubit.dart';

abstract class GetSubCategoriesEvent {}

class GetAllSubCategoriesEvent extends GetSubCategoriesEvent {
  final bool? noPagination;
  GetAllSubCategoriesEvent({this.noPagination});
}

class SetSubCategorySearchEvent extends GetSubCategoriesEvent {
  final String search;
  SetSubCategorySearchEvent(this.search);
}

class SetSubCategoryClinicFilterEvent extends GetSubCategoriesEvent {
  final String? clinicId;
  SetSubCategoryClinicFilterEvent(this.clinicId);
}

class SetSubCategoryCategoryFilterEvent extends GetSubCategoriesEvent {
  final String? categoryId;
  SetSubCategoryCategoryFilterEvent(this.categoryId);
}

class SetSubCategoryPaginationEvent extends GetSubCategoriesEvent {
  final String pagination;
  SetSubCategoryPaginationEvent(this.pagination);
}

class ResetSubCategoryFilters extends GetSubCategoriesEvent {}
