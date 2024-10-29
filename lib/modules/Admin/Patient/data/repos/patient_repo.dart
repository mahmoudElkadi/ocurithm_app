import '../../../Branch/data/model/branches_model.dart';
import '../../../Branch/data/model/data.dart';
import '../model/patients_model.dart';

abstract class PatientRepo {
  Future<Patient> createPatient({required Patient patient});

  Future<PatientModel> getAllPatients({
    int? page,
    String? search,
    String? branch,
    bool? isActive,
  });

  Future<Patient> getPatient({required String id});

  Future<Patient> updatePatient({required String id, required Patient patient});

  Future<DataModel> deletePatient({required String id});

  Future<BranchesModel> getAllBranches();
}
