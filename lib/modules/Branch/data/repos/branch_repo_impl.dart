import 'dart:developer';

import '../../../../../core/Network/dio_handler.dart';
import '../../../../../core/Network/shared.dart';
import '../../../../../core/utils/config.dart';
import '../model/add_branch_model.dart';
import '../model/branches_model.dart';
import '../model/data.dart';
import 'branch_repo.dart';

class BranchRepoImpl implements BranchRepo {
  @override
  Future<AddBranchModel> createBranch({required AddBranchModel addBranchModel}) async {
    final url = "${Config.baseUrl}${Config.branches}";
    final String? token = CacheHelper.getData(key: "token");

    final result = await ApiService.request<AddBranchModel>(
      url: url,
      data: addBranchModel.toJson(),
      method: 'POST',
      headers: {
        "Content-Type": "application/json",
        if (token != null) 'Cookie': 'ocurithmToken=$token',
      },
      showError: true,
      fromJson: (json) => AddBranchModel.fromJson(json),
    );

    if (result != null) {
      return result;
    } else {
      throw Exception("Failed to add branch");
    }
  }

  @override
  Future<BranchesModel> getAllBranches({int? page, String? search, String? clinic}) async {
    final url = "${Config.baseUrl}${Config.branches}";
    final String? token = CacheHelper.getData(key: "token");
    log("token: $token");
    Map<String, dynamic> query = {
      if (page != null) "page": page,
      if (page != null) 'limit': 10,
      if (search != null) "search": search,
      if (clinic != null) "clinic": clinic
    };

    final result = await ApiService.request<BranchesModel>(
      url: url,
      method: 'GET',
      queryParameters: query,
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
  Future<AddBranchModel> getBranch({required String id}) async {
    final url = "${Config.baseUrl}${Config.branches}/$id";
    final String? token = CacheHelper.getData(key: "token");

    final result = await ApiService.request<AddBranchModel>(
      url: url,
      method: 'GET',
      headers: {
        "Content-Type": "application/json",
        if (token != null) 'Cookie': 'ocurithmToken=$token',
      },
      showError: true,
      fromJson: (json) => AddBranchModel.fromJson(json),
    );

    if (result != null) {
      return result;
    } else {
      throw Exception("Failed fetch branches");
    }
  }

  @override
  Future<AddBranchModel> updateBranch({required String id, required AddBranchModel addBranchModel}) async {
    final url = "${Config.baseUrl}${Config.branches}/$id";
    final String? token = CacheHelper.getData(key: "token");

    final result = await ApiService.request<AddBranchModel>(
      url: url,
      method: 'PUT',
      data: addBranchModel.toJson(),
      headers: {
        "Content-Type": "application/json",
        if (token != null) 'Cookie': 'ocurithmToken=$token',
      },
      showError: true,
      fromJson: (json) => AddBranchModel.fromJson(json),
    );

    if (result != null) {
      return result;
    } else {
      throw Exception("Failed fetch branches");
    }
  }

  @override
  Future<DataModel> deleteBranch({required String id}) async {
    final url = "${Config.baseUrl}${Config.branches}/$id";
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
      throw Exception("Failed fetch branches");
    }
  }

  // @override
  // Future<ReceptionistDetailsModel> ReceptionistDetails({
  //   required String fullName,
  //   required String password,
  //   required String phone,
  //   required String gender,
  //   required String dateOfBirth,
  //   required String branchId,
  // }) async {
  //   try {
  //     Map<String, dynamic> data = {
  //       "full_name": fullName,
  //       "phone": phone,
  //       "password": password,
  //       "branch_id": branchId,
  //       "date_of_birth": dateOfBirth,
  //       "gender": gender,
  //       "role": "Receptionist",
  //     };
  //     log(data.toString());
  //
  //     var dio = Dio();
  //
  //     var response = await dio
  //         .post(
  //           "${Config.baseUrl}Receptionist",
  //           data: data,
  //           options: Options(
  //             headers: {
  //               "authentication": "Bearer ${CacheHelper.getData(key: "token")}",
  //             },
  //             validateStatus: (status) {
  //               return status! < 500;
  //             },
  //           ),
  //         )
  //         .timeout(const Duration(seconds: 10))
  //         .catchError((e) {
  //           if (e.toString().contains("connection error")) {
  //             Get.snackbar("Connection Error", "Please check your internet connection and try again",
  //                 colorText: Colors.white, backgroundColor: Colors.red);
  //           }
  //         })
  //         .timeout(const Duration(seconds: 10))
  //         .catchError((e) {
  //           if (e.toString().contains("connection error")) {
  //             Get.snackbar("Connection Error", "Please check your internet connection and try again",
  //                 colorText: Colors.white, backgroundColor: Colors.red);
  //           }
  //         });
  //
  //     log(response.data.toString());
  //     log(response.realUri.toString());
  //
  //     if (response.statusCode == 200) {
  //       return ReceptionistDetailsModel.fromJson(response.data);
  //     } else {
  //       return ReceptionistDetailsModel.fromJson(response.data);
  //     }
  //   } catch (e) {
  //     log("Caught Error: $e");
  //
  //     if (e is TimeoutException) {
  //       log("Timeout Exception: $e");
  //       Get.snackbar("Timeout", "The request timed out. Please try again later.", colorText: Colors.white, backgroundColor: Colors.red);
  //     } else if (e.toString().contains("SocketException") || e.toString().contains("onError")) {
  //       log("Socket Exception: $e");
  //       //Get.back();
  //       Get.snackbar("Connection Error", "Please check your internet connection and try again", colorText: Colors.white, backgroundColor: Colors.red);
  //     } else {
  //       log("Other Exception: $e");
  //       throw Exception(e.toString());
  //     }
  //     return ReceptionistDetailsModel.fromJson({});
  //   }
  // }

  // @override
  // Future<BranchModel> getBranch() async {
  //   try {
  //     var dio = Dio();
  //
  //     var response = await dio
  //         .get(
  //           "${Config.baseUrl}branch",
  //           options: Options(
  //             headers: {
  //               "authentication": "Bearer ${CacheHelper.getData(key: "token")}",
  //             },
  //             validateStatus: (status) {
  //               return status! < 500;
  //             },
  //           ),
  //         )
  //         .timeout(const Duration(seconds: 10))
  //         .catchError((e) {
  //       if (e.toString().contains("connection error")) {
  //         Get.snackbar("Connection Error", "Please check your internet connection and try again",
  //             colorText: Colors.white, backgroundColor: Colors.red);
  //       }
  //     });
  //
  //     log(response.data.toString());
  //     log(response.realUri.toString());
  //
  //     if (response.statusCode == 200) {
  //       return BranchModel.fromJson(response.data);
  //     } else {
  //       return BranchModel.fromJson(response.data);
  //     }
  //   } catch (e) {
  //     log("Caught Error: $e");
  //
  //     if (e is TimeoutException) {
  //       log("Timeout Exception: $e");
  //       Get.snackbar("Timeout", "The request timed out. Please try again later.", colorText: Colors.white, backgroundColor: Colors.red);
  //     } else if (e.toString().contains("SocketException") || e.toString().contains("onError")) {
  //       log("Socket Exception: $e");
  //       //Get.back();
  //       Get.snackbar("Connection Error", "Please check your internet connection and try again", colorText: Colors.white, backgroundColor: Colors.red);
  //     } else {
  //       log("Other Exception: $e");
  //       throw Exception(e.toString());
  //     }
  //     return BranchModel.fromJson({});
  //   }
  // }
}
