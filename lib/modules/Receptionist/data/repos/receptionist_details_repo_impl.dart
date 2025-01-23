import 'package:dio/dio.dart';

import '../../../../../../core/Network/dio_handler.dart';
import '../../../../../../core/Network/shared.dart';
import '../../../../../../core/utils/config.dart';
import '../../../Branch/data/model/branches_model.dart';
import '../../../Branch/data/model/data.dart';
import '../models/add_reception_model.dart';
import '../models/receptionists_model.dart';
import 'receptionist_details_repo.dart';

class ReceptionistRepoImpl implements ReceptionistRepo {
  @override
  Future<AddReceptionistsModel> createReceptionist({required Receptionist receptionist}) async {
    try {
      final url = "${Config.baseUrl}${Config.receptionists}";
      final String? token = CacheHelper.getData(key: "token");

      // Sanitize and validate data before sending
      Map<String, dynamic> data = {
        "name": receptionist.name?.trim(),
        "phone": receptionist.phone?.trim(),
        "password": receptionist.password,
        "branch": receptionist.branch?.id,
        "clinic": receptionist.clinic?.id,
        if (receptionist.birthDate != null) "birthDate": receptionist.birthDate.toString(),
        if (receptionist.image != null && receptionist.image!.isNotEmpty) "image": receptionist.image,
      };

      // Remove null values from the map

      final result = await ApiService.request<AddReceptionistsModel>(
        url: url,
        data: data,
        method: 'POST',
        headers: {
          "Content-Type": "application/json",
          if (token != null) 'Cookie': 'ocurithmToken=$token',
        },
        showError: true,
        fromJson: (json) => AddReceptionistsModel.fromJson(json),
      );

      if (result != null) {
        return result;
      } else {
        throw Exception("Failed to create receptionist: No response from server");
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
            final errorMessage = responseData is Map ? responseData['error'] ?? 'Unknown error' : 'Unknown error';
            throw Exception("Server error: $errorMessage");
          case DioExceptionType.cancel:
            throw Exception("Request cancelled");
          default:
            throw Exception("Network error: ${e.message}");
        }
      }
      throw Exception("Failed to create receptionist: ${e.toString()}");
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
  Future<ReceptionistsModel> getAllReceptionists({int? page, String? search}) async {
    final url = "${Config.baseUrl}${Config.receptionists}";
    final String? token = CacheHelper.getData(key: "token");
    Map<String, dynamic> query = {"page": page ?? 1, 'limit': 10, "search": search};

    final result = await ApiService.request<ReceptionistsModel>(
      url: url,
      method: 'GET',
      queryParameters: query,
      headers: {
        "Content-Type": "application/json",
        if (token != null) 'Cookie': 'ocurithmToken=$token',
      },
      showError: true,
      fromJson: (json) => ReceptionistsModel.fromJson(json),
    );

    if (result != null) {
      return result;
    } else {
      throw Exception("Failed to fetch receptionists");
    }
  }

  @override
  Future<Receptionist> getReceptionist({required String id}) async {
    final url = "${Config.baseUrl}${Config.receptionists}/$id";
    final String? token = CacheHelper.getData(key: "token");

    final result = await ApiService.request<Receptionist>(
      url: url,
      method: 'GET',
      headers: {
        "Content-Type": "application/json",
        if (token != null) 'Cookie': 'ocurithmToken=$token',
      },
      showError: true,
      fromJson: (json) => Receptionist.fromJson(json),
    );

    if (result != null) {
      return result;
    } else {
      throw Exception("Failed to fetch receptionist");
    }
  }

  @override
  Future<Receptionist> updateReceptionist({required String id, required Receptionist receptionist}) async {
    final url = "${Config.baseUrl}${Config.receptionists}/$id";
    final String? token = CacheHelper.getData(key: "token");

    Map<String, dynamic> data = {
      "name": receptionist.name?.trim(),
      "phone": receptionist.phone?.trim(),
      "branch": receptionist.branch?.id,
      "clinic": receptionist.clinic?.id,
      if (receptionist.birthDate != null) "birthDate": receptionist.birthDate.toString(),
      if (receptionist.capability != null && receptionist.capability!.isNotEmpty) "capabilities": receptionist.capability,
      if (receptionist.image != null && receptionist.image!.isNotEmpty) "image": receptionist.image,
    };

    final result = await ApiService.request<Receptionist>(
      url: url,
      method: 'PUT',
      data: data,
      headers: {
        "Content-Type": "application/json",
        if (token != null) 'Cookie': 'ocurithmToken=$token',
      },
      showError: true,
      fromJson: (json) => Receptionist.fromJson(json),
    );

    if (result != null) {
      return result;
    } else {
      throw Exception("Failed to update receptionist");
    }
  }

  @override
  Future<DataModel> deleteReceptionist({required String id}) async {
    final url = "${Config.baseUrl}${Config.receptionists}/$id";
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
      throw Exception("Failed to delete receptionist");
    }
  }
}
