import '../../../Branch/data/model/data.dart';

abstract class ExaminationRepo {
  Future<DataModel> makeExamination({required Map<String, dynamic> data});
}
