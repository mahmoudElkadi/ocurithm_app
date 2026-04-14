import '../../../../core/api/api_constants.dart';
import '../../../../core/api/api_handler.dart';
import '../models/sub_category_model.dart';
import 'sub_category_repo.dart';

class SubCategoryRepoImpl implements SubCategoryRepo {
  final ApiHandler _apiHandler = ApiHandler();

  @override
  Future<SubCategoryModel> getAllSubCategories({
    int? page,
    int? limit,
    String? search,
    String? pagination,
    String? clinic,
    String? category,
    bool? activeOnly,
  }) async {
    try {
      Map<String, dynamic> query = {
        if (page != null) "page": page,
        if (limit != null) "limit": limit,
        if (search != null && search.isNotEmpty) "search": search,
        if (pagination != null) "pagination": pagination,
        if (clinic != null && clinic.isNotEmpty) "clinic": clinic,
        if (category != null && category.isNotEmpty) "category": category,
        if (activeOnly != null) "activeOnly": activeOnly.toString(),
      };

      final response = await _apiHandler.get<SubCategoryModel>(
        ApiConstants.subCategories,
        queryParameters: query,
        cancelKey: 'getAllSubCategories',
        fromJson: (json) => SubCategoryModel.fromJson(json),
      );

      if (response.success && response.data != null) {
        return response.data!;
      } else {
        throw Exception(response.message ?? 'Failed to fetch sub-categories');
      }
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<SubCategory> createSubCategory({
    required String name,
    required String clinicId,
    required String categoryId,
    String? description,
    String? image,
    bool? isActive,
  }) async {
    try {
      final response = await _apiHandler.post(
        ApiConstants.subCategories,
        data: {
          "name": name,
          "clinic": clinicId,
          "category": categoryId,
          if (description != null) "description": description,
          if (image != null) "image": image,
          if (isActive != null) "isActive": isActive,
        },
      );
      return SubCategory.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<SubCategory> updateSubCategory(
    String id, {
    String? name,
    String? clinicId,
    String? categoryId,
    String? description,
    String? image,
    bool? isActive,
  }) async {
    try {
      final response = await _apiHandler.put(
        "${ApiConstants.subCategories}/$id",
        data: {
          if (name != null) "name": name,
          if (clinicId != null) "clinic": clinicId,
          if (categoryId != null) "category": categoryId,
          if (description != null) "description": description,
          if (image != null) "image": image,
          if (isActive != null) "isActive": isActive,
        },
      );
      return SubCategory.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> deleteSubCategory(String id) async {
    try {
      await _apiHandler.delete("${ApiConstants.subCategories}/$id");
    } catch (e) {
      rethrow;
    }
  }
}
