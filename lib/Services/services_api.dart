import 'dart:developer';

import '../core/Network/dio_handler.dart';
import '../core/Network/shared.dart';
import '../core/utils/config.dart';
import '../modules/Clinics/data/model/clinics_model.dart';

class ServicesApi {
  Future<ClinicsModel> getAllClinics({int? page, String? search}) async {
    final url = "${Config.baseUrl}${Config.clinics}";
    final String? token = CacheHelper.getData(key: "token");
    log("token: $token");
    Map<String, dynamic> query = {"page": page, 'limit': 10, "search": search};

    final result = await ApiService.request<ClinicsModel>(
      url: url,
      method: 'GET',
      queryParameters: query,
      headers: {
        "Content-Type": "application/json",
        if (token != null) 'Cookie': 'ocurithmToken=$token',
      },
      showError: true,
      fromJson: (json) => ClinicsModel.fromJson(json),
    );

    if (result != null) {
      return result;
    } else {
      throw Exception("Failed fetch clinics");
    }
  }
}
