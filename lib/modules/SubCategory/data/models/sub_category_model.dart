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
    this.imageKey,
    this.clinic,
    this.category,
    this.isActive,
    this.createdAt,
    this.updatedAt,
    this.id,
  });

  final String? name;
  final String? description;
  /// Resolved, directly-viewable image URL (the backend's storage service
  /// signs this on every read) — display only, never send this back.
  final String? image;
  /// The backend's own storage key for this image (reuses `category-image/…`
  /// — sub-categories are validated against `FileCategory.CATEGORY_IMAGE`,
  /// same as Category). This is what must be resubmitted on update if the
  /// image is unchanged — the backend validates the `image` field against its
  /// own key prefix and rejects anything else, including a resolved URL,
  /// with a 400.
  final String? imageKey;
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
    final rawImage = json["image"];
    String? imageUrl;
    String? imageKey;
    if (rawImage is String) {
      // Defensive: not the documented shape, but avoids a crash if ever seen.
      imageUrl = rawImage;
      imageKey = rawImage;
    } else if (rawImage is Map) {
      imageUrl = rawImage["url"] as String?;
      imageKey = rawImage["key"] as String?;
    }
    return SubCategory(
      name: json["name"],
      description: json["description"],
      image: imageUrl,
      imageKey: imageKey,
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
        "image": imageKey,
        "clinic": clinic?.toJson(),
        "category": category?.toJson(),
        "isActive": isActive,
        "createdAt": createdAt?.toIso8601String(),
        "updatedAt": updatedAt?.toIso8601String(),
        "id": id,
      };
}
