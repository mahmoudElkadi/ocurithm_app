import 'package:ocurithm/modules/Clinics/data/model/clinics_model.dart';

class MedicinesModel {
  MedicinesModel({
    this.success,
    required this.commercialNames,
    this.total,
    this.totalPages,
  });

  final bool? success;
  final List<CommercialName> commercialNames;
  final num? total;
  final num? totalPages;

  factory MedicinesModel.fromJson(Map<String, dynamic> json) {
    return MedicinesModel(
      success: json["success"],
      commercialNames: json["commercialNames"] == null
          ? []
          : List<CommercialName>.from(
              json["commercialNames"]!.map((x) => CommercialName.fromJson(x))),
      total: json["total"],
      totalPages: json["totalPages"],
    );
  }

  Map<String, dynamic> toJson() => {
        "success": success,
        "commercialNames": commercialNames.map((x) => x?.toJson()).toList(),
        "total": total,
        "totalPages": totalPages,
      };
}

class CommercialName {
  CommercialName({
    this.deletedAt,
    this.deletedBy,
    this.clinic,
    this.parentId,
    this.name,
    this.description,
    this.concentration,
    this.isActive,
    this.createdAt,
    this.updatedAt,
    this.isActiveIngredient,
    this.isCommercialName,
    this.id,
    this.createdBy,
    this.updatedBy,
    this.prescribedCount,
  });

  final dynamic deletedAt;
  final dynamic deletedBy;
  final Clinic? clinic;
  final ParentId? parentId;
  final String? name;
  final String? description;
  final String? concentration;
  final bool? isActive;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final bool? isActiveIngredient;
  final bool? isCommercialName;
  final String? id;
  final String? createdBy;
  final String? updatedBy;
  final int? prescribedCount;

  factory CommercialName.fromJson(Map<String, dynamic> json) {
    return CommercialName(
      deletedAt: json["deletedAt"],
      deletedBy: json["deletedBy"],
      prescribedCount: json["prescribedCount"],
      clinic: json["clinic"] == null ? null : Clinic.fromJson(json["clinic"]),
      parentId:
          json["parentId"] == null ? null : ParentId.fromJson(json["parentId"]),
      name: json["name"],
      description: json["description"],
      concentration: json["concentration"],
      isActive: json["isActive"],
      createdAt: DateTime.tryParse(json["createdAt"] ?? ""),
      updatedAt: DateTime.tryParse(json["updatedAt"] ?? ""),
      isActiveIngredient: json["isActiveIngredient"],
      isCommercialName: json["isCommercialName"],
      id: json["id"],
      createdBy: json["createdBy"],
      updatedBy: json["updatedBy"],
    );
  }

  Map<String, dynamic> toJson() => {
        "deletedAt": deletedAt,
        "deletedBy": deletedBy,
        "prescribedCount": prescribedCount,
        "clinic": clinic?.toJson(),
        "parentId": parentId?.toJson(),
        "name": name,
        "description": description,
        "concentration": concentration,
        "isActive": isActive,
        "createdAt": createdAt?.toIso8601String(),
        "updatedAt": updatedAt?.toIso8601String(),
        "isActiveIngredient": isActiveIngredient,
        "isCommercialName": isCommercialName,
        "id": id,
        "createdBy": createdBy,
        "updatedBy": updatedBy,
      };
}

class ParentId {
  ParentId({
    this.name,
    this.isActiveIngredient,
    this.isCommercialName,
    this.id,
  });

  final String? name;
  final bool? isActiveIngredient;
  final bool? isCommercialName;
  final String? id;

  factory ParentId.fromJson(Map<String, dynamic> json) {
    return ParentId(
      name: json["name"],
      isActiveIngredient: json["isActiveIngredient"],
      isCommercialName: json["isCommercialName"],
      id: json["id"],
    );
  }

  Map<String, dynamic> toJson() => {
        "name": name,
        "isActiveIngredient": isActiveIngredient,
        "isCommercialName": isCommercialName,
        "id": id,
      };
}
