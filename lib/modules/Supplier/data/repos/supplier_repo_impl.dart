import '../../../../core/api/api_constants.dart';
import '../../../../core/api/api_handler.dart';
import '../models/supplier_model.dart';
import 'supplier_repo.dart';

class SupplierRepoImpl implements SupplierRepo {
  final ApiHandler _apiHandler = ApiHandler();

  @override
  Future<SupplierModel> getAllSuppliers({
    int? page,
    int? limit,
    String? search,
    String? clinic,
    bool? activeOnly,
  }) async {
    try {
      Map<String, dynamic> query = {
        if (page != null) "page": page,
        if (limit != null) "limit": limit,
        if (search != null && search.isNotEmpty) "search": search,
        if (clinic != null && clinic.isNotEmpty) "clinic": clinic,
        if (activeOnly != null) "activeOnly": activeOnly.toString(),
      };

      final response = await _apiHandler.get<SupplierModel>(
        ApiConstants.suppliers,
        queryParameters: query,
        cancelKey: 'getAllSuppliers',
        fromJson: (json) => SupplierModel.fromJson(json),
      );

      if (response.success && response.data != null) {
        return response.data!;
      } else {
        throw Exception(response.message ?? 'Failed to fetch suppliers');
      }
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<Supplier> getSupplierById(String id) async {
    try {
      final response = await _apiHandler.get(
        "${ApiConstants.suppliers}/$id",
        fromJson: (json) => Supplier.fromJson(json),
      );
      if (response.success && response.data != null) {
        return response.data!;
      } else {
        throw Exception(response.message ?? 'Failed to fetch supplier');
      }
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<Supplier> createSupplier({
    required String name,
    required String phoneNumber,
    String? description,
    String? clinic,
    bool? isActive,
  }) async {
    try {
      final response = await _apiHandler.post(
        ApiConstants.suppliers,
        data: {
          "name": name,
          "phoneNumber": phoneNumber,
          if (description != null) "description": description,
          if (clinic != null) "clinic": clinic,
          if (isActive != null) "isActive": isActive,
        },
      );

      if (response.success && response.data != null) {
        return Supplier.fromJson(response.data);
      } else {
        throw Exception(response.message ?? 'Failed to create supplier');
      }
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<Supplier> updateSupplier(
    String id, {
    String? name,
    String? phoneNumber,
    String? description,
    bool? isActive,
  }) async {
    try {
      final response = await _apiHandler.put(
        "${ApiConstants.suppliers}/$id",
        data: {
          if (name != null) "name": name,
          if (phoneNumber != null) "phoneNumber": phoneNumber,
          if (description != null) "description": description,
          if (isActive != null) "isActive": isActive,
        },
      );

      if (response.success && response.data != null) {
        return Supplier.fromJson(response.data);
      } else {
        throw Exception(response.message ?? 'Failed to update supplier');
      }
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> deleteSupplier(String id) async {
    try {
      final response = await _apiHandler.delete("${ApiConstants.suppliers}/$id");
      if (!response.success) {
        throw Exception(response.message ?? 'Failed to delete supplier');
      }
    } catch (e) {
      rethrow;
    }
  }
}
