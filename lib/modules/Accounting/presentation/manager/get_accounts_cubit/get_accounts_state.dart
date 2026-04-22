import '../../../data/models/account_model.dart';

enum GetAccountsStatus { initial, loading, success, failure, loadingMore }

class GetAccountsState {
  final GetAccountsStatus status;
  final List<Account> accounts;
  final String? errorMessage;
  final int currentPage;
  final bool hasReachedMax;
  final bool noConnection;
  
  // Filters
  final String? search;
  final String? clinic;
  final String? accountType;
  final String? entityType;
  final bool? isActive;
  final int? limit;

  GetAccountsState({
    required this.status,
    this.accounts = const [],
    this.errorMessage,
    this.currentPage = 1,
    this.hasReachedMax = false,
    this.noConnection = false,
    this.search,
    this.clinic,
    this.accountType,
    this.entityType,
    this.isActive,
    this.limit,
  });

  factory GetAccountsState.initial() {
    return GetAccountsState(
      status: GetAccountsStatus.initial,
      limit: 20,
    );
  }

  GetAccountsState copyWith({
    GetAccountsStatus? status,
    List<Account>? accounts,
    String? errorMessage,
    int? currentPage,
    bool? hasReachedMax,
    bool? noConnection,
    String? search,
    String? clinic,
    String? accountType,
    String? entityType,
    bool? isActive,
    int? limit,
  }) {
    return GetAccountsState(
      status: status ?? this.status,
      accounts: accounts ?? this.accounts,
      errorMessage: errorMessage ?? this.errorMessage,
      currentPage: currentPage ?? this.currentPage,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
      noConnection: noConnection ?? this.noConnection,
      search: search ?? this.search,
      clinic: clinic ?? this.clinic,
      accountType: accountType ?? this.accountType,
      entityType: entityType ?? this.entityType,
      isActive: isActive ?? this.isActive,
      limit: limit ?? this.limit,
    );
  }
}
