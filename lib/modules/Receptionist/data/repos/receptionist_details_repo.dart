import '../../../Branch/data/model/branches_model.dart';
import '../../../Branch/data/model/data.dart';
import '../models/add_reception_model.dart';
import '../models/receptionists_model.dart';

abstract class ReceptionistRepo {
  Future<AddReceptionistsModel> createReceptionist({required Receptionist receptionist});
  Future<ReceptionistsModel> getAllReceptionists({int? page, String? search});
  Future<Receptionist> getReceptionist({required String id});
  Future<Receptionist> updateReceptionist({required String id, required Receptionist receptionist});
  Future<DataModel> deleteReceptionist({required String id});
  Future<BranchesModel> getAllBranches();
}
