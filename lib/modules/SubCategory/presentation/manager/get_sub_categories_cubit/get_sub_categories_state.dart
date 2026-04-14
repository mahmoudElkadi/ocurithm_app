part of 'get_sub_categories_cubit.dart';

enum GetSubCategoriesStatus { initial, loading, success, error, noConnection }

class GetSubCategoriesState {
  final GetSubCategoriesStatus status;
  final SubCategoryModel? subCategories;
  final String search;
  final int page;
  final String? clinicFilter;
  final String? categoryFilter;
  final String? errorMessage;
  final String pagination;

  GetSubCategoriesState({
    this.status = GetSubCategoriesStatus.initial,
    this.subCategories,
    this.search = '',
    this.page = 1,
    this.clinicFilter,
    this.categoryFilter,
    this.errorMessage,
    this.pagination = "false",
  });

  bool get isLoading => status == GetSubCategoriesStatus.loading;
  bool get isSuccess => status == GetSubCategoriesStatus.success;
  bool get isError => status == GetSubCategoriesStatus.error;
  bool get noConnection => status == GetSubCategoriesStatus.noConnection;

  GetSubCategoriesState copyWith({
    GetSubCategoriesStatus? status,
    SubCategoryModel? subCategories,
    String? search,
    int? page,
    String? clinicFilter,
    String? categoryFilter,
    String? errorMessage,
    String? pagination,
  }) {
    return GetSubCategoriesState(
      status: status ?? this.status,
      subCategories: subCategories ?? this.subCategories,
      search: search ?? this.search,
      page: page ?? this.page,
      clinicFilter: clinicFilter ?? this.clinicFilter,
      categoryFilter: categoryFilter ?? this.categoryFilter,
      errorMessage: errorMessage ?? this.errorMessage,
      pagination: pagination ?? this.pagination,
    );
  }
}
