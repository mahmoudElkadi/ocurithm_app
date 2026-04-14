import '../models/category_model.dart';

abstract class CategoryRepo {
  /// Get all categories with optional filters
  Future<CategoryModel> getAllCategories({
    int? page,
    int? limit,
    String? search,
    String? pagination,
    String? clinic,
    bool? activeOnly,
  });

  Future<Category> createCategory({
    required String name,
    required String clinic,
    String? description,
    String? image,
    bool? isActive,
  });

  Future<Category> updateCategory(
    String id, {
    String? name,
    String? clinic,
    String? description,
    String? image,
    bool? isActive,
  });

  Future<void> deleteCategory(String id);
}
