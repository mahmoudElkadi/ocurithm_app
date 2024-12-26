import 'dart:developer';

import 'package:dio/dio.dart';

import '../../../../../core/Network/dio_handler.dart';
import '../../../../../core/Network/shared.dart';
import '../../../../../core/utils/config.dart';
import '../../../Branch/data/model/branches_model.dart';
import '../../../Branch/data/model/data.dart';
import '../model/doctor_model.dart';
import 'doctor_repo.dart';

class DoctorRepoImpl implements DoctorRepo {
  @override
  Future<Doctor> createDoctor({required Doctor doctor}) async {
    try {
      final url = "${Config.baseUrl}${Config.doctors}";
      final String? token = CacheHelper.getData(key: "token");

      // Sanitize and validate data before sending
      Map<String, dynamic> data = {
        "name": doctor.name?.trim(),
        "phone": doctor.phone?.trim(),
        "password": doctor.password,
        "clinic": doctor.clinic?.id,
        if (doctor.birthDate != null) "birthDate": doctor.birthDate.toString(),
        if (doctor.capabilities != null && doctor.capabilities!.isNotEmpty) "capabilities": doctor.capabilities,
        if (doctor.qualifications != null && doctor.qualifications!.isNotEmpty) "qualifications": doctor.qualifications,
        if (doctor.image != null && doctor.image!.isNotEmpty) "image": doctor.image,
      };

      log("Creating doctor with data: ${data.toString()}");

      final result = await ApiService.request<Doctor>(
        url: url,
        data: data,
        method: 'POST',
        headers: {
          "Content-Type": "application/json",
          if (token != null) 'Cookie': 'ocurithmToken=$token',
        },
        showError: true,
        fromJson: (json) => Doctor.fromJson(json),
      );

      if (result != null) {
        return result;
      } else {
        throw Exception("Failed to create doctor: No response from server");
      }
    } catch (e) {
      log("Error creating doctor: $e");
      if (e is DioException) {
        switch (e.type) {
          case DioExceptionType.connectionTimeout:
          case DioExceptionType.sendTimeout:
          case DioExceptionType.receiveTimeout:
            throw Exception("Connection timeout. Please try again.");
          case DioExceptionType.badResponse:
            final responseData = e.response?.data;
            final errorMessage = responseData is Map ? responseData['error'] ?? 'Unknown error' : 'Unknown error';
            throw Exception("Server error: $errorMessage");
          case DioExceptionType.cancel:
            throw Exception("Request cancelled");
          default:
            throw Exception("Network error: ${e.message}");
        }
      }
      throw Exception("Failed to create doctor: ${e.toString()}");
    }
  }

  @override
  Future<DoctorModel> getAllDoctors({
    int? page,
    String? search,
    String? branch,
    String? clinic,
    bool? isActive,
  }) async {
    final url = "${Config.baseUrl}${Config.doctors}";
    final String? token = CacheHelper.getData(key: "token");

    Map<String, dynamic> query = {
      "page": page ?? 1,
      'limit': 10,
      if (search != null || search!.isNotEmpty) "search": search,
      if (branch != null) "branch": branch,
      if (clinic != null) "clinic": clinic,
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
  Future<Doctor> getDoctor({required String id}) async {
    final url = "${Config.baseUrl}${Config.doctors}/$id";
    final String? token = CacheHelper.getData(key: "token");

    final result = await ApiService.request<Doctor>(
      url: url,
      method: 'GET',
      headers: {
        "Content-Type": "application/json",
        if (token != null) 'Cookie': 'ocurithmToken=$token',
      },
      showError: true,
      fromJson: (json) => Doctor.fromJson(json),
    );

    if (result != null) {
      return result;
    } else {
      throw Exception("Failed to fetch doctor");
    }
  }

  @override
  Future<Doctor> updateDoctor({required String id, required Doctor doctor}) async {
    final url = "${Config.baseUrl}${Config.doctors}/$id";
    final String? token = CacheHelper.getData(key: "token");

    Map<String, dynamic> data = {
      "name": doctor.name?.trim(),
      "phone": doctor.phone?.trim(),
      "clinic": doctor.clinic?.id,
      if (doctor.birthDate != null) "birthDate": doctor.birthDate.toString(),
      if (doctor.capabilities != null && doctor.capabilities!.isNotEmpty) "capabilities": doctor.capabilities,
      if (doctor.qualifications != null && doctor.qualifications!.isNotEmpty) "qualifications": doctor.qualifications,
      if (doctor.image != null && doctor.image!.isNotEmpty) "image": doctor.image,
    };

    log("data: $data");

    final result = await ApiService.request<Doctor>(
      url: url,
      method: 'PUT',
      data: data,
      headers: {
        "Content-Type": "application/json",
        if (token != null) 'Cookie': 'ocurithmToken=$token',
      },
      showError: true,
      fromJson: (json) => Doctor.fromJson(json),
    );

    if (result != null) {
      return result;
    } else {
      throw Exception("Failed to update doctor");
    }
  }

  @override
  Future<DataModel> deleteDoctor({required String id}) async {
    final url = "${Config.baseUrl}${Config.doctors}/$id";
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
      throw Exception("Failed to delete doctor");
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
}
