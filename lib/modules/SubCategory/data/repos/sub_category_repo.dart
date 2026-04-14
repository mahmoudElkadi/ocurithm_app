import '../models/sub_category_model.dart';

abstract class SubCategoryRepo {
  Future<SubCategoryModel> getAllSubCategories({
    int? page,
    int? limit,
    String? search,
    String? pagination,
    String? clinic,
    String? category,
    bool? activeOnly,
  });

  Future<SubCategory> createSubCategory({
    required String name,
    required String clinicId,
    required String categoryId,
    String? description,
    String? image,
    bool? isActive,
  });

  Future<SubCategory> updateSubCategory(
    String id, {
    String? name,
    String? clinicId,
    String? categoryId,
    String? description,
    String? image,
    bool? isActive,
  });

  Future<void> deleteSubCategory(String id);
}
