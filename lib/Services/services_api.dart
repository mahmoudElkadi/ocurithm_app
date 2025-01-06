import '../core/Network/dio_handler.dart';
import '../core/Network/shared.dart';
import '../core/utils/config.dart';
import '../modules/Branch/data/model/branches_model.dart';
import '../modules/Clinics/data/model/clinics_model.dart';
import '../modules/Doctor/data/model/capability_model.dart';

class ServicesApi {
  Future<ClinicsModel> getAllClinics({int? page, String? search}) async {
    final url = "${Config.baseUrl}${Config.clinics}";
    final String? token = CacheHelper.getData(key: "token");

    final result = await ApiService.request<ClinicsModel>(
      url: url,
      method: 'GET',
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

  Future<BranchesModel> getAllBranches({String? clinic, bool? haveDoctors}) async {
    final url = "${Config.baseUrl}${Config.branches}";
    final String? token = CacheHelper.getData(key: "token");

    final result = await ApiService.request<BranchesModel>(
      url: url,
      method: 'GET',
      queryParameters: {if (clinic != null) "clinic": clinic, if (haveDoctors != null) "haveDoctors": true},
      headers: {
        "Content-Type": "application/json",
        if (token != null) 'Cookie': 'ocurithmToken=$token',
      },
      showError: true,
      fromJson: (json) => BranchesModel.fromJson(json),
    );

    if (result != null) {
      return result;
    } else {
      throw Exception("Failed fetch branches");
    }
  }

  Future<CapabilityModel> getAllCapability() async {
    final url = "${Config.baseUrl}${Config.capabilities}";
    final String? token = CacheHelper.getData(key: "token");

    final result = await ApiService.request<CapabilityModel>(
      url: url,
      method: 'GET',
      headers: {
        "Content-Type": "application/json",
        if (token != null) 'Cookie': 'ocurithmToken=$token',
      },
      showError: true,
      fromJson: (json) => CapabilityModel.fromJson(json),
    );

    if (result != null) {
      return result;
    } else {
      throw Exception("Failed fetch Capability");
    }
  }
}
