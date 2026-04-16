part of 'get_suppliers_cubit.dart';

abstract class GetSuppliersEvent {}

class GetAllSuppliersEvent extends GetSuppliersEvent {
  final int? page;
  final String? search;
  final String? clinicId;
  final bool? activeOnly;

  GetAllSuppliersEvent({this.page, this.search, this.clinicId, this.activeOnly});
}

class RefreshSuppliersEvent extends GetSuppliersEvent {}

class SetSupplierPageEvent extends GetSuppliersEvent {
  final int page;
  SetSupplierPageEvent(this.page);
}

class SetSupplierSearchEvent extends GetSuppliersEvent {
  final String search;
  SetSupplierSearchEvent(this.search);
}

class SetSupplierClinicFilterEvent extends GetSuppliersEvent {
  final String? clinicId;
  SetSupplierClinicFilterEvent(this.clinicId);
}

class SetSupplierActiveOnlyFilterEvent extends GetSuppliersEvent {
  final bool? activeOnly;
  SetSupplierActiveOnlyFilterEvent(this.activeOnly);
}

class ResetSupplierFilters extends GetSuppliersEvent {}

class UpdateLocalSupplierEvent extends GetSuppliersEvent {
  final Supplier supplier;
  UpdateLocalSupplierEvent(this.supplier);
}

class DeleteLocalSupplierEvent extends GetSuppliersEvent {
  final String supplierId;
  DeleteLocalSupplierEvent(this.supplierId);
}
