import '../model/save_reason_model.dart';

abstract class SaveReasonRepo {
  Future<SaveReasonsModel> getAllSaveReasons(
      {int? page, String? search, String? clinic});
  Future<SaveReason> getSaveReason({required String id});
  Future<SaveReason> createSaveReason({required SaveReason saveReason});
  Future<SaveReason> updateSaveReason(
      {required String id, required SaveReason saveReason});
  Future deleteSaveReason({required String id});
}
