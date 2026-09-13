import 'package:get_it/get_it.dart';
import 'package:ocurithm/modules/Doctor/presentation/manager/get_doctor_examinations_cubit/get_doctor_examinations_cubit.dart';
import 'package:ocurithm/modules/Examination/presentation/manager/examination_form_cubit/examination_form_cubit.dart';

import '../../modules/Analysis/data/repos/analysis_repo.dart';
import '../../modules/Analysis/data/repos/analysis_repo_impl.dart';
import '../../modules/Analysis/presentation/manager/analysis_cubit/get_analysis_cubit.dart';
import '../../modules/Appointment/data/repos/appointment_repo.dart';
import '../../modules/Appointment/data/repos/appointment_repo_impl.dart';
import '../../modules/Appointment/presentation/manager/Appointment cubit/appointment_cubit.dart';
import '../../modules/Branch/data/repos/branch_repo.dart';
import '../../modules/Branch/data/repos/branch_repo_impl.dart';
import '../../modules/Branch/presentation/manager/branch_actions_cubit/branch_actions_cubit.dart';
import '../../modules/Branch/presentation/manager/get_branches_cubit/get_branches_cubit.dart';
import '../../modules/Branch/presentation/manager/get_single_branch_cubit/get_single_branch_cubit.dart';
import '../../modules/Category/data/repos/category_repo.dart';
import '../../modules/Category/data/repos/category_repo_impl.dart';
import '../../modules/Category/presentation/manager/category_actions_cubit/category_actions_cubit.dart';
import '../../modules/Category/presentation/manager/get_categories_cubit/get_categories_cubit.dart';
// Chat Module
import '../../modules/Chat/data/repos/chat_repo.dart';
import '../../modules/Chat/data/repos/chat_repo_impl.dart';
import '../../modules/Chat/presentation/manager/chat_messages_bloc/chat_messages_bloc.dart';
import '../../modules/Chat/presentation/manager/chat_socket_bloc/chat_socket_bloc.dart';
import '../../modules/Chat/presentation/manager/chat_threads_bloc/chat_threads_bloc.dart';
import '../../modules/Chat/presentation/manager/get_chat_users_bloc/get_chat_users_bloc.dart';
import '../../modules/Clinics/data/repos/clinic_repo.dart';
import '../../modules/Clinics/data/repos/clinic_repo_impl.dart';
import '../../modules/Clinics/presentation/manager/clinic_actions_cubit/clinic_actions_cubit.dart';
import '../../modules/Clinics/presentation/manager/get_clinics_cubit/get_clinics_cubit.dart';
import '../../modules/Clinics/presentation/manager/get_single_clinic_cubit/get_single_clinic_cubit.dart';
import '../../modules/Dashboard/data/repos/dashboard_repo.dart';
import '../../modules/Dashboard/data/repos/dashboard_repo_impl.dart';
import '../../modules/Dashboard/presentation/manager/dashboard_cubit.dart';
import '../../modules/Doctor/data/repos/doctor_repo.dart';
import '../../modules/Doctor/data/repos/doctor_repo_impl.dart';
import '../../modules/Doctor/presentation/manager/doctor_actions_cubit/doctor_actions_cubit.dart';
import '../../modules/Doctor/presentation/manager/doctor_branch_actions_cubit/doctor_branch_actions_cubit.dart';
import '../../modules/Doctor/presentation/manager/get_doctors_cubit/get_doctors_cubit.dart';
import '../../modules/Doctor/presentation/manager/get_single_doctor_cubit/get_single_doctor_cubit.dart';
import '../../modules/Save Reasons/data/repos/save_reason_repo.dart';
import '../../modules/Save Reasons/data/repos/save_reason_repo_impl.dart';
import '../../modules/Save Reasons/presentation/manager/get_save_reasons_cubit/get_save_reasons_cubit.dart';
import '../../modules/Save Reasons/presentation/manager/save_reason_actions_cubit/save_reason_actions_cubit.dart';
import '../../modules/Examination Type/data/repos/examination_type_repo.dart';
import '../../modules/Examination Type/data/repos/examination_type_repo_impl.dart';
import '../../modules/Examination Type/presentation/manager/examination_type_actions_cubit/examination_type_actions_cubit.dart';
import '../../modules/Examination Type/presentation/manager/get_examination_types_cubit/get_examination_types_cubit.dart';
import '../../modules/Examination Type/presentation/manager/get_single_examination_type_cubit/get_single_examination_type_cubit.dart';
import '../../modules/Examination/data/repos/examination_repo.dart';
import '../../modules/Examination/data/repos/examination_repo_impl.dart';
import '../../modules/Examination/presentation/manager/examination_actions_cubit/examination_actions_cubit.dart';
import '../../modules/Examination/presentation/manager/get_single_examination_cubit/get_single_examination_cubit.dart';
import '../../modules/Examination/presentation/manager/patient_overview_cubit/patient_overview_cubit.dart';
import '../../modules/Login/data/repos/login_repo.dart';
import '../../modules/Login/data/repos/login_repo_impl.dart';
import '../../modules/Login/presentation/manger/login_cubit/login_cubit.dart';
import '../../modules/Make_Appointment/data/repos/make_appointment_repo.dart';
import '../../modules/Make_Appointment/data/repos/make_appointment_repo_impl.dart';
import '../../modules/Make_Appointment/presentation/manager/Make Appointment cubit/make_appointment_cubit.dart';
import '../../modules/Medicine/data/repos/medicine_repo.dart';
import '../../modules/Medicine/data/repos/medicine_repo_impl.dart';
import '../../modules/Medicine/presentation/manager/get_active_ingredients_cubit/get_active_ingredients_cubit.dart';
import '../../modules/Medicine/presentation/manager/get_medicines_cubit/get_medicines_cubit.dart';
import '../../modules/Medicine/presentation/manager/medicine_actions_cubit/medicine_actions_cubit.dart';
import '../../modules/Order/data/repos/order_repo.dart';
import '../../modules/Order/data/repos/order_repo_impl.dart';
import '../../modules/Order/presentation/manager/get_orders_cubit/get_orders_bloc.dart';
import '../../modules/Order/presentation/manager/order_actions_cubit/order_actions_bloc.dart';
import '../../modules/Patient/data/repos/patient_repo.dart';
import '../../modules/Patient/data/repos/patient_repo_impl.dart';
import '../../modules/Patient/presentation/manager/get_one_examination_cubit/get_one_examination_cubit.dart';
import '../../modules/Patient/presentation/manager/get_patient_examinations_cubit/get_patient_examinations_cubit.dart';
import '../../modules/Patient/presentation/manager/get_patient_scans_cubit/get_patient_scans_cubit.dart';
import '../../modules/Patient/presentation/manager/get_patients_cubit/get_patients_cubit.dart';
import '../../modules/Patient/presentation/manager/get_scan_details_cubit/get_scan_details_cubit.dart';
import '../../modules/Patient/presentation/manager/get_single_patient_cubit/get_single_patient_cubit.dart';
import '../../modules/Patient/presentation/manager/patient_actions_cubit/patient_actions_cubit.dart';
import '../../modules/Patient/presentation/manager/scan_actions_cubit/scan_actions_cubit.dart';
import '../../modules/Payment Methods/data/repos/payment_method_repo.dart';
import '../../modules/Payment Methods/data/repos/payment_method_repo_impl.dart';
import '../../modules/Payment Methods/presentation/manager/get_payment_methods_cubit/get_payment_methods_cubit.dart';
import '../../modules/Payment Methods/presentation/manager/get_single_payment_method_cubit/get_single_payment_method_cubit.dart';
import '../../modules/Payment Methods/presentation/manager/payment_method_actions_cubit/payment_method_actions_cubit.dart';
import '../../modules/Product/data/repos/product_repo.dart';
import '../../modules/Product/data/repos/product_repo_impl.dart';
import '../../modules/Product/presentation/manager/get_products_cubit/get_products_cubit.dart';
import '../../modules/Product/presentation/manager/get_single_product_cubit/get_single_product_cubit.dart';
import '../../modules/Product/presentation/manager/product_actions_cubit/product_actions_cubit.dart';
import '../../modules/PurchaseOrder/data/repos/purchase_order_repo.dart';
import '../../modules/PurchaseOrder/data/repos/purchase_order_repo_impl.dart';
import '../../modules/PurchaseOrder/presentation/manager/get_purchase_orders_cubit/get_purchase_orders_cubit.dart';
import '../../modules/PurchaseOrder/presentation/manager/purchase_order_actions_cubit/purchase_order_actions_cubit.dart';
import '../../modules/Receptionist/data/repos/receptionist_repo.dart';
import '../../modules/Receptionist/data/repos/receptionist_repo_impl.dart';
import '../../modules/Receptionist/presentation/manager/get_capabilities_cubit/get_capabilities_cubit.dart';
import '../../modules/Receptionist/presentation/manager/get_receptionists_cubit/get_receptionists_cubit.dart';
import '../../modules/Receptionist/presentation/manager/get_single_receptionist_cubit/get_single_receptionist_cubit.dart';
import '../../modules/Receptionist/presentation/manager/receptionist_actions_cubit/receptionist_actions_cubit.dart';
import '../../modules/Storage/data/repos/storage_repo.dart';
import '../../modules/Storage/presentation/manager/storage_cubit/storage_cubit.dart';
import '../../modules/SubCategory/data/repos/sub_category_repo.dart';
import '../../modules/SubCategory/data/repos/sub_category_repo_impl.dart';
import '../../modules/SubCategory/presentation/manager/get_sub_categories_cubit/get_sub_categories_cubit.dart';
import '../../modules/SubCategory/presentation/manager/sub_category_actions_cubit/sub_category_actions_cubit.dart';
import '../../modules/Supplier/data/repos/supplier_repo.dart';
import '../../modules/Supplier/data/repos/supplier_repo_impl.dart';
import '../../modules/Supplier/presentation/manager/get_suppliers_cubit/get_suppliers_cubit.dart';
import '../../modules/Supplier/presentation/manager/supplier_actions_cubit/supplier_actions_cubit.dart';
import '../../modules/profile/data/repos/profile_repo.dart';
import '../../modules/profile/data/repos/profile_repo_impl.dart';
import '../../modules/profile/presentation/manager/get_profile_cubit/get_profile_cubit.dart';
import '../../modules/profile/presentation/manager/profile_actions_cubit/profile_actions_cubit.dart';
import '../../modules/Accounting/data/repos/accounts_repo.dart';
import '../../modules/Accounting/data/repos/accounts_repo_impl.dart';
import '../../modules/Accounting/presentation/manager/get_accounts_cubit/get_accounts_cubit.dart';
import '../../modules/Accounting/presentation/manager/account_actions_cubit/account_actions_cubit.dart';
import '../../modules/Accounting/presentation/manager/account_details_cubit/account_details_cubit.dart';
import '../../modules/Accounting/presentation/manager/account_form_cubit/account_form_cubit.dart';
import '../../modules/Accounting/presentation/manager/get_transactions_cubit/get_transactions_cubit.dart';
import '../api/api_handler.dart';

final sl = GetIt.instance;

class ServiceLocator {
  void init() {
    ///Core
    sl.registerLazySingleton<ApiHandler>(() => ApiHandler());

    ///Login
    sl.registerLazySingleton<LoginRepo>(() => LoginRepoImpl());
    sl.registerFactory(() => LoginCubit(sl.call<LoginRepo>()));

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

    ///Save Reasons
    sl.registerLazySingleton<SaveReasonRepo>(() => SaveReasonRepoImpl());
    sl.registerFactory(() => GetSaveReasonsCubit(sl.call<SaveReasonRepo>()));
    sl.registerFactory(() => SaveReasonActionsCubit(sl.call<SaveReasonRepo>()));

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
    sl.registerFactory(() => GetDoctorExaminationsBloc(sl.call<DoctorRepo>()));

    ///Patients
    sl.registerLazySingleton<PatientRepo>(() => PatientRepoImpl());
    sl.registerFactory(() => GetPatientsCubit(sl.call<PatientRepo>()));
    sl.registerFactory(() => PatientActionsCubit(sl.call<PatientRepo>()));
    sl.registerFactory(() => GetSinglePatientCubit(sl.call<PatientRepo>()));
    sl.registerFactory(
        () => GetPatientExaminationsCubit(sl.call<PatientRepo>()));
    sl.registerFactory(() => GetOneExaminationCubit(sl.call<PatientRepo>()));
    sl.registerFactory(() => ScanActionsCubit(sl.call<PatientRepo>()));
    sl.registerFactory(() => GetPatientScansCubit(sl.call<PatientRepo>()));
    sl.registerFactory(() => GetScanDetailsCubit(sl.call<PatientRepo>()));

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
    sl.registerFactory(() => PatientOverviewCubit(sl.call<ExaminationRepo>()));

    ///Analysis
    sl.registerLazySingleton<AnalysisRepo>(() => AnalysisRepoImpl());
    sl.registerFactory(() => GetAnalysisCubit(sl.call<AnalysisRepo>()));

    ///Storage
    sl.registerLazySingleton<StorageRepo>(() => StorageRepoImpl());
    sl.registerFactory(() => StorageCubit(sl.call<StorageRepo>()));

    ///Profile
    sl.registerLazySingleton<ProfileRepo>(() => ProfileRepoImpl());
    sl.registerFactory(() => GetProfileCubit(sl.call<ProfileRepo>()));
    sl.registerFactory(() => ProfileActionsCubit(sl.call<ProfileRepo>()));

    ///Chat
    sl.registerLazySingleton<ChatRepo>(() => ChatRepoImpl());
    sl.registerFactory(() => GetChatUsersBloc(sl.call<ChatRepo>()));
    sl.registerLazySingleton(() => ChatThreadsBloc(
        sl.call<ChatRepo>())); // Singleton to share unread counts
    sl.registerFactory(() => ChatMessagesBloc(sl.call<ChatRepo>()));
    sl.registerLazySingleton(() => ChatSocketBloc()); // Singleton for socket

    ///Dashboard
    sl.registerLazySingleton<DashboardRepo>(() => DashboardRepoImpl());
    sl.registerFactory(() => DashboardCubit(sl.call<DashboardRepo>()));

    ///Make Appointment
    sl.registerLazySingleton<MakeAppointmentRepo>(
        () => MakeAppointmentRepoImpl());
    sl.registerFactory(
        () => MakeAppointmentCubit(sl.call<MakeAppointmentRepo>()));

    ///Appointment
    sl.registerLazySingleton<AppointmentRepo>(() => AppointmentRepoImpl());
    sl.registerFactory(() => AppointmentCubit(sl.call<AppointmentRepo>()));

    ///Categories
    sl.registerLazySingleton<CategoryRepo>(() => CategoryRepoImpl());
    sl.registerFactory(() => GetCategoriesCubit(sl.call<CategoryRepo>()));
    sl.registerFactory(() => CategoryActionsCubit(sl.call<CategoryRepo>()));

    ///SubCategories
    sl.registerLazySingleton<SubCategoryRepo>(() => SubCategoryRepoImpl());
    sl.registerFactory(() => GetSubCategoriesCubit(sl.call<SubCategoryRepo>()));
    sl.registerFactory(
        () => SubCategoryActionsCubit(sl.call<SubCategoryRepo>()));

    ///Products
    sl.registerLazySingleton<ProductRepo>(() => ProductRepoImpl());
    sl.registerFactory(() => GetProductsCubit(sl.call<ProductRepo>()));
    sl.registerFactory(() => ProductActionsCubit(sl.call<ProductRepo>()));
    sl.registerFactory(() => GetSingleProductCubit(sl.call<ProductRepo>()));

    ///Suppliers
    sl.registerLazySingleton<SupplierRepo>(() => SupplierRepoImpl());
    sl.registerFactory(() => GetSuppliersCubit(sl.call<SupplierRepo>()));
    sl.registerFactory(() => SupplierActionsCubit(sl.call<SupplierRepo>()));

    ///PurchaseOrders
    sl.registerLazySingleton<PurchaseOrderRepo>(() => PurchaseOrderRepoImpl());
    sl.registerFactory(
        () => GetPurchaseOrdersCubit(sl.call<PurchaseOrderRepo>()));
    sl.registerFactory(
        () => PurchaseOrderActionsCubit(sl.call<PurchaseOrderRepo>()));

    ///Orders
    sl.registerLazySingleton<OrderRepo>(() => OrderRepoImpl());
    sl.registerFactory(() => GetOrdersBloc(sl.call<OrderRepo>()));
    sl.registerFactory(() => OrderActionsBloc(sl.call<OrderRepo>()));
    ///Accounts
    sl.registerLazySingleton<AccountsRepo>(() => AccountsRepoImpl());
    sl.registerFactory(() => GetAccountsCubit(sl.call<AccountsRepo>()));
    sl.registerFactory(() => AccountActionsCubit(sl.call<AccountsRepo>()));
    sl.registerFactory(() => AccountDetailsCubit(sl.call<AccountsRepo>()));
    sl.registerFactoryParam<AccountFormCubit, bool, void>(
        (isSuperAdmin, _) => AccountFormCubit(sl.call<AccountsRepo>(), isSuperAdmin));
    sl.registerFactory(() => GetTransactionsCubit(sl.call<AccountsRepo>()));
  }
}
