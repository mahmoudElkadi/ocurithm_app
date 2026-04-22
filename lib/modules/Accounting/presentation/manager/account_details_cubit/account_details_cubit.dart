import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../data/repos/accounts_repo.dart';
import 'account_details_state.dart';

class AccountDetailsCubit extends Cubit<AccountDetailsState> {
  final AccountsRepo accountsRepo;

  AccountDetailsCubit(this.accountsRepo) : super(AccountDetailsState.initial());

  Future<void> loadAccountDetails(String accountId) async {
    emit(state.copyWith(status: AccountDetailsStatus.loading));
    try {
      final account = await accountsRepo.getAccountById(accountId);
      emit(state.copyWith(
        status: AccountDetailsStatus.success,
        account: account,
      ));
      // Load initial transactions
      loadTransactions(accountId, reset: true);
    } catch (e) {
      emit(state.copyWith(
        status: AccountDetailsStatus.failure,
        errorMessage: e.toString(),
      ));
    }
  }

  Future<void> loadTransactions(String accountId, {bool reset = false}) async {
    if (!reset && (state.hasReachedMaxTransactions || state.status == AccountDetailsStatus.loadingMoreTransactions)) return;
    
    if (!reset) emit(state.copyWith(status: AccountDetailsStatus.loadingMoreTransactions));

    final page = reset ? 1 : state.currentTransactionsPage + 1;
    
    try {
      final transactionModel = await accountsRepo.getAccountTransactions(
        accountId,
        page: page,
        type: state.transactionFilter == 'all' ? null : state.transactionFilter,
      );

      emit(state.copyWith(
        transactions: reset 
            ? transactionModel.transactions 
            : [...state.transactions, ...transactionModel.transactions],
        currentTransactionsPage: page,
        hasReachedMaxTransactions: page >= (transactionModel.totalPages ?? 1),
        status: AccountDetailsStatus.success,
      ));
    } catch (e) {
      // We might not want to fail the whole page if just transactions fail
      emit(state.copyWith(errorMessage: e.toString(), status: AccountDetailsStatus.success));
    }
  }

  void changeTransactionFilter(String accountId, String filter) {
    if (state.transactionFilter == filter) return;
    emit(state.copyWith(transactionFilter: filter));
    loadTransactions(accountId, reset: true);
  }
}
