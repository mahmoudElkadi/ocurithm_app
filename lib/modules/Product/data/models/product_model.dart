import 'package:ocurithm/modules/Clinics/data/model/clinics_model.dart';
import 'package:ocurithm/modules/SubCategory/data/models/sub_category_model.dart';

class ProductModel {
  ProductModel({
    required this.products,
    this.total,
    this.totalPages,
    this.success,
  });

  final List<Product> products;
  final num? total;
  final num? totalPages;
  final bool? success;

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    return ProductModel(
      products: json["products"] == null
          ? []
          : List<Product>.from(
              json["products"]!.map((x) => Product.fromJson(x))),
      total: json["total"],
      totalPages: json["totalPages"],
      success: json["success"],
    );
  }

  Map<String, dynamic> toJson() => {
        "products": products.map((x) => x.toJson()).toList(),
        "total": total,
        "totalPages": totalPages,
        "success": success,
      };

  ProductModel copyWith({
    List<Product>? products,
    num? total,
    num? totalPages,
    bool? success,
  }) {
    return ProductModel(
      products: products ?? this.products,
      total: total ?? this.total,
      totalPages: totalPages ?? this.totalPages,
      success: success ?? this.success,
    );
  }
}

class Product {
  Product({
    this.name,
    this.description,
    this.image,
    this.sku,
    this.price,
    this.stock,
    this.clinic,
    this.subCategory,
    this.isActive,
    this.createdAt,
    this.updatedAt,
    this.id,
  });

  final String? name;
  final String? description;
  final String? image;
  final String? sku;
  final num? price;
  final num? stock;
  final Clinic? clinic;
  final SubCategory? subCategory;
  final bool? isActive;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final String? id;

  String? get clinicId => clinic?.id;
  String? get subCategoryId => subCategory?.id;

  static Product fromJson(dynamic json) {
    if (json is String) {
      return Product(id: json);
    }
    return Product(
      name: json["name"],
      description: json["description"],
      image: json["image"],
      sku: json["sku"],
      price: json["price"],
      stock: json["stock"],
      clinic: json["clinic"] == null ? null : Clinic.fromJson(json["clinic"]),
      subCategory: json["subCategory"] == null
          ? null
          : SubCategory.fromJson(json["subCategory"]),
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
        "sku": sku,
        "price": price,
        "stock": stock,
        "clinic": clinic?.toJson(),
        "subCategory": subCategory?.toJson(),
        "isActive": isActive,
        "createdAt": createdAt?.toIso8601String(),
        "updatedAt": updatedAt?.toIso8601String(),
        "id": id,
      };

  Product copyWith({
    String? name,
    String? description,
    String? image,
    String? sku,
    num? price,
    num? stock,
    Clinic? clinic,
    SubCategory? subCategory,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? id,
  }) {
    return Product(
      name: name ?? this.name,
      description: description ?? this.description,
      image: image ?? this.image,
      sku: sku ?? this.sku,
      price: price ?? this.price,
      stock: stock ?? this.stock,
      clinic: clinic ?? this.clinic,
      subCategory: subCategory ?? this.subCategory,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      id: id ?? this.id,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Product && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}
