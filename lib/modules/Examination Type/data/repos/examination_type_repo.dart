import '../model/examination_type_model.dart';

abstract class ExaminationTypeRepo {
  Future<ExaminationTypesModel> getAllExaminationTypes({int? page, String? search});
  Future<ExaminationType> getExaminationType({required String id});
  Future<ExaminationType> createExaminationType({required ExaminationType examinationType});
  Future<ExaminationType> updateExaminationType({required String id, required ExaminationType examinationType});
  Future deleteExaminationType({required String id});
}
