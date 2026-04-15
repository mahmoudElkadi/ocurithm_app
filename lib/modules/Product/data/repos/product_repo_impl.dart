import '../../../../core/api/api_constants.dart';
import '../../../../core/api/api_handler.dart';
import '../models/product_model.dart';
import 'product_repo.dart';

class ProductRepoImpl implements ProductRepo {
  final ApiHandler _apiHandler = ApiHandler();

  @override
  Future<ProductModel> getAllProducts({
    int? page,
    int? limit,
    String? search,
    String? clinic,
    String? subCategory,
    bool? activeOnly,
  }) async {
    try {
      Map<String, dynamic> query = {
        if (page != null) "page": page,
        if (limit != null) "limit": limit,
        if (search != null && search.isNotEmpty) "search": search,
        if (clinic != null && clinic.isNotEmpty) "clinic": clinic,
        if (subCategory != null && subCategory.isNotEmpty)
          "subCategory": subCategory,
        if (activeOnly != null) "activeOnly": activeOnly.toString(),
      };

      final response = await _apiHandler.get<ProductModel>(
        ApiConstants.products,
        queryParameters: query,
        cancelKey: 'getAllProducts',
        fromJson: (json) => ProductModel.fromJson(json),
      );

      if (response.success && response.data != null) {
        return response.data!;
      } else {
        throw Exception(response.message ?? 'Failed to fetch products');
      }
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<Product> getProductById(String id) async {
    try {
      final response = await _apiHandler.get(
        "${ApiConstants.products}/$id",
        fromJson: (json) => Product.fromJson(json),
      );
      if (response.success && response.data != null) {
        return response.data!;
      } else {
        throw Exception(response.message ?? 'Failed to fetch product');
      }
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<Product> createProduct({
    required String name,
    required num price,
    required String subCategory,
    String? clinic,
    String? description,
    String? image,
    String? sku,
    bool? isActive,
  }) async {
    try {
      final response = await _apiHandler.post(
        ApiConstants.products,
        data: {
          "name": name,
          "price": price,
          "subCategory": subCategory,
          if (clinic != null) "clinic": clinic,
          if (description != null) "description": description,
          if (image != null) "image": image,
          if (sku != null) "sku": sku,
          if (isActive != null) "isActive": isActive,
        },
      );
      
      if (response.success && response.data != null) {
         return Product.fromJson(response.data);
      } else {
        throw Exception(response.message ?? 'Failed to create product');
      }
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<Product> updateProduct(
    String id, {
    String? name,
    num? price,
    String? subCategory,
    String? description,
    String? image,
    String? sku,
    bool? isActive,
  }) async {
    try {
      final response = await _apiHandler.put(
        "${ApiConstants.products}/$id",
        data: {
          if (name != null) "name": name,
          if (price != null) "price": price,
          if (subCategory != null) "subCategory": subCategory,
          if (description != null) "description": description,
          if (image != null) "image": image,
          if (sku != null) "sku": sku,
          if (isActive != null) "isActive": isActive,
        },
      );
      
      if (response.success && response.data != null) {
         return Product.fromJson(response.data);
      } else {
        throw Exception(response.message ?? 'Failed to update product');
      }
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> deleteProduct(String id) async {
    try {
      final response = await _apiHandler.delete("${ApiConstants.products}/$id");
      if (!response.success) {
        throw Exception(response.message ?? 'Failed to delete product');
      }
    } catch (e) {
      rethrow;
    }
  }
}
