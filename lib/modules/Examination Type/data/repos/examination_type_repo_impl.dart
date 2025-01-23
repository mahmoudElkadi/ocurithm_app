import '../../../../../core/Network/dio_handler.dart';
import '../../../../../core/Network/shared.dart';
import '../../../../../core/utils/config.dart';
import '../../../Branch/data/model/data.dart';
import '../model/examination_type_model.dart';
import 'examination_type_repo.dart';

class ExaminationTypeRepoImpl implements ExaminationTypeRepo {
  @override
  Future<ExaminationType> createExaminationType({required ExaminationType examinationType}) async {
    final url = "${Config.baseUrl}${Config.examinationTypes}";
    final String? token = CacheHelper.getData(key: "token");

    final result = await ApiService.request<ExaminationType>(
      url: url,
      data: examinationType.toJson(),
      method: 'POST',
      headers: {
        "Content-Type": "application/json",
        if (token != null) 'Cookie': 'ocurithmToken=$token',
      },
      showError: true,
      fromJson: (json) => ExaminationType.fromJson(json),
    );

    if (result != null) {
      return result;
    } else {
      throw Exception("Failed to add ExaminationType");
    }
  }

  @override
  Future<ExaminationTypesModel> getAllExaminationTypes({int? page, String? search}) async {
    final url = "${Config.baseUrl}${Config.examinationTypes}";
    final String? token = CacheHelper.getData(key: "token");
    Map<String, dynamic> query = {"page": page, 'limit': 10, "search": search};

    final result = await ApiService.request<ExaminationTypesModel>(
      url: url,
      method: 'GET',
      queryParameters: query,
      headers: {
        "Content-Type": "application/json",
        if (token != null) 'Cookie': 'ocurithmToken=$token',
      },
      showError: true,
      fromJson: (json) => ExaminationTypesModel.fromJson(json),
    );

    if (result != null) {
      return result;
    } else {
      throw Exception("Failed fetch examinationTypes");
    }
  }

  @override
  Future<ExaminationType> getExaminationType({required String id}) async {
    final url = "${Config.baseUrl}${Config.examinationTypes}/$id";
    final String? token = CacheHelper.getData(key: "token");

    final result = await ApiService.request<ExaminationType>(
      url: url,
      method: 'GET',
      headers: {
        "Content-Type": "application/json",
        if (token != null) 'Cookie': 'ocurithmToken=$token',
      },
      showError: true,
      fromJson: (json) => ExaminationType.fromJson(json),
    );

    if (result != null) {
      return result;
    } else {
      throw Exception("Failed fetch examinationTypes");
    }
  }

  @override
  Future<ExaminationType> updateExaminationType({required String id, required ExaminationType examinationType}) async {
    final url = "${Config.baseUrl}${Config.examinationTypes}/$id";
    final String? token = CacheHelper.getData(key: "token");

    final result = await ApiService.request<ExaminationType>(
      url: url,
      method: 'PUT',
      data: examinationType.toJson(),
      headers: {
        "Content-Type": "application/json",
        if (token != null) 'Cookie': 'ocurithmToken=$token',
      },
      showError: true,
      fromJson: (json) => ExaminationType.fromJson(json),
    );

    if (result != null) {
      return result;
    } else {
      throw Exception("Failed fetch examinationTypes");
    }
  }

  @override
  Future<DataModel> deleteExaminationType({required String id}) async {
    final url = "${Config.baseUrl}${Config.examinationTypes}/$id";
    final String? token = CacheHelper.getData(key: "token");

    final result = await ApiService.request<DataModel>(
      url: url,
      method: 'DELETE',
      headers: {
        "Content-Type": "application/json",
        if (token != null) 'Cookie': 'ocurithmToken=$token',
      },
      showError: true,
      fromJson: (json) => DataModel.fromJson(json),
    );

    if (result != null) {
      return result;
    } else {
      throw Exception("Failed fetch examinationTypes");
    }
  }
}
