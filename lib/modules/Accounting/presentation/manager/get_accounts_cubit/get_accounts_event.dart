abstract class GetAccountsEvent {}

class GetAllAccountsEvent extends GetAccountsEvent {
  final int? page;
  final String? search;
  final String? clinic;
  final String? accountType;
  final String? entityType;
  final bool? isActive;
  final int? limit;

  GetAllAccountsEvent({
    this.page,
    this.limit,
    this.search,
    this.clinic,
    this.accountType,
    this.entityType,
    this.isActive,
  });
}

class LoadMoreAccountsEvent extends GetAccountsEvent {}

class ResetAccountFilters extends GetAccountsEvent {}
