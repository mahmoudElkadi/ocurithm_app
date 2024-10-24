import 'package:ocurithm/modules/Admin/Branch/data/model/add_branch_model.dart';

abstract class BranchRepo {
  Future<AddBranchModel> createBranch({required AddBranchModel addBranchModel});
  // Future<BranchModel> getBranch();
}
