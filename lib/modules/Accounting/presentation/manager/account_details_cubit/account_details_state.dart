import '../../../data/models/account_model.dart';
import '../../../data/models/transaction_model.dart';

enum AccountDetailsStatus { initial, loading, success, failure, loadingMoreTransactions }

class AccountDetailsState {
  final AccountDetailsStatus status;
  final Account? account;
  final List<AccountTransaction> transactions;
  final String? errorMessage;
  final int currentTransactionsPage;
  final bool hasReachedMaxTransactions;
  final String? transactionFilter; // 'all', 'incoming', 'outgoing'

  AccountDetailsState({
    required this.status,
    this.account,
    this.transactions = const [],
    this.errorMessage,
    this.currentTransactionsPage = 1,
    this.hasReachedMaxTransactions = false,
    this.transactionFilter = 'all',
  });

  factory AccountDetailsState.initial() {
    return AccountDetailsState(status: AccountDetailsStatus.initial);
  }

  AccountDetailsState copyWith({
    AccountDetailsStatus? status,
    Account? account,
    List<AccountTransaction>? transactions,
    String? errorMessage,
    int? currentTransactionsPage,
    bool? hasReachedMaxTransactions,
    String? transactionFilter,
  }) {
    return AccountDetailsState(
      status: status ?? this.status,
      account: account ?? this.account,
      transactions: transactions ?? this.transactions,
      errorMessage: errorMessage ?? this.errorMessage,
      currentTransactionsPage:
          currentTransactionsPage ?? this.currentTransactionsPage,
      hasReachedMaxTransactions:
          hasReachedMaxTransactions ?? this.hasReachedMaxTransactions,
      transactionFilter: transactionFilter ?? this.transactionFilter,
    );
  }
}
