import 'package:dio/dio.dart';
import '../../../../../core/api/api_constants.dart';
import '../../../../../core/api/api_handler.dart';
import '../../../../../core/Network/shared.dart';
import '../../../Branch/data/model/data.dart';
import '../model/save_reason_model.dart';
import 'save_reason_repo.dart';

class SaveReasonRepoImpl implements SaveReasonRepo {
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
  Future<SaveReason> createSaveReason({required SaveReason saveReason}) async {
    try {
      final result = await _apiHandler.post<SaveReason>(
        ApiConstants.saveReasons,
        data: saveReason.toJson(),
        options: _getOptions(),
        fromJson: (json) => SaveReason.fromJson(json),
      );

      if (result.success && result.data != null) {
        return result.data!;
      } else {
        throw Exception(result.message ?? "Failed to add save reason");
      }
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<SaveReasonsModel> getAllSaveReasons(
      {int? page, String? search, String? clinic}) async {
    Map<String, dynamic> query = {
      if (page != null) "page": page,
      if (page != null) 'limit': 10,
      if (page == null) 'pagination': 'false',
      if (search != null && search.isNotEmpty) "search": search,
      if (clinic != null) "clinic": clinic,
    };

    try {
      final result = await _apiHandler.get<SaveReasonsModel>(
        ApiConstants.saveReasons,
        queryParameters: query,
        options: _getOptions(),
        fromJson: (json) => SaveReasonsModel.fromJson(json),
      );

      if (result.success && result.data != null) {
        return result.data!;
      } else {
        throw Exception(result.message ?? "Failed fetch save reasons");
      }
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<SaveReason> getSaveReason({required String id}) async {
    try {
      final result = await _apiHandler.get<SaveReason>(
        "${ApiConstants.saveReasons}/$id",
        options: _getOptions(),
        fromJson: (json) => SaveReason.fromJson(json),
      );

      if (result.success && result.data != null) {
        return result.data!;
      } else {
        throw Exception(result.message ?? "Failed fetch save reason");
      }
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<SaveReason> updateSaveReason(
      {required String id, required SaveReason saveReason}) async {
    try {
      final result = await _apiHandler.put<SaveReason>(
        "${ApiConstants.saveReasons}/$id",
        data: saveReason.toJson(),
        options: _getOptions(),
        fromJson: (json) => SaveReason.fromJson(json),
      );

      if (result.success && result.data != null) {
        return result.data!;
      } else {
        throw Exception(result.message ?? "Failed to update save reason");
      }
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<DataModel> deleteSaveReason({required String id}) async {
    try {
      final result = await _apiHandler.delete<DataModel>(
        "${ApiConstants.saveReasons}/$id",
        options: _getOptions(),
        fromJson: (json) => DataModel.fromJson(json),
      );

      if (result.success && result.data != null) {
        return result.data!;
      } else {
        throw Exception(result.message ?? "Failed to delete save reason");
      }
    } catch (e) {
      rethrow;
    }
  }
}
