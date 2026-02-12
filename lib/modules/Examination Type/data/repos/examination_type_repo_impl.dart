import 'package:dio/dio.dart';
import '../../../../../core/api/api_handler.dart';
import '../../../../../core/Network/shared.dart';
import '../../../../core/api/api_constants.dart';
import '../../../Branch/data/model/data.dart';
import '../model/examination_type_model.dart';
import 'examination_type_repo.dart';

class ExaminationTypeRepoImpl implements ExaminationTypeRepo {
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
  Future<ExaminationType> createExaminationType(
      {required ExaminationType examinationType}) async {
    try {
      final result = await _apiHandler.post<ExaminationType>(
        ApiConstants.examinationTypes,
        data: examinationType.toJson(),
        options: _getOptions(),
        fromJson: (json) => ExaminationType.fromJson(json),
      );

      if (result.success && result.data != null) {
        return result.data!;
      } else {
        throw Exception(result.message ?? "Failed to add ExaminationType");
      }
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<ExaminationTypesModel> getAllExaminationTypes(
      {int? page, String? search, String? clinic}) async {
    Map<String, dynamic> query = {
      if (page != null) "page": page,
      if (page != null) 'limit': 25,
      if (search != null && search.isNotEmpty) "search": search,
      if (clinic != null) "clinic": clinic,
    };

    try {
      final result = await _apiHandler.get<ExaminationTypesModel>(
        ApiConstants.examinationTypes,
        queryParameters: query,
        options: _getOptions(),
        fromJson: (json) => ExaminationTypesModel.fromJson(json),
      );

      if (result.success && result.data != null) {
        return result.data!;
      } else {
        throw Exception(result.message ?? "Failed fetch examinationTypes");
      }
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<ExaminationType> getExaminationType({required String id}) async {
    try {
      final result = await _apiHandler.get<ExaminationType>(
        "${ApiConstants.examinationTypes}/$id",
        options: _getOptions(),
        fromJson: (json) => ExaminationType.fromJson(json),
      );

      if (result.success && result.data != null) {
        return result.data!;
      } else {
        throw Exception(result.message ?? "Failed fetch examinationTypes");
      }
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<ExaminationType> updateExaminationType(
      {required String id, required ExaminationType examinationType}) async {
    try {
      final result = await _apiHandler.put<ExaminationType>(
        "${ApiConstants.examinationTypes}/$id",
        data: examinationType.toJson(),
        options: _getOptions(),
        fromJson: (json) => ExaminationType.fromJson(json),
      );

      if (result.success && result.data != null) {
        return result.data!;
      } else {
        throw Exception(result.message ?? "Failed update examinationType");
      }
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<DataModel> deleteExaminationType({required String id}) async {
    try {
      final result = await _apiHandler.delete<DataModel>(
        "${ApiConstants.examinationTypes}/$id",
        options: _getOptions(),
        fromJson: (json) => DataModel.fromJson(json),
      );

      if (result.success && result.data != null) {
        return result.data!;
      } else {
        throw Exception(result.message ?? "Failed delete examinationType");
      }
    } catch (e) {
      rethrow;
    }
  }
}
