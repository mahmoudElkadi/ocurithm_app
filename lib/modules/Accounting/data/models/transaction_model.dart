import 'package:ocurithm/modules/Accounting/data/models/account_model.dart';

class TransactionModel {
  TransactionModel({
    required this.transactions,
    this.total,
    this.totalPages,
    this.success,
  });

  final List<AccountTransaction> transactions;
  final num? total;
  final num? totalPages;
  final bool? success;

  factory TransactionModel.fromJson(Map<String, dynamic> json) {
    return TransactionModel(
      transactions: json["transactions"] == null
          ? []
          : List<AccountTransaction>.from(
              json["transactions"]!.map((x) => AccountTransaction.fromJson(x))),
      total: json["total"],
      totalPages: json["totalPages"],
      success: json["success"],
    );
  }

  Map<String, dynamic> toJson() => {
        "transactions": transactions.map((x) => x.toJson()).toList(),
        "total": total,
        "totalPages": totalPages,
        "success": success,
      };
}

class AccountTransaction {
  AccountTransaction({
    this.fromAccount,
    this.toAccount,
    this.amount,
    this.source,
    this.note,
    this.date,
    this.id,
    this.createdAt,
  });

  final Account? fromAccount;
  final Account? toAccount;
  final num? amount;
  final String? source;
  final String? note;
  final DateTime? date;
  final String? id;
  final DateTime? createdAt;

  factory AccountTransaction.fromJson(Map<String, dynamic> json) {
    return AccountTransaction(
      fromAccount: json["fromAccount"] == null ? null : Account.fromJson(json["fromAccount"]),
      toAccount: json["toAccount"] == null ? null : Account.fromJson(json["toAccount"]),
      amount: json["amount"],
      source: json["source"],
      note: json["note"],
      date: DateTime.tryParse(json["date"] ?? ""),
      id: json["id"],
      createdAt: DateTime.tryParse(json["createdAt"] ?? ""),
    );
  }

  Map<String, dynamic> toJson() => {
        "fromAccount": fromAccount?.toJson(),
        "toAccount": toAccount?.toJson(),
        "amount": amount,
        "source": source,
        "note": note,
        "date": date?.toIso8601String(),
        "id": id,
        "createdAt": createdAt?.toIso8601String(),
      };
}
