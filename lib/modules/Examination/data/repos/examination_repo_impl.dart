import 'package:ocurithm/modules/Examination/data/repos/examination_repo.dart';

import '../../../../../core/Network/dio_handler.dart';
import '../../../../../core/Network/shared.dart';
import '../../../../../core/utils/config.dart';
import '../../../Branch/data/model/data.dart';
import '../../../Patient/data/model/one_exam.dart';
import '../model/saved_Exam.dart';

class ExaminationRepoImpl implements ExaminationRepo {
  @override
  Future<ExaminationModel> makeExamination({required Map<String, dynamic> data}) async {
    final url = "${Config.baseUrl}${Config.examination}";
    final String? token = CacheHelper.getData(key: "token");
    final result = await ApiService.request<ExaminationModel>(
      url: url,
      method: 'POST',
      data: data,
      headers: {
        "Content-Type": "application/json",
        if (token != null) 'Cookie': 'ocurithmToken=$token',
      },
      showError: true,
      fromJson: (json) => ExaminationModel.fromJson(json),
    );

    if (result != null) {
      return result;
    } else {
      throw Exception("Failed to make examination");
    }
  }

  @override
  Future<DataModel> makeFinalization({required String id, required Map<String, dynamic> data}) async {
    final url = "${Config.baseUrl}${Config.examination}/$id/finalization";
    final String? token = CacheHelper.getData(key: "token");
    final result = await ApiService.request<DataModel>(
      url: url,
      method: 'POST',
      data: data,
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
      throw Exception("Failed to make examination");
    }
  }

  @override
  Future<SavedExaminationModel> getOneExamination({required String appointmentId}) async {
    final url = "${Config.baseUrl}${Config.examination}";
    final String? token = CacheHelper.getData(key: "token");

    final result = await ApiService.request<SavedExaminationModel>(
      url: url,
      method: 'GET',
      queryParameters: {"appointment": appointmentId},
      headers: {
        "Content-Type": "application/json",
        if (token != null) 'Cookie': 'ocurithmToken=$token',
      },
      showError: true,
      fromJson: (json) => SavedExaminationModel.fromJson(json),
    );

    if (result != null) {
      return result;
    } else {
      throw Exception("Failed fetch branches");
    }
  }
}
