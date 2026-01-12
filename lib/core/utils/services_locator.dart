import 'package:get_it/get_it.dart';

import '../../modules/Clinics/data/repos/clinic_repo.dart';
import '../../modules/Clinics/data/repos/clinic_repo_impl.dart';
import '../../modules/Clinics/presentation/manager/clinic_actions_cubit/clinic_actions_cubit.dart';
import '../../modules/Clinics/presentation/manager/get_clinics_cubit/get_clinics_cubit.dart';
import '../../modules/Clinics/presentation/manager/get_single_clinic_cubit/get_single_clinic_cubit.dart';
import '../../modules/Branch/data/repos/branch_repo.dart';
import '../../modules/Branch/data/repos/branch_repo_impl.dart';
import '../../modules/Branch/presentation/manager/branch_actions_cubit/branch_actions_cubit.dart';
import '../../modules/Branch/presentation/manager/get_branches_cubit/get_branches_cubit.dart';
import '../../modules/Branch/presentation/manager/get_single_branch_cubit/get_single_branch_cubit.dart';
import '../../modules/Payment Methods/data/repos/payment_method_repo.dart';
import '../../modules/Payment Methods/data/repos/payment_method_repo_impl.dart';
import '../../modules/Payment Methods/presentation/manager/get_payment_methods_cubit/get_payment_methods_cubit.dart';
import '../../modules/Payment Methods/presentation/manager/payment_method_actions_cubit/payment_method_actions_cubit.dart';
import '../../modules/Payment Methods/presentation/manager/get_single_payment_method_cubit/get_single_payment_method_cubit.dart';
import '../../modules/Examination Type/data/repos/examination_type_repo.dart';
import '../../modules/Examination Type/data/repos/examination_type_repo_impl.dart';
import '../../modules/Examination Type/presentation/manager/get_examination_types_cubit/get_examination_types_cubit.dart';
import '../../modules/Examination Type/presentation/manager/examination_type_actions_cubit/examination_type_actions_cubit.dart';
import '../../modules/Examination Type/presentation/manager/get_single_examination_type_cubit/get_single_examination_type_cubit.dart';
import '../../modules/Receptionist/data/repos/receptionist_repo.dart';
import '../../modules/Receptionist/data/repos/receptionist_repo_impl.dart';
import '../../modules/Receptionist/presentation/manager/receptionist_actions_cubit/receptionist_actions_cubit.dart';
import '../../modules/Receptionist/presentation/manager/get_receptionists_cubit/get_receptionists_cubit.dart';
import '../../modules/Receptionist/presentation/manager/get_single_receptionist_cubit/get_single_receptionist_cubit.dart';
import '../../modules/Receptionist/presentation/manager/get_capabilities_cubit/get_capabilities_cubit.dart';
import '../../modules/Doctor/data/repos/doctor_repo.dart';
import '../../modules/Doctor/data/repos/doctor_repo_impl.dart';
import '../../modules/Doctor/presentation/manager/doctor_actions_cubit/doctor_actions_cubit.dart';
import '../../modules/Doctor/presentation/manager/get_doctors_cubit/get_doctors_cubit.dart';
import '../../modules/Doctor/presentation/manager/get_single_doctor_cubit/get_single_doctor_cubit.dart';
import '../../modules/Doctor/presentation/manager/doctor_branch_actions_cubit/doctor_branch_actions_cubit.dart';
import '../../modules/Patient/data/repos/patient_repo.dart';
import '../../modules/Patient/data/repos/patient_repo_impl.dart';
import '../../modules/Patient/presentation/manager/get_patients_cubit/get_patients_cubit.dart';
import '../../modules/Patient/presentation/manager/patient_actions_cubit/patient_actions_cubit.dart';
import '../../modules/Patient/presentation/manager/get_single_patient_cubit/get_single_patient_cubit.dart';
import '../../modules/Patient/presentation/manager/get_patient_examinations_cubit/get_patient_examinations_cubit.dart';
import '../../modules/Patient/presentation/manager/get_one_examination_cubit/get_one_examination_cubit.dart';
import '../../modules/Medicine/data/repos/medicine_repo.dart';
import '../../modules/Medicine/data/repos/medicine_repo_impl.dart';
import '../../modules/Medicine/presentation/manager/get_medicines_cubit/get_medicines_cubit.dart';
import '../../modules/Medicine/presentation/manager/medicine_actions_cubit/medicine_actions_cubit.dart';
import '../../modules/Medicine/presentation/manager/get_active_ingredients_cubit/get_active_ingredients_cubit.dart';
import '../../modules/Examination/data/repos/examination_repo.dart';
import '../../modules/Examination/data/repos/examination_repo_impl.dart';
import '../../modules/Examination/presentation/manager/examination_actions_cubit/examination_actions_cubit.dart';
import '../../modules/Examination/presentation/manager/get_single_examination_cubit/get_single_examination_cubit.dart';
import 'package:ocurithm/modules/Examination/presentation/manager/examination_form_cubit/examination_form_cubit.dart';

final sl = GetIt.instance;

class ServiceLocator {
  void init() {
    ///Clinics
    sl.registerLazySingleton<ClinicRepo>(() => ClinicRepoImpl());
    sl.registerFactory(() => GetClinicsCubit(sl.call<ClinicRepo>()));
    sl.registerFactory(() => ClinicActionsCubit(sl.call<ClinicRepo>()));
    sl.registerFactory(() => GetSingleClinicCubit(sl.call<ClinicRepo>()));

    ///Branches
    sl.registerLazySingleton<BranchRepo>(() => BranchRepoImpl());
    sl.registerFactory(() => GetBranchesCubit(sl.call<BranchRepo>()));
    sl.registerFactory(() => BranchActionsCubit(sl.call<BranchRepo>()));
    sl.registerFactory(() => GetSingleBranchCubit(sl.call<BranchRepo>()));

    ///Payment Methods
    sl.registerLazySingleton<PaymentMethodRepo>(() => PaymentMethodRepoImpl());
    sl.registerFactory(
        () => GetPaymentMethodsCubit(sl.call<PaymentMethodRepo>()));
    sl.registerFactory(
        () => PaymentMethodActionsCubit(sl.call<PaymentMethodRepo>()));
    sl.registerFactory(
        () => GetSinglePaymentMethodCubit(sl.call<PaymentMethodRepo>()));

    ///Examination Types
    sl.registerLazySingleton<ExaminationTypeRepo>(
        () => ExaminationTypeRepoImpl());
    sl.registerFactory(
        () => GetExaminationTypesCubit(sl.call<ExaminationTypeRepo>()));
    sl.registerFactory(
        () => ExaminationTypeActionsCubit(sl.call<ExaminationTypeRepo>()));
    sl.registerFactory(
        () => GetSingleExaminationTypeCubit(sl.call<ExaminationTypeRepo>()));

    ///Receptionists
    sl.registerLazySingleton<ReceptionistRepo>(() => ReceptionistRepoImpl());
    sl.registerFactory(
        () => GetReceptionistsCubit(sl.call<ReceptionistRepo>()));
    sl.registerFactory(
        () => ReceptionistActionsCubit(sl.call<ReceptionistRepo>()));
    sl.registerFactory(
        () => GetSingleReceptionistCubit(sl.call<ReceptionistRepo>()));
    sl.registerFactory(() => GetCapabilitiesCubit(sl.call<ReceptionistRepo>()));

    ///Doctors
    sl.registerLazySingleton<DoctorRepo>(() => DoctorRepoImpl());
    sl.registerFactory(() => GetDoctorsCubit(sl.call<DoctorRepo>()));
    sl.registerFactory(() => DoctorActionsCubit(sl.call<DoctorRepo>()));
    sl.registerFactory(() => GetSingleDoctorCubit(sl.call<DoctorRepo>()));
    sl.registerFactory(() => DoctorBranchActionsCubit(sl.call<DoctorRepo>()));

    ///Patients
    sl.registerLazySingleton<PatientRepo>(() => PatientRepoImpl());
    sl.registerFactory(() => GetPatientsCubit(sl.call<PatientRepo>()));
    sl.registerFactory(() => PatientActionsCubit(sl.call<PatientRepo>()));
    sl.registerFactory(() => GetSinglePatientCubit(sl.call<PatientRepo>()));
    sl.registerFactory(
        () => GetPatientExaminationsCubit(sl.call<PatientRepo>()));
    sl.registerFactory(() => GetOneExaminationCubit(sl.call<PatientRepo>()));

    ///Medicines
    sl.registerLazySingleton<MedicineRepo>(() => MedicineRepoImpl());
    sl.registerFactory(
        () => GetMedicinesCubit(medicineRepo: sl.call<MedicineRepo>()));
    sl.registerFactory(
        () => MedicineActionsCubit(medicineRepo: sl.call<MedicineRepo>()));
    sl.registerFactory(
        () => GetActiveIngredientsCubit(medicineRepo: sl.call<MedicineRepo>()));

    ///Examinations
    sl.registerLazySingleton<ExaminationRepo>(() => ExaminationRepoImpl());
    sl.registerFactory(
        () => ExaminationActionsCubit(sl.call<ExaminationRepo>()));
    sl.registerFactory(
        () => GetSingleExaminationCubit(sl.call<ExaminationRepo>()));
    sl.registerFactory(() => ExaminationFormCubit());
  }
}
