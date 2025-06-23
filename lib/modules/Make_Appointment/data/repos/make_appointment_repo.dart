import '../../../Appointment/data/models/appointment_model.dart';
import '../../../Branch/data/model/branches_model.dart';
import '../../../Doctor/data/model/doctor_model.dart';
import '../../../Examination Type/data/model/examination_type_model.dart';
import '../../../Patient/data/model/patients_model.dart';
import '../../../Payment Methods/data/model/payment_method_model.dart';
import '../models/make_appointment_model.dart';

abstract class MakeAppointmentRepo {
  Future<DoctorModel> getAllDoctors({
    String? branch,
  });
  Future<BranchesModel> getAllBranches();

  Future<PaymentMethodsModel> getAllPaymentMethods({int? page, String? clinic});
  Future<ExaminationTypesModel> getAllExaminationTypes({int? page, String? clinic});
  Future<PatientModel> getAllPatients({String? search});

  Future<Appointment> makeAppointment({required MakeAppointmentModel model});
  Future<Appointment> editAppointment({required MakeAppointmentModel model, required String id});
  Future<AppointmentModel> getAllAppointment({DateTime? date, String? branch, String? doctor});
}
