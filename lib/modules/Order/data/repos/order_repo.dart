import '../models/order_model.dart';
import 'package:ocurithm/modules/Product/data/models/product_model.dart';

abstract class OrderRepo {
  Future<OrderModel> getAllOrders({
    int? page,
    int? limit,
    String? search,
    String? status,
    String? branch,
    String? doctor,
    String? startDate,
    String? endDate,
  });

  Future<Order> getOrderById(String id);

  /// [paymentMethod] is required by the API on both create and update —
  /// orders.service.ts throws `Payment method must be provided` without it, and
  /// it is what the automatic account transaction is credited against.
  Future<Order> createOrder({
    required List<Map<String, dynamic>> items,
    required String paymentMethod,
    String? clinic,
    String? branch,
    String? doctor,
  });

  Future<Order> updateOrder(
    String id, {
    required List<Map<String, dynamic>> items,
    required String paymentMethod,
    String? branch,
    String? doctor,
    String? clinic,
  });

  Future<Order> cancelOrder(String id);

  Future<ProductModel> getProductLookup({
    String? search,
    int? page,
    int? limit,
  });
}
