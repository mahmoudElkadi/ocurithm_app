import 'dart:developer';

import '../../../../../core/Network/dio_handler.dart';
import '../../../../../core/Network/shared.dart';
import '../../../../../core/utils/config.dart';
import '../../../Branch/data/model/branches_model.dart';
import '../../../Doctor/data/model/doctor_model.dart';
import '../models/appointment_model.dart';
import 'appointment_repo.dart';

class AppointmentRepoImpl implements AppointmentRepo {
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
  Future<AppointmentModel> getAllAppointment() async {
    final url = "${Config.baseUrl}${Config.appointments}";
    final String? token = CacheHelper.getData(key: "token");
    log("token: $token");

    final result = await ApiService.request<AppointmentModel>(
      url: url,
      method: 'GET',
      headers: {
        "Content-Type": "application/json",
        if (token != null) 'Cookie': 'ocurithmToken=$token',
      },
      showError: true,
      fromJson: (json) => AppointmentModel.fromJson(json),
    );

    if (result != null) {
      return result;
    } else {
      throw Exception("Failed fetch branches");
    }
  }
}
