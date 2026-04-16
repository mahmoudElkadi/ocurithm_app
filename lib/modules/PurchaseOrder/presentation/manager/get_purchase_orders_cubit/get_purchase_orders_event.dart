part of 'get_purchase_orders_cubit.dart';

abstract class GetPurchaseOrdersEvent {}

class GetAllPurchaseOrdersEvent extends GetPurchaseOrdersEvent {
  final int? page;
  final String? search;
  final String? supplierId;
  final String? clinicId;
  final String? fromDate;
  final String? toDate;

  GetAllPurchaseOrdersEvent({
    this.page,
    this.search,
    this.supplierId,
    this.clinicId,
    this.fromDate,
    this.toDate,
  });
}

class RefreshPurchaseOrdersEvent extends GetPurchaseOrdersEvent {}

class SetPOPageEvent extends GetPurchaseOrdersEvent {
  final int page;
  SetPOPageEvent(this.page);
}

class SetPOSearchEvent extends GetPurchaseOrdersEvent {
  final String search;
  SetPOSearchEvent(this.search);
}

class SetPOSupplierFilterEvent extends GetPurchaseOrdersEvent {
  final String? supplierId;
  SetPOSupplierFilterEvent(this.supplierId);
}

class SetPOClinicFilterEvent extends GetPurchaseOrdersEvent {
  final String? clinicId;
  SetPOClinicFilterEvent(this.clinicId);
}

class SetPODateRangeFilterEvent extends GetPurchaseOrdersEvent {
  final String? fromDate;
  final String? toDate;
  SetPODateRangeFilterEvent({this.fromDate, this.toDate});
}

class ResetPOFilters extends GetPurchaseOrdersEvent {}
