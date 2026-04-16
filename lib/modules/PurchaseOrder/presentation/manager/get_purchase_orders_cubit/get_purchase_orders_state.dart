part of 'get_purchase_orders_cubit.dart';

enum GetPurchaseOrdersStatus { initial, loading, success, error, noConnection }

class GetPurchaseOrdersState {
  final GetPurchaseOrdersStatus status;
  final PurchaseOrderListModel? purchaseOrders;
  final String? errorMessage;
  final int page;
  final String search;
  final String? supplierFilter;
  final String? clinicFilter;
  final String? fromDate;
  final String? toDate;

  const GetPurchaseOrdersState({
    this.status = GetPurchaseOrdersStatus.initial,
    this.purchaseOrders,
    this.errorMessage,
    this.page = 1,
    this.search = '',
    this.supplierFilter,
    this.clinicFilter,
    this.fromDate,
    this.toDate,
  });

  bool get isLoading => status == GetPurchaseOrdersStatus.loading;
  bool get isSuccess => status == GetPurchaseOrdersStatus.success;
  bool get isError => status == GetPurchaseOrdersStatus.error;
  bool get noConnection => status == GetPurchaseOrdersStatus.noConnection;

  GetPurchaseOrdersState copyWith({
    GetPurchaseOrdersStatus? status,
    PurchaseOrderListModel? purchaseOrders,
    String? errorMessage,
    int? page,
    String? search,
    String? supplierFilter,
    String? clinicFilter,
    String? fromDate,
    String? toDate,
  }) {
    return GetPurchaseOrdersState(
      status: status ?? this.status,
      purchaseOrders: purchaseOrders ?? this.purchaseOrders,
      errorMessage: errorMessage ?? this.errorMessage,
      page: page ?? this.page,
      search: search ?? this.search,
      supplierFilter: supplierFilter ?? this.supplierFilter,
      clinicFilter: clinicFilter ?? this.clinicFilter,
      fromDate: fromDate ?? this.fromDate,
      toDate: toDate ?? this.toDate,
    );
  }
}
