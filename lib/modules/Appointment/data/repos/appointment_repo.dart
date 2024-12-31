import '../../../Branch/data/model/branches_model.dart';
import '../../../Doctor/data/model/doctor_model.dart';
import '../models/appointment_model.dart';

abstract class AppointmentRepo {
  Future<DoctorModel> getAllDoctors({
    String? branch,
    bool? isActive,
  });
  Future<BranchesModel> getAllBranches();
  Future<AppointmentModel> getAllAppointment({DateTime? date, String? branch, String? doctor});
  Future<Appointment> editAppointment({required String id, required String action, DateTime? date, String? doctor});
}
