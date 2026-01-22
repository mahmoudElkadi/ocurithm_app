import 'package:dio/dio.dart';
import '../../../../../core/api/api_constants.dart';
import '../../../../../core/api/api_handler.dart';
import '../../../../../core/Network/shared.dart';
import '../../../Branch/data/model/data.dart';
import '../model/active_ingredient_model.dart';
import '../model/medicine_model.dart';
import 'medicine_repo.dart';

class MedicineRepoImpl implements MedicineRepo {
  final ApiHandler _apiHandler = ApiHandler();

  Options _getOptions() {
    final String? token = CacheHelper.getData(key: "token");
    return Options(
      headers: {
        "Content-Type": "application/json",
        if (token != null) 'Cookie': 'ocurithmToken=$token',
      },
    );
  }

  @override
  Future<CommercialName> createMedicine(
      {required CommercialName commercialName}) async {
    String path = ApiConstants.medicines;
    if (commercialName.parentId?.id != null) {
      path =
          "${ApiConstants.activeIngredients}/${commercialName.parentId!.id}/commercial-names";
    }

    final result = await _apiHandler.post<CommercialName>(
      path,
      data: commercialName.toJson(),
      options: _getOptions(),
      fromJson: (json) => CommercialName.fromJson(json),
    );

    if (result.success && result.data != null) {
      return result.data!;
    } else {
      throw Exception(result.message ?? "Failed to add Medicine");
    }
  }

  @override
  Future<MedicinesModel> getAllMedicines({int? page, String? search}) async {
    Map<String, dynamic> query = {"page": page, 'limit': 10, "search": search};

    final result = await _apiHandler.get<MedicinesModel>(
      ApiConstants.medicines,
      queryParameters: query,
      options: _getOptions(),
      fromJson: (json) => MedicinesModel.fromJson(json),
    );

    if (result.success && result.data != null) {
      return result.data!;
    } else {
      throw Exception(result.message ?? "Failed fetch medicines");
    }
  }

  @override
  Future<CommercialName> getMedicine({required String id}) async {
    final result = await _apiHandler.get<CommercialName>(
      "${ApiConstants.medicines}/$id",
      options: _getOptions(),
      fromJson: (json) => CommercialName.fromJson(json),
    );

    if (result.success && result.data != null) {
      return result.data!;
    } else {
      throw Exception(result.message ?? "Failed fetch medicine");
    }
  }

  @override
  Future<CommercialName> updateMedicine(
      {required String id, required CommercialName commercialName}) async {
    final result = await _apiHandler.put<CommercialName>(
      "${ApiConstants.medicines}/$id",
      data: commercialName.toJson(),
      options: _getOptions(),
      fromJson: (json) => CommercialName.fromJson(json),
    );

    if (result.success && result.data != null) {
      return result.data!;
    } else {
      throw Exception(result.message ?? "Failed update medicine");
    }
  }

  @override
  Future<DataModel> deleteMedicine({required String id}) async {
    final result = await _apiHandler.delete<DataModel>(
      "${ApiConstants.medicines}/$id",
      options: _getOptions(),
      fromJson: (json) => DataModel.fromJson(json),
    );

    if (result.success && result.data != null) {
      return result.data!;
    } else {
      throw Exception(result.message ?? "Failed delete medicine");
    }
  }

  // Active Ingredient Implementation

  @override
  Future<ActiveIngredientModel> getAllActiveIngredients(
      {int? page, String? search, bool? pagination, String? clinic}) async {
    Map<String, dynamic> query = {
      "page": page,
      'limit': 10,
      "search": search,
      if (pagination != null) "pagination": pagination,
      if (clinic != null) "clinic": clinic
    };

    final result = await _apiHandler.get<ActiveIngredientModel>(
      ApiConstants.activeIngredients,
      queryParameters: query,
      options: _getOptions(),
      fromJson: (json) => ActiveIngredientModel.fromJson(json),
    );

    if (result.success && result.data != null) {
      return result.data!;
    } else {
      throw Exception(result.message ?? "Failed fetch active ingredients");
    }
  }

  @override
  Future<ActiveIngredient> createActiveIngredient(
      {required ActiveIngredient activeIngredient}) async {
    final result = await _apiHandler.post<ActiveIngredient>(
      ApiConstants.activeIngredients,
      data: activeIngredient.toJson(),
      options: _getOptions(),
      fromJson: (json) => ActiveIngredient.fromJson(json),
    );

    if (result.success && result.data != null) {
      return result.data!;
    } else {
      throw Exception(result.message ?? "Failed create active ingredient");
    }
  }

  @override
  Future<ActiveIngredient> updateActiveIngredient(
      {required String id, required ActiveIngredient activeIngredient}) async {
    final result = await _apiHandler.put<ActiveIngredient>(
      "${ApiConstants.activeIngredients}/$id",
      data: activeIngredient.toJson(),
      options: _getOptions(),
      fromJson: (json) => ActiveIngredient.fromJson(json),
    );

    if (result.success && result.data != null) {
      return result.data!;
    } else {
      throw Exception(result.message ?? "Failed update active ingredient");
    }
  }

  @override
  Future<DataModel> deleteActiveIngredient({required String id}) async {
    final result = await _apiHandler.delete<DataModel>(
      "${ApiConstants.activeIngredients}/$id",
      options: _getOptions(),
      fromJson: (json) => DataModel.fromJson(json),
    );

    if (result.success && result.data != null) {
      return result.data!;
    } else {
      throw Exception(result.message ?? "Failed delete active ingredient");
    }
  }
}
