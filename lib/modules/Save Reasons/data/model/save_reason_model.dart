import 'package:ocurithm/modules/Clinics/data/model/clinics_model.dart';

class SaveReasonsModel {
  SaveReasonsModel({
    this.saveReasons,
    this.total,
    this.totalPages,
    this.error,
  });

  List<SaveReason>? saveReasons;
  num? total;
  num? totalPages;
  String? error;

  factory SaveReasonsModel.fromJson(Map<String, dynamic> json) {
    return SaveReasonsModel(
      saveReasons: json["saveReasons"] == null
          ? []
          : List<SaveReason>.from(
              json["saveReasons"]!.map((x) => SaveReason.fromJson(x))),
      total: json["total"],
      totalPages: json["totalPages"],
      error: json["error"],
    );
  }

  Map<String, dynamic> toJson() => {
        "saveReasons": saveReasons?.map((x) => x.toJson()).toList(),
        "total": total,
        "totalPages": totalPages,
      };

  SaveReasonsModel copyWith({
    List<SaveReason>? saveReasons,
    num? total,
    num? totalPages,
    String? error,
  }) {
    return SaveReasonsModel(
      saveReasons: saveReasons ?? this.saveReasons,
      total: total ?? this.total,
      totalPages: totalPages ?? this.totalPages,
      error: error ?? this.error,
    );
  }
}

/// Why a visit was parked. Picked by the doctor when saving an examination as a
/// draft; the backend snapshots the name and price onto the save session so later
/// edits here never rewrite what was already recorded.
class SaveReason {
  SaveReason({
    this.name,
    this.price,
    this.clinic,
    this.createdAt,
    this.updatedAt,
    this.id,
    this.error,
    this.allowCycloplegicRefraction = false,
  });

  String? name;
  num? price;
  Clinic? clinic;

  /// Parking a visit for this reason unlocks the Cycloplegic Refraction group when
  /// the doctor resumes it.
  bool allowCycloplegicRefraction;
  DateTime? createdAt;
  DateTime? updatedAt;
  String? id;
  String? error;

  factory SaveReason.fromJson(Map<String, dynamic> json) {
    return SaveReason(
      name: json["name"],
      price: json["price"],
      allowCycloplegicRefraction: json["allowCycloplegicRefraction"] == true,
      clinic: json["clinic"] == null ? null : Clinic.fromJson(json["clinic"]),
      createdAt: DateTime.tryParse(json["createdAt"] ?? ""),
      updatedAt: DateTime.tryParse(json["updatedAt"] ?? ""),
      id: json["id"],
      error: json["error"],
    );
  }

  Map<String, dynamic> toJson() => {
        "name": name,
        "price": price ?? 0,
        "allowCycloplegicRefraction": allowCycloplegicRefraction,
        "clinic": clinic?.id,
      };

  SaveReason copyWith({
    String? name,
    num? price,
    Clinic? clinic,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? id,
    String? error,
    bool? allowCycloplegicRefraction,
  }) {
    return SaveReason(
      name: name ?? this.name,
      price: price ?? this.price,
      allowCycloplegicRefraction:
          allowCycloplegicRefraction ?? this.allowCycloplegicRefraction,
      clinic: clinic ?? this.clinic,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      id: id ?? this.id,
      error: error ?? this.error,
    );
  }
}
