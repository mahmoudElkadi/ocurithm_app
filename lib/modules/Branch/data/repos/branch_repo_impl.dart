import '../../../../core/api/api_handler.dart';
import '../../../../core/api/api_constants.dart';
import '../model/add_branch_model.dart';
import '../model/branches_model.dart';
import '../model/data.dart';
import 'branch_repo.dart';

class BranchRepoImpl implements BranchRepo {
  final ApiHandler _apiHandler = ApiHandler();

  @override
  Future<AddBranchModel> createBranch(
      {required AddBranchModel addBranchModel}) async {
    final response = await _apiHandler.post<AddBranchModel>(
      ApiConstants.branches,
      data: addBranchModel.toJson(),
      fromJson: (json) => AddBranchModel.fromJson(json),
    );

    if (response.success && response.data != null) {
      return response.data!;
    } else {
      throw Exception(response.message ?? "Failed to add branch");
    }
  }

  @override
  Future<BranchesModel> getAllBranches(
      {int? page, String? search, String? clinic}) async {
    Map<String, dynamic> query = {
      if (page != null) "page": page,
      if (page != null) 'limit': 10,
      if (search != null) "search": search,
      if (clinic != null) "clinic": clinic
    };

    final response = await _apiHandler.get<BranchesModel>(
      ApiConstants.branches,
      queryParameters: query,
      fromJson: (json) => BranchesModel.fromJson(json),
    );

    if (response.success && response.data != null) {
      return response.data!;
    } else {
      throw Exception(response.message ?? "Failed fetch branches");
    }
  }

  @override
  Future<AddBranchModel> getBranch({required String id}) async {
    final response = await _apiHandler.get<AddBranchModel>(
      "${ApiConstants.branches}/$id",
      fromJson: (json) => AddBranchModel.fromJson(json),
    );

    if (response.success && response.data != null) {
      return response.data!;
    } else {
      throw Exception(response.message ?? "Failed fetch branches");
    }
  }

  @override
  Future<AddBranchModel> updateBranch(
      {required String id, required AddBranchModel addBranchModel}) async {
    final response = await _apiHandler.put<AddBranchModel>(
      "${ApiConstants.branches}/$id",
      data: addBranchModel.toJson(),
      fromJson: (json) => AddBranchModel.fromJson(json),
    );

    if (response.success && response.data != null) {
      return response.data!;
    } else {
      throw Exception(response.message ?? "Failed fetch branches");
    }
  }

  @override
  Future<DataModel> deleteBranch({required String id}) async {
    final response = await _apiHandler.delete<DataModel>(
      "${ApiConstants.branches}/$id",
      fromJson: (json) => DataModel.fromJson(json),
    );

    if (response.success && response.data != null) {
      return response.data!;
    } else {
      throw Exception(response.message ?? "Failed fetch branches");
    }
  }
}
