part of 'get_products_cubit.dart';

@immutable
abstract class GetProductsEvent {}

class GetAllProductsEvent extends GetProductsEvent {
  final int? page;
  final String? search;
  final String? clinicId;
  final String? subCategoryId;
  final bool? activeOnly;

  GetAllProductsEvent({
    this.page,
    this.search,
    this.clinicId,
    this.subCategoryId,
    this.activeOnly,
  });
}

class RefreshProductsEvent extends GetProductsEvent {}

class SetProductPageEvent extends GetProductsEvent {
  final int? page;

  SetProductPageEvent(this.page);
}

class SetProductSearchEvent extends GetProductsEvent {
  final String? search;

  SetProductSearchEvent(this.search);
}

class SetProductClinicFilterEvent extends GetProductsEvent {
  final String? clinicId;

  SetProductClinicFilterEvent(this.clinicId);
}

class SetProductSubCategoryFilterEvent extends GetProductsEvent {
  final String? subCategoryId;

  SetProductSubCategoryFilterEvent(this.subCategoryId);
}

class SetProductActiveOnlyFilterEvent extends GetProductsEvent {
  final bool? activeOnly;

  SetProductActiveOnlyFilterEvent(this.activeOnly);
}

class ResetProductFilters extends GetProductsEvent {}

class UpdateLocalProductEvent extends GetProductsEvent {
  final Product product;
  UpdateLocalProductEvent(this.product);
}

class DeleteLocalProductEvent extends GetProductsEvent {
  final String productId;
  DeleteLocalProductEvent(this.productId);
}
