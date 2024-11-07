import '../../../Branch/data/model/branches_model.dart';
import '../../../Doctor/data/model/doctor_model.dart';
import '../../../Examination Type/data/model/examination_type_model.dart';
import '../../../Patient/data/model/patients_model.dart';
import '../../../Payment Methods/data/model/payment_method_model.dart';

abstract class MakeAppointmentRepo {
  Future<DoctorModel> getAllDoctors({
    String? branch,
    bool? isActive,
  });
  Future<BranchesModel> getAllBranches();

  Future<PaymentMethodsModel> getAllPaymentMethods({int? page, String? search});
  Future<ExaminationTypesModel> getAllExaminationTypes({int? page, String? search});
  Future<PatientModel> getAllPatients({
    int? page,
    String? search,
    String? branch,
    bool? isActive,
  });
}
