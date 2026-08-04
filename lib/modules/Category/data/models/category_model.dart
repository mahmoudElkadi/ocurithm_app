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
  /// Resolved, directly-viewable image URL (the backend's storage service
  /// signs this on every read) — display only, never send this back.
  final String? image;
  /// The backend's own storage key for this image (e.g. `category-image/…`).
  /// This is what must be resubmitted on update if the image is unchanged —
  /// the backend validates the `image` field against its own key prefix and
  /// rejects anything else, including a resolved URL, with a 400.
  final String? imageKey;
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
    this.imageKey,
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
    return Category(
      name: json["name"],
      description: json["description"],
      image: imageUrl,
      imageKey: imageKey,
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
        "image": imageKey,
        "clinic": clinic?.toJson(),
        "isActive": isActive,
        "createdAt": createdAt?.toIso8601String(),
        "updatedAt": updatedAt?.toIso8601String(),
        "id": id,
      };
}
