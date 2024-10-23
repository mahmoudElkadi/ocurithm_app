abstract class CreateReceptionistRepo {
  Future createReceptionist({
    required String fullName,
    required String password,
    required String phone,
    required String gender,
    required String dateOfBirth,
    required String branchId,
  });
  // Future<BranchModel> getBranch();
}
