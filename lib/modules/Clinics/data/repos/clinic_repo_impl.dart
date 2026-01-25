import 'dart:developer';

import '../../../../core/api/api_handler.dart';
import '../../../../core/api/api_constants.dart';
import '../../../Branch/data/model/data.dart';
import '../model/clinics_model.dart';
import 'clinic_repo.dart';

class ClinicRepoImpl implements ClinicRepo {
  final ApiHandler _apiHandler = ApiHandler();

  @override
  Future<Clinic> createClinic({required Clinic clinic}) async {
    final response = await _apiHandler.post<Clinic>(
      ApiConstants.clinics,
      data: clinic.toJson(),
      fromJson: (json) => Clinic.fromJson(json),
    );

    if (response.success && response.data != null) {
      return response.data!;
    } else {
      throw Exception(response.message ?? "Failed to add Clinic");
    }
  }

  @override
  Future<ClinicsModel> getAllClinics({int? page, String? search}) async {
    Map<String, dynamic> query = {"page": page, 'limit': 10, "search": search};

    log(ApiConstants.clinics);

    final response = await _apiHandler.get<ClinicsModel>(
      ApiConstants.clinics,
      queryParameters: query,
      fromJson: (json) => ClinicsModel.fromJson(json),
    );

    if (response.success && response.data != null) {
      return response.data!;
    } else {
      throw Exception(response.message ?? "Failed fetch clinics");
    }
  }

  @override
  Future<Clinic> getClinic({required String id}) async {
    final response = await _apiHandler.get<Clinic>(
      "${ApiConstants.clinics}/$id",
      fromJson: (json) => Clinic.fromJson(json),
    );

    if (response.success && response.data != null) {
      return response.data!;
    } else {
      throw Exception(response.message ?? "Failed fetch clinics");
    }
  }

  @override
  Future<Clinic> updateClinic(
      {required String id, required Clinic clinic}) async {
    final response = await _apiHandler.put<Clinic>(
      "${ApiConstants.clinics}/$id",
      data: clinic.toJson(),
      fromJson: (json) => Clinic.fromJson(json),
    );

    if (response.success && response.data != null) {
      return response.data!;
    } else {
      throw Exception(response.message ?? "Failed fetch clinics");
    }
  }

  @override
  Future<DataModel> deleteClinic({required String id}) async {
    final response = await _apiHandler.delete<DataModel>(
      "${ApiConstants.clinics}/$id",
      fromJson: (json) => DataModel.fromJson(json),
    );

    if (response.success && response.data != null) {
      return response.data!;
    } else {
      throw Exception(response.message ?? "Failed fetch clinics");
    }
  }
}
