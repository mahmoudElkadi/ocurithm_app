import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../data/repos/accounts_repo.dart';
import 'account_form_state.dart';

class AccountFormCubit extends Cubit<AccountFormState> {
  final AccountsRepo accountsRepo;

  AccountFormCubit(this.accountsRepo, bool isSuperAdmin) 
      : super(AccountFormState.initial(isSuperAdmin));

  void onClinicChanged(String? clinicId) {
    emit(state.copyWith(
      selectedClinicId: clinicId,
      selectedOwnerId: null,
      ownerOptions: [],
    ));
    // If account type is already selected, fetch owners for this clinic
    if (state.selectedAccountType != null) {
      fetchOwnerOptions();
    }
  }

  void onAccountTypeChanged(String? accountType) {
    emit(state.copyWith(
      selectedAccountType: accountType,
      selectedOwnerId: null,
      ownerOptions: [],
    ));
    
    if (accountType != null && accountType != 'other') {
      fetchOwnerOptions();
    }
  }

  void onOwnerChanged(String? ownerId) {
    emit(state.copyWith(selectedOwnerId: ownerId));
  }

  Future<void> fetchOwnerOptions({String? accountId}) async {
    if (state.selectedAccountType == null || state.selectedAccountType == 'other') return;
    
    // For Super Admin, clinic must be selected
    if (state.isSuperAdmin && state.selectedClinicId == null) return;

    emit(state.copyWith(status: AccountFormStatus.loading));
    try {
      final options = await accountsRepo.getOwnerOptions(
        accountType: state.selectedAccountType!,
        accountId: accountId,
        clinicId: state.selectedClinicId,
      );
      emit(state.copyWith(
        status: AccountFormStatus.success,
        ownerOptions: options,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: AccountFormStatus.failure,
        errorMessage: e.toString(),
      ));
    }
  }
}
