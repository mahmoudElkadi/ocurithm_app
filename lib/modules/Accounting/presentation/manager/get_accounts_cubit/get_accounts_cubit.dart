import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ocurithm/core/utils/network_connection.dart';
import '../../../data/repos/accounts_repo.dart';
import 'get_accounts_event.dart';
import 'get_accounts_state.dart';

class GetAccountsCubit extends Bloc<GetAccountsEvent, GetAccountsState> {
  final AccountsRepo accountsRepo;

  GetAccountsCubit(this.accountsRepo) : super(GetAccountsState.initial()) {
    on<GetAllAccountsEvent>(_onGetAllAccounts);
    on<LoadMoreAccountsEvent>(_onLoadMoreAccounts);
    on<ResetAccountFilters>(_onResetFilters);
  }

  Future<void> _onGetAllAccounts(
      GetAllAccountsEvent event, Emitter<GetAccountsState> emit) async {
    if (await NetworkStatus().hasInternetConnection() == false) {
      emit(state.copyWith(status: GetAccountsStatus.failure, noConnection: true));
      return;
    }

    emit(state.copyWith(
      status: GetAccountsStatus.loading,
      search: event.search,
      clinic: event.clinic,
      accountType: event.accountType,
      entityType: event.entityType,
      isActive: event.isActive,
      limit: event.limit,
      currentPage: 1,
      hasReachedMax: false,
      noConnection: false,
    ));

    try {
      final accountModel = await accountsRepo.getAllAccounts(
        page: 1,
        limit: event.limit,
        search: event.search,
        clinic: event.clinic,
        accountType: event.accountType,
        entityType: event.entityType,
        isActive: event.isActive,
      );

      emit(state.copyWith(
        status: GetAccountsStatus.success,
        accounts: accountModel.accounts,
        hasReachedMax: (accountModel.totalPages ?? 1) <= 1,
      ));
    } catch (e) {
      emit(state.copyWith(
          status: GetAccountsStatus.failure, errorMessage: e.toString()));
    }
  }

  Future<void> _onLoadMoreAccounts(
      LoadMoreAccountsEvent event, Emitter<GetAccountsState> emit) async {
    if (state.hasReachedMax || state.status == GetAccountsStatus.loadingMore) {
      return;
    }

    emit(state.copyWith(status: GetAccountsStatus.loadingMore));

    try {
      final nextPage = state.currentPage + 1;
      final accountModel = await accountsRepo.getAllAccounts(
        page: nextPage,
        limit: state.limit,
        search: state.search,
        clinic: state.clinic,
        accountType: state.accountType,
        entityType: state.entityType,
        isActive: state.isActive,
      );

      if (accountModel.accounts.isEmpty) {
        emit(state.copyWith(hasReachedMax: true, status: GetAccountsStatus.success));
      } else {
        emit(state.copyWith(
          status: GetAccountsStatus.success,
          accounts: List.of(state.accounts)..addAll(accountModel.accounts),
          currentPage: nextPage,
          hasReachedMax: nextPage >= (accountModel.totalPages ?? 1),
        ));
      }
    } catch (e) {
      emit(state.copyWith(
          status: GetAccountsStatus.failure, errorMessage: e.toString()));
    }
  }

  void _onResetFilters(ResetAccountFilters event, Emitter<GetAccountsState> emit) {
    add(GetAllAccountsEvent());
  }
}
