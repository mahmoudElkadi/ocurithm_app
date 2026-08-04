import '../../../Branch/data/model/data.dart';
import '../../../Patient/data/model/one_exam.dart';
import '../model/patient_overview_model.dart';
import '../model/saved_Exam.dart';

abstract class ExaminationRepo {
  Future<ExaminationModel> makeExamination(
      {required Map<String, dynamic> data});

  Future<DataModel> makeFinalization(
      {required String id, required Map<String, dynamic> data});

  /// Soft-deletes an examination. Gated server-side on `deleteExaminations`.
  Future<void> deleteExamination(String id);

  Future<SavedExaminationModel> getOneExamination(
      {required String appointmentId});

  Future<PatientOverviewModel> getPatientOverview(
      {required String patientId});
}
