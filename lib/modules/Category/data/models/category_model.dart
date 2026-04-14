import 'package:ocurithm/modules/Clinics/data/model/clinics_model.dart';


class CategoryModel {
  CategoryModel({
    required this.categories,
    this.total,
    this.totalPages,
    this.success,
  });

  final List<Category> categories;
  final num? total;
  final num? totalPages;
  final bool? success;

  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    return CategoryModel(
      categories: json["categories"] == null
          ? []
          : List<Category>.from(
              json["categories"]!.map((x) => Category.fromJson(x))),
      total: json["total"],
      totalPages: json["totalPages"],
      success: json["success"],
    );
  }

  Map<String, dynamic> toJson() => {
        "categories": categories.map((x) => x.toJson()).toList(),
        "total": total,
        "totalPages": totalPages,
        "success": success,
      };
}

class Category {
  final String? name;
  final String? description;
  final String? image;
  final Clinic? clinic;
  final bool? isActive;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final String? id;

  String? get clinicId => clinic?.id;

  Category({
    this.name,
    this.description,
    this.image,
    this.clinic,
    this.isActive,
    this.createdAt,
    this.updatedAt,
    this.id,
  });

  static Category fromJson(dynamic json) {
    if (json is String) {
      return Category(id: json);
    }
    return Category(
      name: json["name"],
      description: json["description"],
      image: json["image"],
      clinic: json["clinic"] == null ? null : Clinic.fromJson(json["clinic"]),
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
        "isActive": isActive,
        "createdAt": createdAt?.toIso8601String(),
        "updatedAt": updatedAt?.toIso8601String(),
        "id": id,
      };
}
