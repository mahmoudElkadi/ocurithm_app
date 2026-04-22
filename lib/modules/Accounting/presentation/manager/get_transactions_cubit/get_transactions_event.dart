abstract class GetTransactionsEvent {}

class GetAllTransactionsEvent extends GetTransactionsEvent {
  final int? page;
  final int? limit;
  final String? clinic;
  final String? accountId;
  final String? direction;
  final String? fromAccount;
  final String? toAccount;
  final String? source;
  final String? startDate;
  final String? endDate;
  final String? search;

  GetAllTransactionsEvent({
    this.page,
    this.limit,
    this.clinic,
    this.accountId,
    this.direction,
    this.fromAccount,
    this.toAccount,
    this.source,
    this.startDate,
    this.endDate,
    this.search,
  });
}

class LoadMoreTransactionsEvent extends GetTransactionsEvent {}

class ResetTransactionFilters extends GetTransactionsEvent {}
