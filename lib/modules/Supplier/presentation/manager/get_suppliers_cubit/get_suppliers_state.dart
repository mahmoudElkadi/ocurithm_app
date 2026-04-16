part of 'get_suppliers_cubit.dart';

enum GetSuppliersStatus { initial, loading, success, error, noConnection }

class GetSuppliersState {
  final GetSuppliersStatus status;
  final SupplierModel? suppliers;
  final String? errorMessage;
  final int page;
  final String search;
  final String? clinicFilter;
  final bool? activeOnly;

  const GetSuppliersState({
    this.status = GetSuppliersStatus.initial,
    this.suppliers,
    this.errorMessage,
    this.page = 1,
    this.search = '',
    this.clinicFilter,
    this.activeOnly,
  });

  bool get isLoading => status == GetSuppliersStatus.loading;
  bool get isSuccess => status == GetSuppliersStatus.success;
  bool get isError => status == GetSuppliersStatus.error;
  bool get noConnection => status == GetSuppliersStatus.noConnection;

  GetSuppliersState copyWith({
    GetSuppliersStatus? status,
    SupplierModel? suppliers,
    String? errorMessage,
    int? page,
    String? search,
    String? clinicFilter,
    bool? activeOnly,
  }) {
    return GetSuppliersState(
      status: status ?? this.status,
      suppliers: suppliers ?? this.suppliers,
      errorMessage: errorMessage ?? this.errorMessage,
      page: page ?? this.page,
      search: search ?? this.search,
      clinicFilter: clinicFilter ?? this.clinicFilter,
      activeOnly: activeOnly ?? this.activeOnly,
    );
  }
}
