import 'package:ocurithm/modules/Admin/Doctor/data/model/doctor_model.dart';

import '../../../Branch/data/model/branches_model.dart';
import '../../../Branch/data/model/data.dart';

abstract class DoctorRepo {
  Future<Doctor> createDoctor({required Doctor doctor});

  Future<DoctorModel> getAllDoctors({
    int? page,
    String? search,
    String? branch,
    bool? isActive,
  });

  Future<Doctor> getDoctor({required String id});

  Future<Doctor> updateDoctor({required String id, required Doctor doctor});

  Future<DataModel> deleteDoctor({required String id});

  Future<BranchesModel> getAllBranches();
}
