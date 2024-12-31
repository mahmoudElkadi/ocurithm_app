import 'dart:developer';

import 'package:ocurithm/modules/Examination/data/repos/examination_repo.dart';

import '../../../../../core/Network/dio_handler.dart';
import '../../../../../core/Network/shared.dart';
import '../../../../../core/utils/config.dart';

class ExaminationRepoImpl implements ExaminationRepo {
  @override
  Future makeExamination({required Map<String, dynamic> data}) async {
    final url = "${Config.baseUrl}${Config.examination}";
    final String? token = CacheHelper.getData(key: "token");
    log(data.toString());
    final result = await ApiService.request(
      url: url,
      method: 'POST',
      data: data,
      headers: {
        "Content-Type": "application/json",
        if (token != null) 'Cookie': 'ocurithmToken=$token',
      },
      showError: true,
    );

    if (result != null) {
      return result;
    } else {
      throw Exception("Failed to make examination");
    }
  }
}
