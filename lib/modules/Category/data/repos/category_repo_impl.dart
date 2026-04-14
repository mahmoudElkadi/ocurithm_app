import '../../../../core/api/api_constants.dart';
import '../../../../core/api/api_handler.dart';
import '../models/category_model.dart';
import 'category_repo.dart';

class CategoryRepoImpl implements CategoryRepo {
  final ApiHandler _apiHandler = ApiHandler();

  @override
  Future<CategoryModel> getAllCategories({
    int? page,
    int? limit,
    String? search,
    String? pagination,
    String? clinic,
    bool? activeOnly,
  }) async {
    try {
      Map<String, dynamic> query = {
        if (page != null) "page": page,
        if (limit != null) "limit": limit,
        if (search != null && search.isNotEmpty) "search": search,
        if (pagination != null) "pagination": pagination,
        if (clinic != null && clinic.isNotEmpty) "clinic": clinic,
        if (activeOnly != null) "activeOnly": activeOnly.toString(),
      };

      final response = await _apiHandler.get<CategoryModel>(
        ApiConstants.categories,
        queryParameters: query,
        cancelKey: 'getAllCategories',
        fromJson: (json) => CategoryModel.fromJson(json),
      );

      if (response.success && response.data != null) {
        return response.data!;
      } else {
        throw Exception(response.message ?? 'Failed to fetch categories');
      }
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<Category> createCategory({
    required String name,
    required String clinic,
    String? description,
    String? image,
    bool? isActive,
  }) async {
    try {
      final response = await _apiHandler.post(
        ApiConstants.categories,
        data: {
          "name": name,
          "clinic": clinic,
          if (description != null) "description": description,
          // if (image != null) "image": image,
          if (isActive != null) "isActive": isActive,
        },
      );
      return Category.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<Category> updateCategory(
    String id, {
    String? name,
    String? clinic,
    String? description,
    String? image,
    bool? isActive,
  }) async {
    try {
      final response = await _apiHandler.put(
        "${ApiConstants.categories}/$id",
        data: {
          if (name != null) "name": name,
          if (clinic != null) "clinic": clinic,
          if (description != null) "description": description,
          if (image != null) "image": image,
          if (isActive != null) "isActive": isActive,
        },
      );
      return Category.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> deleteCategory(String id) async {
    try {
      await _apiHandler.delete("${ApiConstants.categories}/$id");
    } catch (e) {
      rethrow;
    }
  }
}
