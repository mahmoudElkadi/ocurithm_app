part of 'get_orders_bloc.dart';

enum GetOrdersStatus { initial, loading, success, error, noConnection }

class GetOrdersState {
  final GetOrdersStatus status;
  final OrderModel? orders;
  final int page;
  final String search;
  final String? statusFilter;
  final String? branchFilter;
  final String? doctorFilter;
  final String? startDate;
  final String? endDate;
  final String? errorMessage;

  const GetOrdersState({
    this.status = GetOrdersStatus.initial,
    this.orders,
    this.page = 1,
    this.search = '',
    this.statusFilter,
    this.branchFilter,
    this.doctorFilter,
    this.startDate,
    this.endDate,
    this.errorMessage,
  });

  bool get noConnection => status == GetOrdersStatus.noConnection;

  GetOrdersState copyWith({
    GetOrdersStatus? status,
    OrderModel? orders,
    int? page,
    String? search,
    String? statusFilter,
    String? branchFilter,
    String? doctorFilter,
    String? startDate,
    String? endDate,
    String? errorMessage,
  }) {
    return GetOrdersState(
      status: status ?? this.status,
      orders: orders ?? this.orders,
      page: page ?? this.page,
      search: search ?? this.search,
      statusFilter: statusFilter ?? this.statusFilter,
      branchFilter: branchFilter ?? this.branchFilter,
      doctorFilter: doctorFilter ?? this.doctorFilter,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}
