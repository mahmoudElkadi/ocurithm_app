import 'package:dio/dio.dart';
import 'package:ocurithm/modules/Patient/data/model/one_exam.dart';
import 'package:ocurithm/modules/Patient/data/model/patient_examination.dart';

import '../../../../../core/Network/dio_handler.dart';
import '../../../../../core/Network/shared.dart';
import '../../../../../core/utils/config.dart';
import '../../../Branch/data/model/branches_model.dart';
import '../../../Branch/data/model/data.dart';
import '../model/patients_model.dart';
import 'patient_repo.dart';

class PatientRepoImpl implements PatientRepo {
  @override
  Future<Patient> createPatient({required Patient patient}) async {
    try {
      final url = "${Config.baseUrl}${Config.patients}";
      final String? token = CacheHelper.getData(key: "token");

      // Sanitize and validate data before sending
      Map<String, dynamic> data = {
        "name": patient.name?.trim(),
        "clinic": patient.clinic?.id,
        "phone": patient.phone?.trim(),
        "password": patient.password,
        "branch": patient.branch?.id,
        "email": patient.email?.trim(),
        "address": patient.address?.trim(),
        "username": patient.username?.trim(),
        "gender": patient.gender,
        "nationality": patient.nationality?.trim(),
        "nationalID": patient.nationalId?.trim().toString(),
        "serialNumber": patient.nationalId?.trim().toString(),
        if (patient.birthDate != null)
          "birthDate": patient.birthDate.toString(),
      };

      final result = await ApiService.request<Patient>(
        url: url,
        data: data,
        method: 'POST',
        headers: {
          "Content-Type": "application/json",
          if (token != null) 'Cookie': 'ocurithmToken=$token',
        },
        showError: true,
        fromJson: (json) => Patient.fromJson(json),
      );

      if (result != null) {
        return result;
      } else {
        throw Exception("Failed to create Patient: No response from server");
      }
    } catch (e) {
      if (e is DioException) {
        switch (e.type) {
          case DioExceptionType.connectionTimeout:
          case DioExceptionType.sendTimeout:
          case DioExceptionType.receiveTimeout:
            throw Exception("Connection timeout. Please try again.");
          case DioExceptionType.badResponse:
            final responseData = e.response?.data;
            final errorMessage = responseData is Map
                ? responseData['error'] ?? 'Unknown error'
                : 'Unknown error';
            throw Exception("Server error: $errorMessage");
          case DioExceptionType.cancel:
            throw Exception("Request cancelled");
          default:
            throw Exception("Network error: ${e.message}");
        }
      }
      throw Exception("Failed to create Patient: ${e.toString()}");
    }
  }

  @override
  Future<PatientModel> getAllPatients({
    int? page,
    String? search,
    String? branch,
    bool? isActive,
  }) async {
    final url = "${Config.baseUrl}${Config.patients}";
    final String? token = CacheHelper.getData(key: "token");

    Map<String, dynamic> query = {
      "page": page ?? 1,
      'limit': 10,
      if (search != null) "search": search,
      if (branch != null) "branch": branch,
      if (isActive != null) "isActive": isActive,
    };

    final result = await ApiService.request<PatientModel>(
      url: url,
      method: 'GET',
      queryParameters: query,
      headers: {
        "Content-Type": "application/json",
        if (token != null) 'Cookie': 'ocurithmToken=$token',
      },
      showError: true,
      fromJson: (json) => PatientModel.fromJson(json),
    );

    if (result != null) {
      return result;
    } else {
      throw Exception("Failed to fetch Patients");
    }
  }

  @override
  Future<Patient> getPatient({required String id}) async {
    final url = "${Config.baseUrl}${Config.patients}/$id";
    final String? token = CacheHelper.getData(key: "token");

    final result = await ApiService.request<Patient>(
      url: url,
      method: 'GET',
      headers: {
        "Content-Type": "application/json",
        if (token != null) 'Cookie': 'ocurithmToken=$token',
      },
      showError: true,
      fromJson: (json) => Patient.fromJson(json),
    );

    if (result != null) {
      return result;
    } else {
      throw Exception("Failed to fetch Patient");
    }
  }

  @override
  Future<Patient> updatePatient(
      {required String id, required Patient patient}) async {
    final url = "${Config.baseUrl}${Config.patients}/$id";
    final String? token = CacheHelper.getData(key: "token");

    Map<String, dynamic> data = {
      "name": patient.name?.trim(),
      "phone": patient.phone?.trim(),
      "branch": patient.branch?.id,
      "email": patient.email?.trim(),
      "clinic": patient.clinic?.id,
      "address": patient.address?.trim(),
      "username": patient.username?.trim(),
      "gender": patient.gender,
      "nationality": patient.nationality?.trim(),
      "nationalID": patient.nationalId?.trim().toString(),
      "serialNumber": patient.nationalId?.trim().toString(),
      if (patient.birthDate != null) "birthDate": patient.birthDate.toString(),
    };

    final result = await ApiService.request<Patient>(
      url: url,
      method: 'PUT',
      data: data,
      headers: {
        "Content-Type": "application/json",
        if (token != null) 'Cookie': 'ocurithmToken=$token',
      },
      showError: true,
      fromJson: (json) => Patient.fromJson(json),
    );

    if (result != null) {
      return result;
    } else {
      throw Exception("Failed to update Patient");
    }
  }

  @override
  Future<DataModel> deletePatient({required String id}) async {
    final url = "${Config.baseUrl}${Config.patients}/$id";
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
      throw Exception("Failed to delete Patient");
    }
  }

  @override
  Future<BranchesModel> getAllBranches() async {
    final url = "${Config.baseUrl}${Config.branches}";
    final String? token = CacheHelper.getData(key: "token");

    final result = await ApiService.request<BranchesModel>(
      url: url,
      method: 'GET',
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

  @override
  Future<PatientExaminationModel> getPatientExaminations(
      {required String id}) async {
    final url = "${Config.baseUrl}${Config.examination}";
    final String? token = CacheHelper.getData(key: "token");

    final result = await ApiService.request<PatientExaminationModel>(
      url: url,
      method: 'GET',
      queryParameters: {"patient": id},
      headers: {
        "Content-Type": "application/json",
        if (token != null) 'Cookie': 'ocurithmToken=$token',
      },
      showError: true,
      fromJson: (json) => PatientExaminationModel.fromJson(json),
    );

    if (result != null) {
      return result;
    } else {
      throw Exception("Failed fetch branches");
    }
  }

  @override
  Future<ExaminationModel> getOneExamination({required String id}) async {
    final url = "${Config.baseUrl}${Config.examination}/$id";
    final String? token = CacheHelper.getData(key: "token");

    final result = await ApiService.request<ExaminationModel>(
      url: url,
      method: 'GET',
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
      throw Exception("Failed fetch branches");
    }
  }
}
