import '../models/supplier_model.dart';

abstract class SupplierRepo {
  Future<SupplierModel> getAllSuppliers({
    int? page,
    int? limit,
    String? search,
    String? clinic,
    bool? activeOnly,
  });

  Future<Supplier> getSupplierById(String id);

  Future<Supplier> createSupplier({
    required String name,
    required String phoneNumber,
    String? description,
    String? clinic,
    bool? isActive,
  });

  Future<Supplier> updateSupplier(
    String id, {
    String? name,
    String? phoneNumber,
    String? description,
    bool? isActive,
  });

  Future<void> deleteSupplier(String id);
}
