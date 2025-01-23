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
}
