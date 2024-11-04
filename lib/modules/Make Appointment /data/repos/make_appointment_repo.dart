import '../../../Branch/data/model/branches_model.dart';
import '../../../Doctor/data/model/doctor_model.dart';

abstract class MakeAppointmentRepo {
  Future<DoctorModel> getAllDoctors({
    String? branch,
    bool? isActive,
  });
  Future<BranchesModel> getAllBranches();
}
