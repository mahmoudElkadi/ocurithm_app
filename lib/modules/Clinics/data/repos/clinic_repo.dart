import '../model/clinics_model.dart';

abstract class ClinicRepo {
  Future<ClinicsModel> getAllClinics({int? page, String? search});
  Future<Clinic> getClinic({required String id});
  Future<Clinic> createClinic({required Clinic clinic});
  Future<Clinic> updateClinic({required String id, required Clinic clinic});
  Future deleteClinic({required String id});
}
