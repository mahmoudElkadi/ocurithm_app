import 'package:ocurithm/modules/Clinics/data/model/clinics_model.dart';
import 'package:ocurithm/modules/Category/data/models/category_model.dart';

class SubCategoryModel {
  SubCategoryModel({
    required this.subCategories,
    this.total,
    this.totalPages,
    this.success,
  });

  final List<SubCategory> subCategories;
  final num? total;
  final num? totalPages;
  final bool? success;

  factory SubCategoryModel.fromJson(Map<String, dynamic> json) {
    return SubCategoryModel(
      subCategories: json["subCategories"] == null
          ? []
          : List<SubCategory>.from(
              json["subCategories"]!.map((x) => SubCategory.fromJson(x))),
      total: json["total"],
      totalPages: json["totalPages"],
      success: json["success"],
    );
  }

  Map<String, dynamic> toJson() => {
        "subCategories": subCategories.map((x) => x.toJson()).toList(),
        "total": total,
        "totalPages": totalPages,
        "success": success,
      };
}

class SubCategory {
  SubCategory({
    this.name,
    this.description,
    this.image,
    this.clinic,
    this.category,
    this.isActive,
    this.createdAt,
    this.updatedAt,
    this.id,
  });

  final String? name;
  final String? description;
  final String? image;
  final Clinic? clinic;
  final Category? category;
  final bool? isActive;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final String? id;

  String? get clinicId => clinic?.id;
  String? get categoryId => category?.id;

  static SubCategory fromJson(dynamic json) {
    if (json is String) {
      return SubCategory(id: json);
    }
    return SubCategory(
      name: json["name"],
      description: json["description"],
      image: json["image"],
      clinic: json["clinic"] == null ? null : Clinic.fromJson(json["clinic"]),
      category: json["category"] == null ? null : Category.fromJson(json["category"]),
      isActive: json["isActive"],
      createdAt: DateTime.tryParse(json["createdAt"] ?? ""),
      updatedAt: DateTime.tryParse(json["updatedAt"] ?? ""),
      id: json["id"],
    );
  }

  Map<String, dynamic> toJson() => {
        "name": name,
        "description": description,
        "image": image,
        "clinic": clinic?.toJson(),
        "category": category?.toJson(),
        "isActive": isActive,
        "createdAt": createdAt?.toIso8601String(),
        "updatedAt": updatedAt?.toIso8601String(),
        "id": id,
      };
}
