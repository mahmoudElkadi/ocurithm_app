import '../../../Branch/data/model/branches_model.dart';
import '../../../Branch/data/model/data.dart';
import '../model/one_exam.dart';
import '../model/patient_examination.dart';
import '../model/patients_model.dart';
import '../model/scan_records_model.dart';

abstract class PatientRepo {
  Future<Patient> createPatient({required Patient patient});

  Future<PatientModel> getAllPatients({
    int? page,
    String? search,
    String? branch,
    String? clinic,
    bool? isActive,
  });

  Future<Patient> getPatient({required String id});

  Future<Patient> updatePatient({required String id, required Patient patient});

  Future<DataModel> deletePatient({required String id});

  /// Moves every clinical record (appointments, examinations, billings,
  /// surgeries, scans, leads) from [sourceId] into [targetId]. Irreversible.
  /// When [deleteSource] is true the source patient is soft-deleted afterwards.
  Future<TransferPatientResult> transferPatient({
    required String sourceId,
    required String targetId,
    required bool deleteSource,
  });

  Future<BranchesModel> getAllBranches();
  Future<Examinations> getPatientExaminations({required String id});
  Future<ExaminationModel> getOneExamination({required String id});

  Future<void> createScanRecord({
    required String patientId,
    required String doctorId,
    required String comment,
    required String scanDate,
    required List<String> files,
    String? eye,
    List<String>? investigations,
  });

  Future<ScanRecordsModel> getPatientScans({
    required String patientId,
    int? page,
    int? limit,
    String? doctorId,
    String? fromDate,
    String? toDate,
  });

  Future<ScanRecord> getScanDetails({
    required String patientId,
    required String scanId,
  });

  Future<void> deleteScan({
    required String patientId,
    required String scanId,
  });

  Future<ScanRecord> editScanFile({
    required String patientId,
    required String scanId,
    required String fileId,
    required String newKey,
  });

  Future<ScanRecord> restoreScanFile({
    required String patientId,
    required String scanId,
    required String fileId,
  });

  Future<bool> checkDuplicateName({required String name});
}
