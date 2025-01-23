import '../../../../../core/Network/dio_handler.dart';
import '../../../../../core/Network/shared.dart';
import '../../../../../core/utils/config.dart';
import '../../../Branch/data/model/data.dart';
import '../model/clinics_model.dart';
import 'clinic_repo.dart';

class ClinicRepoImpl implements ClinicRepo {
  @override
  Future<Clinic> createClinic({required Clinic clinic}) async {
    final url = "${Config.baseUrl}${Config.clinics}";
    final String? token = CacheHelper.getData(key: "token");

    final result = await ApiService.request<Clinic>(
      url: url,
      data: clinic.toJson(),
      method: 'POST',
      headers: {
        "Content-Type": "application/json",
        if (token != null) 'Cookie': 'ocurithmToken=$token',
      },
      showError: true,
      fromJson: (json) => Clinic.fromJson(json),
    );

    if (result != null) {
      return result;
    } else {
      throw Exception("Failed to add Clinic");
    }
  }

  @override
  Future<ClinicsModel> getAllClinics({int? page, String? search}) async {
    final url = "${Config.baseUrl}${Config.clinics}";
    final String? token = CacheHelper.getData(key: "token");
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

  @override
  Future<Clinic> getClinic({required String id}) async {
    final url = "${Config.baseUrl}${Config.clinics}/$id";
    final String? token = CacheHelper.getData(key: "token");

    final result = await ApiService.request<Clinic>(
      url: url,
      method: 'GET',
      headers: {
        "Content-Type": "application/json",
        if (token != null) 'Cookie': 'ocurithmToken=$token',
      },
      showError: true,
      fromJson: (json) => Clinic.fromJson(json),
    );

    if (result != null) {
      return result;
    } else {
      throw Exception("Failed fetch clinics");
    }
  }

  @override
  Future<Clinic> updateClinic({required String id, required Clinic clinic}) async {
    final url = "${Config.baseUrl}${Config.clinics}/$id";
    final String? token = CacheHelper.getData(key: "token");

    final result = await ApiService.request<Clinic>(
      url: url,
      method: 'PUT',
      data: clinic.toJson(),
      headers: {
        "Content-Type": "application/json",
        if (token != null) 'Cookie': 'ocurithmToken=$token',
      },
      showError: true,
      fromJson: (json) => Clinic.fromJson(json),
    );

    if (result != null) {
      return result;
    } else {
      throw Exception("Failed fetch clinics");
    }
  }

  @override
  Future<DataModel> deleteClinic({required String id}) async {
    final url = "${Config.baseUrl}${Config.clinics}/$id";
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
      throw Exception("Failed fetch clinics");
    }
  }
}
