part of 'get_categories_cubit.dart';

@immutable
abstract class GetCategoriesEvent {}

class GetAllCategoriesEvent extends GetCategoriesEvent {
  final int? page;
  final String? search;
  final String? clinicId;

  GetAllCategoriesEvent({this.page, this.search, this.clinicId});
}

class RefreshCategoriesEvent extends GetCategoriesEvent {}

class SetPageEvent extends GetCategoriesEvent {
  final int? page;

  SetPageEvent(this.page);
}

class SetSearchEvent extends GetCategoriesEvent {
  final String? search;

  SetSearchEvent(this.search);
}

class SetClinicFilterEvent extends GetCategoriesEvent {
  final String? clinicId;

  SetClinicFilterEvent(this.clinicId);
}

class SetPaginationEvent extends GetCategoriesEvent {
  final String? pagination;

  SetPaginationEvent(this.pagination);
}

class ResetCategoryFilters extends GetCategoriesEvent {}
