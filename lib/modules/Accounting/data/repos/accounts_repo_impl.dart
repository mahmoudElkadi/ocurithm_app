import '../../../../core/api/api_constants.dart';
import '../../../../core/api/api_handler.dart';
import '../models/account_model.dart';
import '../models/transaction_model.dart';
import 'accounts_repo.dart';

class AccountsRepoImpl implements AccountsRepo {
  final ApiHandler _apiHandler = ApiHandler();

  @override
  Future<AccountModel> getAllAccounts({
    int? page,
    int? limit,
    String? search,
    String? clinic,
    String? accountType,
    String? entityType,
    bool? isActive,
  }) async {
    try {
      Map<String, dynamic> query = {
        if (page != null) "page": page,
        if (limit != null) "limit": limit,
        if (search != null && search.isNotEmpty) "search": search,
        if (clinic != null && clinic.isNotEmpty) "clinic": clinic,
        if (accountType != null && accountType.isNotEmpty)
          "accountType": accountType,
        if (entityType != null && entityType.isNotEmpty)
          "entityType": entityType,
        if (isActive != null) "isActive": isActive.toString(),
      };

      final response = await _apiHandler.get<AccountModel>(
        ApiConstants.accounts,
        queryParameters: query,
        fromJson: (json) => AccountModel.fromJson(json),
      );

      if (response.success && response.data != null) {
        return response.data!;
      } else {
        throw Exception(response.message ?? 'Failed to fetch accounts');
      }
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<Account> getAccountById(String id) async {
    try {
      final response = await _apiHandler.get(
        "${ApiConstants.accounts}/$id",
        fromJson: (json) => Account.fromJson(json),
      );
      if (response.success && response.data != null) {
        return response.data!;
      } else {
        throw Exception(response.message ?? 'Failed to fetch account');
      }
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<Account> createAccount({
    required String name,
    required String accountType,
    String? entityId,
    num? initialBalance,
    String? clinicId,
  }) async {
    try {
      final response = await _apiHandler.post(
        ApiConstants.accounts,
        data: {
          "name": name,
          "accountType": accountType,
          if (entityId != null) "entityId": entityId,
          if (initialBalance != null) "initialBalance": initialBalance,
          if (clinicId != null) "clinic": clinicId,
        },
      );

      if (response.success && response.data != null) {
        return Account.fromJson(response.data);
      } else {
        throw Exception(response.message ?? 'Failed to create account');
      }
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<Account> updateAccount(
    String id, {
    String? name,
    bool? isActive,
    String? accountType,
    String? entityId,
  }) async {
    try {
      final response = await _apiHandler.put(
        "${ApiConstants.accounts}/$id",
        data: {
          if (name != null) "name": name,
          if (isActive != null) "isActive": isActive,
          if (accountType != null) "accountType": accountType,
          if (entityId != null) "entityId": entityId,
        },
      );

      if (response.success && response.data != null) {
        return Account.fromJson(response.data);
      } else {
        throw Exception(response.message ?? 'Failed to update account');
      }
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> deleteAccount(String id) async {
    try {
      final response = await _apiHandler.delete("${ApiConstants.accounts}/$id");
      if (!response.success) {
        throw Exception(response.message ?? 'Failed to delete account');
      }
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<List<OwnerOption>> getOwnerOptions({
    required String accountType,
    String? accountId,
    String? clinicId,
  }) async {
    try {
      Map<String, dynamic> query = {
        "accountType": accountType,
        if (accountId != null) "accountId": accountId,
        if (clinicId != null) "clinic": clinicId,
      };

      final response = await _apiHandler.get(
        ApiConstants.accountOwnerOptions,
        queryParameters: query,
        fromJson: (json) {
          if (json is Map<String, dynamic> && json.containsKey('ownerOptions')) {
            final options = json['ownerOptions'] as List;
            return options.map((e) => OwnerOption.fromJson(e)).toList();
          } else if (json is List) {
            return json.map((e) => OwnerOption.fromJson(e)).toList();
          }
          return <OwnerOption>[];
        },
      );

      if (response.success && response.data != null) {
        return response.data!;
      } else {
        throw Exception(response.message ?? 'Failed to fetch owner options');
      }
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<TransactionModel> getAccountTransactions(
    String accountId, {
    int? page,
    int? limit,
    String? type,
  }) async {
    try {
      Map<String, dynamic> query = {
        "accountId": accountId,
        if (page != null) "page": page,
        if (limit != null) "limit": limit,
        if (type != null) "type": type,
      };

      final response = await _apiHandler.get<TransactionModel>(
        ApiConstants.transactions,
        queryParameters: query,
        fromJson: (json) => TransactionModel.fromJson(json),
      );

      if (response.success && response.data != null) {
        return response.data!;
      } else {
        throw Exception(response.message ?? 'Failed to fetch transactions');
      }
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> addTransaction({
    required String fromAccountId,
    required String toAccountId,
    required num amount,
    String? source,
    String? note,
    DateTime? date,
  }) async {
    try {
      final response = await _apiHandler.post(
        ApiConstants.transactions,
        data: {
          "fromAccount": fromAccountId,
          "toAccount": toAccountId,
          "amount": amount,
          "source": source ?? "manual",
          if (note != null) "note": note,
          if (date != null) "date": date.toIso8601String(),
        },
      );

      if (!response.success) {
        throw Exception(response.message ?? 'Failed to add transaction');
      }
    } catch (e) {
      rethrow;
    }
  }

  @override
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
  }) async {
    try {
      Map<String, dynamic> query = {
        if (page != null) "page": page,
        if (limit != null) "limit": limit,
        if (clinic != null) "clinic": clinic,
        if (accountId != null) "accountId": accountId,
        if (direction != null) "direction": direction,
        if (fromAccount != null) "fromAccount": fromAccount,
        if (toAccount != null) "toAccount": toAccount,
        if (source != null) "source": source,
        if (startDate != null) "startDate": startDate,
        if (endDate != null) "endDate": endDate,
        if (search != null) "search": search,
      };

      final response = await _apiHandler.get<TransactionModel>(
        ApiConstants.transactions,
        queryParameters: query,
        fromJson: (json) => TransactionModel.fromJson(json),
      );

      if (response.success && response.data != null) {
        return response.data!;
      } else {
        throw Exception(response.message ?? 'Failed to fetch transactions');
      }
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> updateTransaction(
    String id, {
    String? fromAccountId,
    String? toAccountId,
    num? amount,
    String? source,
    String? note,
    DateTime? date,
  }) async {
    try {
      final response = await _apiHandler.put(
        "${ApiConstants.transactions}/$id",
        data: {
          if (fromAccountId != null) "fromAccount": fromAccountId,
          if (toAccountId != null) "toAccount": toAccountId,
          if (amount != null) "amount": amount,
          if (source != null) "source": source,
          if (note != null) "note": note,
          if (date != null) "date": date.toIso8601String(),
        },
      );

      if (!response.success) {
        throw Exception(response.message ?? 'Failed to update transaction');
      }
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> deleteTransaction(String id) async {
    try {
      final response = await _apiHandler.delete(
        "${ApiConstants.transactions}/$id",
      );

      if (!response.success) {
        throw Exception(response.message ?? 'Failed to delete transaction');
      }
    } catch (e) {
      rethrow;
    }
  }
}
