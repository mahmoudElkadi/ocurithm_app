import 'package:ocurithm/modules/Clinics/data/model/clinics_model.dart';

class AccountModel {
  AccountModel({
    required this.accounts,
    this.total,
    this.totalPages,
    this.success,
  });

  final List<Account> accounts;
  final num? total;
  final num? totalPages;
  final bool? success;

  factory AccountModel.fromJson(Map<String, dynamic> json) {
    return AccountModel(
      accounts: json["accounts"] == null
          ? []
          : List<Account>.from(
              json["accounts"]!.map((x) => Account.fromJson(x))),
      total: json["total"],
      totalPages: json["totalPages"],
      success: json["success"],
    );
  }

  Map<String, dynamic> toJson() => {
        "accounts": accounts.map((x) => x.toJson()).toList(),
        "total": total,
        "totalPages": totalPages,
        "success": success,
      };
}

class Account {
  Account({
    this.name,
    this.accountType,
    this.entityType,
    this.entityId,
    this.initialBalance,
    this.currentBalance,
    this.isActive,
    this.clinic,
    this.createdAt,
    this.updatedAt,
    this.id,
  });

  final String? name;
  final String? accountType;
  final String? entityType;
  final String? entityId;
  final num? initialBalance;
  final num? currentBalance;
  final bool? isActive;
  final Clinic? clinic;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final String? id;

  static Account fromJson(dynamic json) {
    if (json is String) {
      return Account(id: json);
    }
    return Account(
      name: json["name"],
      accountType: json["accountType"],
      entityType: json["entityType"],
      entityId: json["entityId"],
      initialBalance: json["initialBalance"],
      currentBalance: json["currentBalance"],
      isActive: json["isActive"],
      clinic: json["clinic"] == null ? null : Clinic.fromJson(json["clinic"]),
      createdAt: DateTime.tryParse(json["createdAt"] ?? ""),
      updatedAt: DateTime.tryParse(json["updatedAt"] ?? ""),
      id: json["id"],
    );
  }

  Map<String, dynamic> toJson() => {
        "name": name,
        "accountType": accountType,
        "entityType": entityType,
        "entityId": entityId,
        "initialBalance": initialBalance,
        "currentBalance": currentBalance,
        "isActive": isActive,
        "clinic": clinic?.toJson(),
        "createdAt": createdAt?.toIso8601String(),
        "updatedAt": updatedAt?.toIso8601String(),
        "id": id,
      };

  Account copyWith({
    String? name,
    String? accountType,
    String? entityType,
    String? entityId,
    num? initialBalance,
    num? currentBalance,
    bool? isActive,
    Clinic? clinic,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? id,
  }) {
    return Account(
      name: name ?? this.name,
      accountType: accountType ?? this.accountType,
      entityType: entityType ?? this.entityType,
      entityId: entityId ?? this.entityId,
      initialBalance: initialBalance ?? this.initialBalance,
      currentBalance: currentBalance ?? this.currentBalance,
      isActive: isActive ?? this.isActive,
      clinic: clinic ?? this.clinic,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      id: id ?? this.id,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Account && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}

class OwnerOption {
  final String id;
  final String name;

  OwnerOption({required this.id, required this.name});

  factory OwnerOption.fromJson(Map<String, dynamic> json) {
    return OwnerOption(
      id: json["id"],
      name: json["label"] ?? json["name"] ?? "Unknown",
    );
  }
}
