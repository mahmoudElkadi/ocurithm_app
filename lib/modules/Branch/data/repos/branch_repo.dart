import '../model/add_branch_model.dart';
import '../model/branches_model.dart';

abstract class BranchRepo {
  Future<BranchesModel> getAllBranches({int? page, String? search});
  Future<AddBranchModel> getBranch({required String id});
  Future<AddBranchModel> createBranch({required AddBranchModel addBranchModel});
  Future<AddBranchModel> updateBranch({required String id, required AddBranchModel addBranchModel});
  Future deleteBranch({required String id});
  // Future<BranchModel> getBranch();
}
