import '../../../../core/api/api_constants.dart';
import '../../../../core/api/api_handler.dart';
import '../models/order_model.dart';
import 'package:ocurithm/modules/Product/data/models/product_model.dart';
import 'order_repo.dart';

class OrderRepoImpl implements OrderRepo {
  final ApiHandler _apiHandler = ApiHandler();

  @override
  Future<OrderModel> getAllOrders({
    int? page,
    int? limit,
    String? search,
    String? status,
    String? branch,
    String? doctor,
    String? startDate,
    String? endDate,
  }) async {
    try {
      Map<String, dynamic> query = {
        if (page != null) "page": page,
        if (limit != null) "limit": limit,
        if (search != null && search.isNotEmpty) "search": search,
        if (status != null && status.isNotEmpty) "status": status,
        if (branch != null && branch.isNotEmpty) "branch": branch,
        if (doctor != null && doctor.isNotEmpty) "doctor": doctor,
        if (startDate != null && startDate.isNotEmpty) "startDate": startDate,
        if (endDate != null && endDate.isNotEmpty) "endDate": endDate,
      };

      final response = await _apiHandler.get<OrderModel>(
        ApiConstants.orders,
        queryParameters: query,
        cancelKey: 'getAllOrders',
        fromJson: (json) => OrderModel.fromJson(json),
      );

      if (response.success && response.data != null) {
        return response.data!;
      } else {
        throw Exception(response.message ?? 'Failed to fetch orders');
      }
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<Order> getOrderById(String id) async {
    try {
      final response = await _apiHandler.get(
        "${ApiConstants.orders}/$id",
        fromJson: (json) => Order.fromJson(json),
      );
      if (response.success && response.data != null) {
        return response.data!;
      } else {
        throw Exception(response.message ?? 'Failed to fetch order');
      }
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<Order> createOrder({
    required List<Map<String, dynamic>> items,
    String? clinic,
    String? branch,
    String? doctor,
  }) async {
    try {
      final response = await _apiHandler.post(
        ApiConstants.orders,
        data: {
          "items": items,
          if (clinic != null) "clinic": clinic,
          if (branch != null) "branch": branch,
          if (doctor != null) "doctor": doctor,
        },
      );

      if (response.success && response.data != null) {
        return Order.fromJson(response.data);
      } else {
        throw Exception(response.message ?? 'Failed to create order');
      }
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<Order> updateOrder(
    String id, {
    required List<Map<String, dynamic>> items,
    String? branch,
    String? doctor,
    String? clinic,
  }) async {
    try {
      final response = await _apiHandler.put(
        "${ApiConstants.orders}/$id",
        data: {
          "items": items,
          if (branch != null) "branch": branch,
          if (doctor != null) "doctor": doctor,
          if (clinic != null) "clinic": clinic,
        },
      );

      if (response.success && response.data != null) {
        return Order.fromJson(response.data);
      } else {
        throw Exception(response.message ?? 'Failed to update order');
      }
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<Order> cancelOrder(String id) async {
    try {
      final response = await _apiHandler.put(
        "${ApiConstants.orders}/$id/cancel",
        data: {},
      );

      if (response.success && response.data != null) {
        return Order.fromJson(response.data);
      } else {
        throw Exception(response.message ?? 'Failed to cancel order');
      }
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<ProductModel> getProductLookup({
    String? search,
    int? page,
    int? limit,
  }) async {
    try {
      Map<String, dynamic> query = {
        if (page != null) "page": page,
        if (limit != null) "limit": limit,
        if (search != null && search.isNotEmpty) "search": search,
      };

      final response = await _apiHandler.get<ProductModel>(
        ApiConstants.orderProductLookup,
        queryParameters: query,
        cancelKey: 'getOrderProductLookup',
        fromJson: (json) => ProductModel.fromJson(json),
      );

      if (response.success && response.data != null) {
        return response.data!;
      } else {
        throw Exception(response.message ?? 'Failed to fetch product lookup');
      }
    } catch (e) {
      rethrow;
    }
  }
}
