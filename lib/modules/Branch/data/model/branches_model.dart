import 'package:ocurithm/modules/Clinics/data/model/clinics_model.dart';

class BranchesModel {
  BranchesModel({
    required this.branches,
    this.total,
    this.totalPages,
    this.error,
  });

  List<Branch> branches;
  num? total;
  num? totalPages;
  String? error;

  factory BranchesModel.fromJson(Map<String, dynamic> json) {
    return BranchesModel(
      branches: json["branches"] == null ? [] : List<Branch>.from(json["branches"]!.map((x) => Branch.fromJson(x))),
      total: json["total"],
      totalPages: json["totalPages"],
      error: json["error"],
    );
  }

  Map<String, dynamic> toJson() => {
        "branches": branches.map((x) => x?.toJson()).toList(),
        "total": total,
        "totalPages": totalPages,
        "error": error,
      };
}

class Branch {
  Branch({
    this.clinic,
    this.code,
    this.name,
    this.address,
    this.phone,
    this.openTime,
    this.closeTime,
    this.workDays,
    this.createdAt,
    this.updatedAt,
    this.id,
    this.error,
  });

  Clinic? clinic;
  String? code;
  String? name;
  String? address;
  String? phone;
  String? openTime;
  String? closeTime;
  List<String>? workDays;
  DateTime? createdAt;
  DateTime? updatedAt;
  String? id;
  String? error;

  factory Branch.fromJson(Map<String, dynamic> json) {
    return Branch(
      clinic: json["clinic"] == null ? null : Clinic.fromJson(json["clinic"]),
      code: json["code"],
      name: json["name"],
      address: json["address"],
      phone: json["phone"],
      openTime: json["openTime"],
      closeTime: json["closeTime"],
      workDays: json["workDays"] == null ? [] : List<String>.from(json["workDays"]!.map((x) => x)),
      createdAt: DateTime.tryParse(json["createdAt"] ?? ""),
      updatedAt: DateTime.tryParse(json["updatedAt"] ?? ""),
      id: json["id"],
      error: json["error"],
    );
  }

  Map<String, dynamic> toJson() => {
        "clinic": clinic,
        "code": code,
        "name": name,
        "address": address,
        "phone": phone,
        "openTime": openTime,
        "closeTime": closeTime,
        "workDays": workDays?.map((x) => x).toList(),
      };
}
