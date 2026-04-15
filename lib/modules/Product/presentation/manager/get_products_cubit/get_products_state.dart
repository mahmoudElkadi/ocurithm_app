part of 'get_products_cubit.dart';

enum GetProductsStatus { initial, loading, success, error, noConnection }

class GetProductsState {
  final GetProductsStatus status;
  final ProductModel? products;
  final String? errorMessage;
  final int page;
  final String search;
  final String? clinicFilter;
  final String? subCategoryFilter;
  final bool? activeOnly;

  const GetProductsState({
    this.status = GetProductsStatus.initial,
    this.products,
    this.errorMessage,
    this.page = 1,
    this.search = '',
    this.clinicFilter,
    this.subCategoryFilter,
    this.activeOnly,
  });

  bool get noConnection => status == GetProductsStatus.noConnection;
  bool get isLoading => status == GetProductsStatus.loading;

  GetProductsState copyWith({
    GetProductsStatus? status,
    ProductModel? products,
    String? errorMessage,
    int? page,
    String? search,
    String? clinicFilter,
    String? subCategoryFilter,
    bool? activeOnly,
  }) {
    return GetProductsState(
      status: status ?? this.status,
      products: products ?? this.products,
      errorMessage: errorMessage ?? this.errorMessage,
      page: page ?? this.page,
      search: search ?? this.search,
      clinicFilter: clinicFilter ?? this.clinicFilter,
      subCategoryFilter: subCategoryFilter ?? this.subCategoryFilter,
      activeOnly: activeOnly ?? this.activeOnly,
    );
  }
}
