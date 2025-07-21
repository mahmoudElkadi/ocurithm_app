import '../../../Branch/data/model/data.dart';
import '../../../Patient/data/model/one_exam.dart';
import '../model/saved_Exam.dart';

abstract class ExaminationRepo {
  Future<ExaminationModel> makeExamination(
      {required Map<String, dynamic> data});

  Future<DataModel> makeFinalization(
      {required String id, required Map<String, dynamic> data});

  Future<SavedExaminationModel> getOneExamination(
      {required String appointmentId});
}
