import '../models/purchase_order_model.dart';
import 'package:ocurithm/modules/Product/data/models/product_model.dart';

abstract class PurchaseOrderRepo {
  Future<PurchaseOrderListModel> getAllPurchaseOrders({
    int? page,
    int? limit,
    String? search,
    String? supplierId,
    String? clinicId,
    String? fromDate,
    String? toDate,
  });

  Future<PurchaseOrderDetails> getPurchaseOrderById(String id);

  Future<PurchaseOrderDetails> createPurchaseOrder(CreatePurchaseOrderRequest request);

  Future<void> deletePurchaseOrder(String id);

  Future<Product> lookupProductBySku(String sku);
}
