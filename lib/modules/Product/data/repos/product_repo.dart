import '../models/product_model.dart';

abstract class ProductRepo {
  Future<ProductModel> getAllProducts({
    int? page,
    int? limit,
    String? search,
    String? clinic,
    String? subCategory,
    bool? activeOnly,
  });

  Future<Product> getProductById(String id);

  Future<Product> createProduct({
    required String name,
    required num price,
    required String subCategory,
    String? clinic,
    String? description,
    String? image,
    String? sku,
    bool? isActive,
  });

  Future<Product> updateProduct(
    String id, {
    String? name,
    num? price,
    String? subCategory,
    String? description,
    String? image,
    String? sku,
    bool? isActive,
  });

  Future<void> deleteProduct(String id);
}
