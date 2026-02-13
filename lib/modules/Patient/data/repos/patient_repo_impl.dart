import 'package:ocurithm/core/api/api_handler.dart';
import 'package:ocurithm/modules/Patient/data/model/one_exam.dart';
import 'package:ocurithm/modules/Patient/data/model/patient_examination.dart';
import 'package:ocurithm/modules/Patient/data/model/scan_records_model.dart';

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
    if(patient.email !=null&& patient.email!.isNotEmpty) "email": patient.email?.trim(),
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
    String? clinic,
    bool? isActive,
  }) async {
    Map<String, dynamic> query = {
      if (page != null) "page": page,
      if (page != null) 'limit': 10,
      if (search != null && search.isNotEmpty) "search": search,
      if (branch != null) "branch": branch,
      if (clinic != null) "clinic": clinic,
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
      if(patient.email !=null&& patient.email!.isNotEmpty) "email": patient.email?.trim(),
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

  @override
  Future<void> createScanRecord({
    required String patientId,
    required String doctorId,
    required String comment,
    required String scanDate,
    required List<String> files,
  }) async {
    Map<String, dynamic> data = {
      "doctor": doctorId,
      "comment": comment,
      "scanDate": scanDate,
      "files": files,
    };

    final response = await _apiHandler.post(
      "${ApiConstants.patients}/$patientId/scans",
      data: data,
    );

    if (!response.success) {
      throw Exception(response.message ?? "Failed to create scan record");
    }
  }

  @override
  Future<ScanRecordsModel> getPatientScans({
    required String patientId,
    int? page,
    int? limit,
    String? doctorId,
    String? fromDate,
    String? toDate,
  }) async {
    Map<String, dynamic> query = {
      "page": page ?? 1,
      "limit": limit ?? 10,
      if (doctorId != null && doctorId.isNotEmpty) "doctorId": doctorId,
      if (fromDate != null && fromDate.isNotEmpty) "fromDate": fromDate,
      if (toDate != null && toDate.isNotEmpty) "toDate": toDate,
    };

    final response = await _apiHandler.get<ScanRecordsModel>(
      "${ApiConstants.patients}/$patientId/scans",
      queryParameters: query,
      fromJson: (json) => ScanRecordsModel.fromJson(json),
    );

    if (response.success && response.data != null) {
      return response.data!;
    } else {
      throw Exception(response.message ?? "Failed to fetch scan records");
    }
  }

  @override
  Future<ScanRecord> getScanDetails({
    required String patientId,
    required String scanId,
  }) async {
    final response = await _apiHandler.get<ScanRecord>(
      "${ApiConstants.patients}/$patientId/scans/$scanId",
      fromJson: (json) => ScanRecord.fromJson(json),
    );

    if (response.success && response.data != null) {
      return response.data!;
    } else {
      throw Exception(response.message ?? "Failed to fetch scan details");
    }
  }

  @override
  Future<void> deleteScan({
    required String patientId,
    required String scanId,
  }) async {
    final response = await _apiHandler.delete(
      "${ApiConstants.patients}/$patientId/scans/$scanId",
    );

    if (!response.success) {
      throw Exception(response.message ?? "Failed to delete scan");
    }
  }

  @override
  Future<bool> checkDuplicateName({required String name}) async {
    final response = await _apiHandler.get<Map<String, dynamic>>(
      ApiConstants.checkDuplicatePatientName,
      queryParameters: {"name": name},
    );

    if (response.success && response.data != null) {
      return response.data!['exists'] ?? false;
    } else {
      throw Exception(response.message ?? "Failed to check duplicate name");
    }
  }
}
