part of 'get_categories_cubit.dart';

enum GetCategoriesStatus { initial, loading, success, error, noConnection }

class GetCategoriesState {
  final GetCategoriesStatus status;
  final CategoryModel? categories;
  final String? errorMessage;
  final int page;
  final String search;
  final String? clinicFilter;

  final String? pagination;

  const GetCategoriesState({
    this.status = GetCategoriesStatus.initial,
    this.categories,
    this.errorMessage,
    this.page = 1,
    this.search = '',
    this.clinicFilter,
    this.pagination = "false",
  });

  bool get noConnection => status == GetCategoriesStatus.noConnection;
  bool get isLoading => status == GetCategoriesStatus.loading;

  GetCategoriesState copyWith({
    GetCategoriesStatus? status,
    CategoryModel? categories,
    String? errorMessage,
    int? page,
    String? search,
    String? clinicFilter,
    String? pagination,
  }) {
    return GetCategoriesState(
      status: status ?? this.status,
      categories: categories ?? this.categories,
      errorMessage: errorMessage ?? this.errorMessage,
      page: page ?? this.page,
      search: search ?? this.search,
      clinicFilter: clinicFilter ?? this.clinicFilter,
      pagination: pagination ?? this.pagination,
    );
  }
}
