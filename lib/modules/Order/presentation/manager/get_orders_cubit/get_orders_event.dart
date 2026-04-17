part of 'get_orders_bloc.dart';

abstract class GetOrdersEvent {}

class GetAllOrdersEvent extends GetOrdersEvent {
  final int? page;
  final String? search;
  final String? status;
  final String? branch;
  final String? doctor;
  final String? startDate;
  final String? endDate;

  GetAllOrdersEvent({
    this.page,
    this.search,
    this.status,
    this.branch,
    this.doctor,
    this.startDate,
    this.endDate,
  });
}

class ResetOrderFilters extends GetOrdersEvent {}

class SetOrderSearchEvent extends GetOrdersEvent {
  final String search;
  SetOrderSearchEvent(this.search);
}

class SetOrderPageEvent extends GetOrdersEvent {
  final int page;
  SetOrderPageEvent(this.page);
}

class SetOrderStatusFilterEvent extends GetOrdersEvent {
  final String? status;
  SetOrderStatusFilterEvent(this.status);
}

class SetOrderBranchFilterEvent extends GetOrdersEvent {
  final String? branch;
  SetOrderBranchFilterEvent(this.branch);
}

class SetOrderDoctorFilterEvent extends GetOrdersEvent {
  final String? doctor;
  SetOrderDoctorFilterEvent(this.doctor);
}

class SetOrderDateRangeFilterEvent extends GetOrdersEvent {
  final String? startDate;
  final String? endDate;
  SetOrderDateRangeFilterEvent({this.startDate, this.endDate});
}
