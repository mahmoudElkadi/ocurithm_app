import '../../../../core/api/api_constants.dart';
import '../../../../core/api/api_handler.dart';
import '../models/purchase_order_model.dart';
import 'purchase_order_repo.dart';
import 'package:ocurithm/modules/Product/data/models/product_model.dart';

class PurchaseOrderRepoImpl implements PurchaseOrderRepo {
  final ApiHandler _apiHandler = ApiHandler();

  @override
  Future<PurchaseOrderListModel> getAllPurchaseOrders({
    int? page,
    int? limit,
    String? search,
    String? supplierId,
    String? clinicId,
    String? fromDate,
    String? toDate,
  }) async {
    try {
      Map<String, dynamic> query = {
        if (page != null) "page": page,
        if (limit != null) "limit": limit,
        if (search != null && search.isNotEmpty) "search": search,
        if (supplierId != null && supplierId.isNotEmpty) "supplier": supplierId,
        if (clinicId != null && clinicId.isNotEmpty) "clinic": clinicId,
        if (fromDate != null) "fromDate": fromDate,
        if (toDate != null) "toDate": toDate,
      };

      final response = await _apiHandler.get<PurchaseOrderListModel>(
        ApiConstants.purchaseOrders,
        queryParameters: query,
        cancelKey: 'getAllPurchaseOrders',
        fromJson: (json) => PurchaseOrderListModel.fromJson(json),
      );

      if (response.success && response.data != null) {
        return response.data!;
      } else {
        throw Exception(response.message ?? 'Failed to fetch purchase orders');
      }
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<PurchaseOrderDetails> getPurchaseOrderById(String id) async {
    try {
      final response = await _apiHandler.get(
        "${ApiConstants.purchaseOrders}/$id",
        fromJson: (json) => PurchaseOrderDetails.fromJson(json),
      );
      if (response.success && response.data != null) {
        return response.data!;
      } else {
        throw Exception(response.message ?? 'Failed to fetch purchase order details');
      }
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<PurchaseOrderDetails> createPurchaseOrder(CreatePurchaseOrderRequest request) async {
    try {
      final response = await _apiHandler.post(
        ApiConstants.purchaseOrders,
        data: request.toJson(),
      );

      if (response.success && response.data != null) {
        return PurchaseOrderDetails.fromJson(response.data);
      } else {
        throw Exception(response.message ?? 'Failed to create purchase order');
      }
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> deletePurchaseOrder(String id) async {
    try {
      final response = await _apiHandler.delete("${ApiConstants.purchaseOrders}/$id");
      if (!response.success) {
        throw Exception(response.message ?? 'Failed to delete purchase order');
      }
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<Product> lookupProductBySku(String sku) async {
    try {
      final response = await _apiHandler.get(
        ApiConstants.poProductLookup,
        queryParameters: {"sku": sku},
        fromJson: (json) => Product.fromJson(json),
      );
      if (response.success && response.data != null) {
        return response.data!;
      } else {
        throw Exception(response.message ?? 'Product not found');
      }
    } catch (e) {
      rethrow;
    }
  }
}
