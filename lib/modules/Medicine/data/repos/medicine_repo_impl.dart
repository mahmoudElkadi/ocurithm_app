import 'dart:developer';

import 'package:dio/dio.dart';

import '../../../../../core/api/api_handler.dart';
import '../../../../../core/Network/shared.dart';
import '../../../../../core/utils/config.dart';
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
  Future<Medicine> createMedicine({required Medicine medicine}) async {
    final result = await _apiHandler.post<Medicine>(
      Config.medicines,
      data: medicine.toJson(),
      options: _getOptions(),
      fromJson: (json) => Medicine.fromJson(json),
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
      Config.medicines,
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
  Future<Medicine> getMedicine({required String id}) async {
    final result = await _apiHandler.get<Medicine>(
      "${Config.medicines}/$id",
      options: _getOptions(),
      fromJson: (json) => Medicine.fromJson(json),
    );

    if (result.success && result.data != null) {
      return result.data!;
    } else {
      throw Exception(result.message ?? "Failed fetch medicine");
    }
  }

  @override
  Future<Medicine> updateMedicine(
      {required String id, required Medicine medicine}) async {
    final result = await _apiHandler.put<Medicine>(
      "${Config.medicines}/$id",
      data: medicine.toJson(),
      options: _getOptions(),
      fromJson: (json) => Medicine.fromJson(json),
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
      "${Config.medicines}/$id",
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
  Future<ActiveIngredientsModel> getAllActiveIngredients(
      {int? page, String? search}) async {
    Map<String, dynamic> query = {"page": page, 'limit': 10, "search": search};

    final result = await _apiHandler.get<ActiveIngredientsModel>(
      Config.activeIngredients,
      queryParameters: query,
      options: _getOptions(),
      fromJson: (json) => ActiveIngredientsModel.fromJson(json),
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
      Config.activeIngredients,
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
      "${Config.activeIngredients}/$id",
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
      "${Config.activeIngredients}/$id",
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
