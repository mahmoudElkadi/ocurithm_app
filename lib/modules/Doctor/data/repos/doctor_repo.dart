import '../../../Branch/data/model/branches_model.dart';
import '../../../Branch/data/model/data.dart';
import '../model/doctor_model.dart';

abstract class DoctorRepo {
  Future<Doctor> createDoctor({required Doctor doctor});

  Future<DoctorModel> getAllDoctors({
    int? page,
    String? search,
    String? branch,
    String? clinic,
    bool? isActive,
  });

  Future<Doctor> getDoctor({required String id});

  Future<Doctor> updateDoctor({required String id, required Doctor doctor});

  Future<DataModel> deleteDoctor({required String id});

  Future<BranchesModel> getAllBranches();

  Future<Doctor> addBranch(
      {required String doctorId, required String branchId, required String availableFrom, required String availableTo, required List availableDays});
  Future<Doctor> editBranch(
      {required String doctorId, required String branchId, required String availableFrom, required String availableTo, required List availableDays});
  Future<Doctor> deleteBranch({required String doctorId, required String branchId});
}
