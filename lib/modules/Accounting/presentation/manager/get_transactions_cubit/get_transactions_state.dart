import '../../../data/models/transaction_model.dart';

enum GetTransactionsStatus { initial, loading, success, failure, loadingMore }

class GetTransactionsState {
  final GetTransactionsStatus status;
  final List<AccountTransaction> transactions;
  final String? errorMessage;
  final int currentPage;
  final bool hasReachedMax;
  final bool noConnection;
  
  // Filter values
  final String? search;
  final String? clinic;
  final String? accountId;
  final String? direction;
  final String? fromAccount;
  final String? toAccount;
  final String? source;
  final String? startDate;
  final String? endDate;
  final int limit;

  GetTransactionsState({
    required this.status,
    this.transactions = const [],
    this.errorMessage,
    this.currentPage = 1,
    this.hasReachedMax = false,
    this.noConnection = false,
    this.search,
    this.clinic,
    this.accountId,
    this.direction,
    this.fromAccount,
    this.toAccount,
    this.source,
    this.startDate,
    this.endDate,
    this.limit = 20,
  });

  factory GetTransactionsState.initial() {
    return GetTransactionsState(status: GetTransactionsStatus.initial);
  }

  GetTransactionsState copyWith({
    GetTransactionsStatus? status,
    List<AccountTransaction>? transactions,
    String? errorMessage,
    int? currentPage,
    bool? hasReachedMax,
    bool? noConnection,
    String? search,
    String? clinic,
    String? accountId,
    String? direction,
    String? fromAccount,
    String? toAccount,
    GetTransactionsStatus? sourceStatus, // Wait, I'll just use String? source
    String? source,
    String? startDate,
    String? endDate,
    int? limit,
  }) {
    return GetTransactionsState(
      status: status ?? this.status,
      transactions: transactions ?? this.transactions,
      errorMessage: errorMessage ?? this.errorMessage,
      currentPage: currentPage ?? this.currentPage,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
      noConnection: noConnection ?? this.noConnection,
      search: search ?? this.search,
      clinic: clinic ?? this.clinic,
      accountId: accountId ?? this.accountId,
      direction: direction ?? this.direction,
      fromAccount: fromAccount ?? this.fromAccount,
      toAccount: toAccount ?? this.toAccount,
      source: source ?? this.source,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      limit: limit ?? this.limit,
    );
  }
}
