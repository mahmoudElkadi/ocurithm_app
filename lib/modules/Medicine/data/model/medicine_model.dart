import 'active_ingredient_model.dart';

class MedicinesModel {
  MedicinesModel({
    required this.medicines,
    this.total,
    this.totalPages,
    this.error,
  });

  List<Medicine> medicines;
  num? total;
  num? totalPages;
  String? error;

  factory MedicinesModel.fromJson(Map<String, dynamic> json) {
    return MedicinesModel(
      medicines: json["medicines"] == null
          ? []
          : List<Medicine>.from(
              json["medicines"]!.map((x) => Medicine.fromJson(x))),
      total: json["total"],
      totalPages: json["totalPages"],
      error: json["error"],
    );
  }

  Map<String, dynamic> toJson() => {
        "medicines": medicines.map((x) => x.toJson()).toList(),
        "total": total,
        "totalPages": totalPages,
        "error": error,
      };
}

class Medicine {
  Medicine({
    this.name,
    this.description,
    this.concentration,
    this.reminder,
    this.parentId,
    this.activeIngredient,
    this.id,
    this.error,
  });

  String? name;
  String? description;
  String? concentration;
  String? reminder;
  String? parentId;
  ActiveIngredient? activeIngredient;
  String? id;
  String? error;

  factory Medicine.fromJson(Map<String, dynamic> json) {
    return Medicine(
      name: json["name"],
      description: json["description"],
      concentration: json["concentration"],
      reminder: json["reminder"],
      parentId: json["parent_id"],
      activeIngredient: json["active_ingredient"] != null
          ? ActiveIngredient.fromJson(json["active_ingredient"])
          : null,
      id: json["id"],
      error: json["error"],
    );
  }

  Map<String, dynamic> toJson() => {
        "name": name,
        "description": description,
        "concentration": concentration,
        "reminder": reminder,
        "parent_id": parentId,
        "id": id,
        "error": error,
      };
}
