import 'dart:developer';

import '../../../../../core/Network/dio_handler.dart';
import '../../../../../core/Network/shared.dart';
import '../../../../../core/utils/config.dart';
import '../../../Branch/data/model/branches_model.dart';
import '../../../Doctor/data/model/doctor_model.dart';
import '../../../Examination Type/data/model/examination_type_model.dart';
import '../../../Patient/data/model/patients_model.dart';
import '../../../Payment Methods/data/model/payment_method_model.dart';
import 'make_appointment_repo.dart';

class MakeAppointmentRepoImpl implements MakeAppointmentRepo {
  @override
  Future<DoctorModel> getAllDoctors({
    String? branch,
    bool? isActive,
  }) async {
    final url = "${Config.baseUrl}${Config.doctors}";
    final String? token = CacheHelper.getData(key: "token");

    Map<String, dynamic> query = {
      "page": 1,
      'limit': 10,
      if (branch != null) "branch": branch,
      if (isActive != null) "isActive": isActive,
    };

    final result = await ApiService.request<DoctorModel>(
      url: url,
      method: 'GET',
      queryParameters: query,
      headers: {
        "Content-Type": "application/json",
        if (token != null) 'Cookie': 'ocurithmToken=$token',
      },
      showError: true,
      fromJson: (json) => DoctorModel.fromJson(json),
    );

    if (result != null) {
      return result;
    } else {
      throw Exception("Failed to fetch doctors");
    }
  }

  @override
  Future<BranchesModel> getAllBranches() async {
    final url = "${Config.baseUrl}${Config.branches}";
    final String? token = CacheHelper.getData(key: "token");
    log("token: $token");

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
  Future<PaymentMethodsModel> getAllPaymentMethods({int? page, String? search}) async {
    final url = "${Config.baseUrl}${Config.paymentMethods}";
    final String? token = CacheHelper.getData(key: "token");
    log("token: $token");
    Map<String, dynamic> query = {"page": page, 'limit': 10, "search": search};

    final result = await ApiService.request<PaymentMethodsModel>(
      url: url,
      method: 'GET',
      queryParameters: query,
      headers: {
        "Content-Type": "application/json",
        if (token != null) 'Cookie': 'ocurithmToken=$token',
      },
      showError: true,
      fromJson: (json) => PaymentMethodsModel.fromJson(json),
    );

    if (result != null) {
      return result;
    } else {
      throw Exception("Failed fetch PaymentMethods");
    }
  }

  @override
  Future<ExaminationTypesModel> getAllExaminationTypes({int? page, String? search}) async {
    final url = "${Config.baseUrl}${Config.examinationTypes}";
    final String? token = CacheHelper.getData(key: "token");
    log("token: $token");
    Map<String, dynamic> query = {"page": page, 'limit': 10, "search": search};

    final result = await ApiService.request<ExaminationTypesModel>(
      url: url,
      method: 'GET',
      queryParameters: query,
      headers: {
        "Content-Type": "application/json",
        if (token != null) 'Cookie': 'ocurithmToken=$token',
      },
      showError: true,
      fromJson: (json) => ExaminationTypesModel.fromJson(json),
    );

    if (result != null) {
      return result;
    } else {
      throw Exception("Failed fetch examinationTypes");
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
}
