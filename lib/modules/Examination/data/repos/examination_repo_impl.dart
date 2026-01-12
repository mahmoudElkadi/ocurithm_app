import 'package:dio/dio.dart';
import 'package:ocurithm/modules/Examination/data/repos/examination_repo.dart';

import '../../../../../core/api/api_handler.dart';
import '../../../../../core/Network/shared.dart';
import '../../../../../core/utils/config.dart';
import '../../../Branch/data/model/data.dart';
import '../../../Patient/data/model/one_exam.dart';
import '../model/saved_Exam.dart';

class ExaminationRepoImpl implements ExaminationRepo {
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
  Future<ExaminationModel> makeExamination(
      {required Map<String, dynamic> data}) async {
    final result = await _apiHandler.post<ExaminationModel>(
      Config.examination,
      data: data,
      options: _getOptions(),
      fromJson: (json) => ExaminationModel.fromJson(json),
    );

    if (result.success && result.data != null) {
      return result.data!;
    } else {
      throw Exception(result.message ?? "Failed to make examination");
    }
  }

  @override
  Future<DataModel> makeFinalization(
      {required String id, required Map<String, dynamic> data}) async {
    final result = await _apiHandler.post<DataModel>(
      "${Config.examination}/$id/finalization",
      data: data,
      options: _getOptions(),
      fromJson: (json) => DataModel.fromJson(json),
    );

    if (result.success && result.data != null) {
      return result.data!;
    } else {
      throw Exception(result.message ?? "Failed to finalize examination");
    }
  }

  @override
  Future<SavedExaminationModel> getOneExamination(
      {required String appointmentId}) async {
    final result = await _apiHandler.get<SavedExaminationModel>(
      Config.examination,
      queryParameters: {"appointment": appointmentId},
      options: _getOptions(),
      fromJson: (json) => SavedExaminationModel.fromJson(json),
    );

    if (result.success && result.data != null) {
      return result.data!;
    } else {
      throw Exception(result.message ?? "Failed fetch examination");
    }
  }
}
