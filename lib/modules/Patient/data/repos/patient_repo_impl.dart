import 'package:ocurithm/core/api/api_handler.dart';
import 'package:ocurithm/modules/Patient/data/model/one_exam.dart';
import 'package:ocurithm/modules/Patient/data/model/patient_examination.dart';

import '../../../../core/api/api_constants.dart';
import '../../../Branch/data/model/branches_model.dart';
import '../../../Branch/data/model/data.dart';
import '../model/patients_model.dart';
import 'patient_repo.dart';

class PatientRepoImpl implements PatientRepo {
  final ApiHandler _apiHandler = ApiHandler();

  @override
  Future<Patient> createPatient({required Patient patient}) async {
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
        "birthDate": patient.birthDate!.toIso8601String(),
    };

    final response = await _apiHandler.post<Patient>(
      ApiConstants.patients,
      data: data,
      fromJson: (json) => Patient.fromJson(json),
    );

    if (response.success && response.data != null) {
      return response.data!;
    } else {
      throw Exception(response.message ?? "Failed to create Patient");
    }
  }

  @override
  Future<PatientModel> getAllPatients({
    int? page,
    String? search,
    String? branch,
    bool? isActive,
  }) async {
    Map<String, dynamic> query = {
      "page": page ?? 1,
      'limit': 10,
      if (search != null && search.isNotEmpty) "search": search,
      if (branch != null) "branch": branch,
      if (isActive != null) "isActive": isActive,
    };

    final response = await _apiHandler.get<PatientModel>(
      ApiConstants.patients,
      queryParameters: query,
      fromJson: (json) => PatientModel.fromJson(json),
    );

    if (response.success && response.data != null) {
      return response.data!;
    } else {
      throw Exception(response.message ?? 'Failed to fetch patients');
    }
  }

  @override
  Future<Patient> getPatient({required String id}) async {
    final response = await _apiHandler.get<Patient>(
      "${ApiConstants.patients}/$id",
      fromJson: (json) => Patient.fromJson(json),
    );

    if (response.success && response.data != null) {
      return response.data!;
    } else {
      throw Exception(response.message ?? "Failed to fetch Patient");
    }
  }

  @override
  Future<Patient> updatePatient({
    required String id,
    required Patient patient,
  }) async {
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
      if (patient.birthDate != null)
        "birthDate": patient.birthDate!.toIso8601String(),
    };

    final response = await _apiHandler.put<Patient>(
      "${ApiConstants.patients}/$id",
      data: data,
      fromJson: (json) => Patient.fromJson(json),
    );

    if (response.success && response.data != null) {
      return response.data!;
    } else {
      throw Exception(response.message ?? "Failed to update Patient");
    }
  }

  @override
  Future<DataModel> deletePatient({required String id}) async {
    final response = await _apiHandler.delete<DataModel>(
      "${ApiConstants.patients}/$id",
      fromJson: (json) => DataModel.fromJson(json),
    );

    if (response.success && response.data != null) {
      return response.data!;
    } else {
      throw Exception(response.message ?? "Failed to delete Patient");
    }
  }

  @override
  Future<BranchesModel> getAllBranches() async {
    final response = await _apiHandler.get<BranchesModel>(
      ApiConstants.branches,
      fromJson: (json) => BranchesModel.fromJson(json),
    );

    if (response.success && response.data != null) {
      return response.data!;
    } else {
      throw Exception(response.message ?? "Failed fetch branches");
    }
  }

  @override
  Future<Examinations> getPatientExaminations({required String id}) async {
    final response = await _apiHandler.get<Examinations>(
      ApiConstants.examination,
      queryParameters: {"patient": id},
      fromJson: (json) => Examinations.fromJson(json),
    );

    if (response.success && response.data != null) {
      return response.data!;
    } else {
      throw Exception(response.message ?? "Failed fetch examinations");
    }
  }

  @override
  Future<ExaminationModel> getOneExamination({required String id}) async {
    final response = await _apiHandler.get<ExaminationModel>(
      "${ApiConstants.examination}/$id",
      fromJson: (json) => ExaminationModel.fromJson(json),
    );

    if (response.success && response.data != null) {
      return response.data!;
    } else {
      throw Exception(response.message ?? "Failed fetch examination");
    }
  }
}
