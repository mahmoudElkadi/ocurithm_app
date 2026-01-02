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
  }
}
