import 'package:ocurithm/modules/Clinics/data/model/clinics_model.dart';

class SupplierModel {
  SupplierModel({
    required this.suppliers,
    this.total,
    this.totalPages,
    this.success,
  });

  final List<Supplier> suppliers;
  final num? total;
  final num? totalPages;
  final bool? success;

  factory SupplierModel.fromJson(Map<String, dynamic> json) {
    return SupplierModel(
      suppliers: json["suppliers"] == null
          ? []
          : List<Supplier>.from(
              json["suppliers"]!.map((x) => Supplier.fromJson(x))),
      total: json["total"],
      totalPages: json["totalPages"],
      success: json["success"],
    );
  }

  Map<String, dynamic> toJson() => {
        "suppliers": suppliers.map((x) => x.toJson()).toList(),
        "total": total,
        "totalPages": totalPages,
        "success": success,
      };

  SupplierModel copyWith({
    List<Supplier>? suppliers,
    num? total,
    num? totalPages,
    bool? success,
  }) {
    return SupplierModel(
      suppliers: suppliers ?? this.suppliers,
      total: total ?? this.total,
      totalPages: totalPages ?? this.totalPages,
      success: success ?? this.success,
    );
  }
}

class Supplier {
  Supplier({
    this.name,
    this.phoneNumber,
    this.description,
    this.clinic,
    this.isActive,
    this.createdAt,
    this.updatedAt,
    this.id,
  });

  final String? name;
  final String? phoneNumber;
  final String? description;
  final Clinic? clinic;
  final bool? isActive;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final String? id;

  factory Supplier.fromJson(dynamic json) {
    if (json is String) {
      return Supplier(id: json);
    }
    return Supplier(
      name: json["name"],
      phoneNumber: json["phoneNumber"],
      description: json["description"],
      clinic: json["clinic"] == null ? null : Clinic.fromJson(json["clinic"]),
      isActive: json["isActive"],
      createdAt: DateTime.tryParse(json["createdAt"] ?? ""),
      updatedAt: DateTime.tryParse(json["updatedAt"] ?? ""),
      id: json["id"],
    );
  }

  Map<String, dynamic> toJson() => {
        "name": name,
        "phoneNumber": phoneNumber,
        "description": description,
        "clinic": clinic?.toJson(),
        "isActive": isActive,
        "createdAt": createdAt?.toIso8601String(),
        "updatedAt": updatedAt?.toIso8601String(),
        "id": id,
      };

  Supplier copyWith({
    String? name,
    String? phoneNumber,
    String? description,
    Clinic? clinic,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? id,
  }) {
    return Supplier(
      name: name ?? this.name,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      description: description ?? this.description,
      clinic: clinic ?? this.clinic,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      id: id ?? this.id,
    );
  }
}
