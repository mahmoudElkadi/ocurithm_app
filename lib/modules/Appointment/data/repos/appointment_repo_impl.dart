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
  Future<AppointmentModel> getAllAppointment({DateTime? date, String? branch, String? doctor}) async {
    final url = "${Config.baseUrl}${Config.appointments}";
    final String? token = CacheHelper.getData(key: "token");
    log("token: $token");

    Map<String, dynamic> quary = {
      if (date != null) "startDate": DateTime(date.year, date.month, date.day, 0, 0, 0).toString(),
      if (date != null) "endDate": DateTime(date.year, date.month, date.day, 23, 59, 59).toString(),
      if (doctor != null) "doctor": doctor,
      if (branch != null) "branch": branch
    };
    log(quary.toString());

    final result = await ApiService.request<AppointmentModel>(
      url: url,
      method: 'GET',
      queryParameters: quary,
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

  @override
  Future<Appointment> editAppointment({required String id, required String action, DateTime? date, String? doctor}) async {
    final url = "${Config.baseUrl}${Config.appointments}/$id";
    final String? token = CacheHelper.getData(key: "token");
    Map<String, dynamic> data = {"action": action, if (doctor != null) "doctor": doctor, if (date != null) "datetime": date.toString()};
    log(data.toString());
    final result = await ApiService.request<Appointment>(
      url: url,
      method: 'PUT',
      data: data,
      headers: {
        "Content-Type": "application/json",
        if (token != null) 'Cookie': 'ocurithmToken=$token',
      },
      showError: true,
      fromJson: (json) => Appointment.fromJson(json),
    );

    if (result != null) {
      return result;
    } else {
      throw Exception("Failed to edit appointment");
    }
  }
}
