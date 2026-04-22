import '../models/account_model.dart';
import '../models/transaction_model.dart';

abstract class AccountsRepo {
  Future<AccountModel> getAllAccounts({
    int? page,
    int? limit,
    String? search,
    String? clinic,
    String? accountType,
    String? entityType,
    bool? isActive,
  });

  Future<Account> getAccountById(String id);

  Future<Account> createAccount({
    required String name,
    required String accountType,
    String? entityId,
    num? initialBalance,
    String? clinicId,
  });

  Future<Account> updateAccount(
    String id, {
    String? name,
    bool? isActive,
    String? accountType,
    String? entityId,
  });

  Future<void> deleteAccount(String id);

  Future<List<OwnerOption>> getOwnerOptions({
    required String accountType,
    String? accountId,
    String? clinicId,
  });

  Future<TransactionModel> getAccountTransactions(
    String accountId, {
    int? page,
    int? limit,
    String? type, // Incoming / Outgoing / null for All
  });

  Future<void> addTransaction({
    required String fromAccountId,
    required String toAccountId,
    required num amount,
    String? source,
    String? note,
    DateTime? date,
  });

  Future<TransactionModel> getAllTransactions({
    int? page,
    int? limit,
    String? clinic,
    String? accountId,
    String? direction,
    String? fromAccount,
    String? toAccount,
    String? source,
    String? startDate,
    String? endDate,
    String? search,
  });

  Future<void> updateTransaction(
    String id, {
    String? fromAccountId,
    String? toAccountId,
    num? amount,
    String? source,
    String? note,
    DateTime? date,
  });

  Future<void> deleteTransaction(String id);
}
