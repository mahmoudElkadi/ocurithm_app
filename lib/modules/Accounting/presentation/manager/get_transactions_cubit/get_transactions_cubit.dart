import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ocurithm/core/utils/network_connection.dart';
import '../../../data/repos/accounts_repo.dart';
import 'get_transactions_event.dart';
import 'get_transactions_state.dart';

class GetTransactionsCubit extends Bloc<GetTransactionsEvent, GetTransactionsState> {
  final AccountsRepo accountsRepo;

  GetTransactionsCubit(this.accountsRepo) : super(GetTransactionsState.initial()) {
    on<GetAllTransactionsEvent>(_onGetAllTransactions);
    on<LoadMoreTransactionsEvent>(_onLoadMoreTransactions);
    on<ResetTransactionFilters>(_onResetFilters);
  }

  Future<void> _onGetAllTransactions(
      GetAllTransactionsEvent event, Emitter<GetTransactionsState> emit) async {
    if (await NetworkStatus().hasInternetConnection() == false) {
      emit(state.copyWith(status: GetTransactionsStatus.failure, noConnection: true));
      return;
    }

    emit(state.copyWith(
      status: GetTransactionsStatus.loading,
      search: event.search,
      clinic: event.clinic,
      accountId: event.accountId,
      direction: event.direction,
      fromAccount: event.fromAccount,
      toAccount: event.toAccount,
      source: event.source,
      startDate: event.startDate,
      endDate: event.endDate,
      currentPage: 1,
      hasReachedMax: false,
      noConnection: false,
    ));

    try {
      final transactionModel = await accountsRepo.getAllTransactions(
        page: 1,
        limit: state.limit,
        search: event.search,
        clinic: event.clinic,
        accountId: event.accountId,
        direction: event.direction,
        fromAccount: event.fromAccount,
        toAccount: event.toAccount,
        source: event.source,
        startDate: event.startDate,
        endDate: event.endDate,
      );

      emit(state.copyWith(
        status: GetTransactionsStatus.success,
        transactions: transactionModel.transactions,
        hasReachedMax: (transactionModel.totalPages ?? 1) <= 1,
      ));
    } catch (e) {
      emit(state.copyWith(
          status: GetTransactionsStatus.failure, errorMessage: e.toString()));
    }
  }

  Future<void> _onLoadMoreTransactions(
      LoadMoreTransactionsEvent event, Emitter<GetTransactionsState> emit) async {
    if (state.hasReachedMax || state.status == GetTransactionsStatus.loadingMore) {
      return;
    }

    emit(state.copyWith(status: GetTransactionsStatus.loadingMore));

    try {
      final nextPage = state.currentPage + 1;
      final transactionModel = await accountsRepo.getAllTransactions(
        page: nextPage,
        limit: state.limit,
        search: state.search,
        clinic: state.clinic,
        accountId: state.accountId,
        direction: state.direction,
        fromAccount: state.fromAccount,
        toAccount: state.toAccount,
        source: state.source,
        startDate: state.startDate,
        endDate: state.endDate,
      );

      if (transactionModel.transactions.isEmpty) {
        emit(state.copyWith(hasReachedMax: true, status: GetTransactionsStatus.success));
      } else {
        emit(state.copyWith(
          status: GetTransactionsStatus.success,
          transactions: List.of(state.transactions)..addAll(transactionModel.transactions),
          currentPage: nextPage,
          hasReachedMax: nextPage >= (transactionModel.totalPages ?? 1),
        ));
      }
    } catch (e) {
      emit(state.copyWith(
          status: GetTransactionsStatus.failure, errorMessage: e.toString()));
    }
  }

  void _onResetFilters(ResetTransactionFilters event, Emitter<GetTransactionsState> emit) {
    add(GetAllTransactionsEvent());
  }
}
