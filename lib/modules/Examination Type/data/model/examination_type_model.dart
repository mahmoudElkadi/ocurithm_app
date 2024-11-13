class ExaminationTypesModel {
  ExaminationTypesModel({
    this.examinationTypes,
    this.total,
    this.totalPages,
    this.error,
  });

  List<ExaminationType>? examinationTypes;
  num? total;
  num? totalPages;
  String? error;

  factory ExaminationTypesModel.fromJson(Map<String, dynamic> json) {
    return ExaminationTypesModel(
      examinationTypes:
          json["examinationTypes"] == null ? [] : List<ExaminationType>.from(json["examinationTypes"]!.map((x) => ExaminationType.fromJson(x))),
      total: json["total"],
      totalPages: json["totalPages"],
      error: json["error"],
    );
  }

  Map<String, dynamic> toJson() => {
        "examinationTypes": examinationTypes?.map((x) => x?.toJson()).toList(),
        "total": total,
        "totalPages": totalPages,
      };
}

class ExaminationType {
  ExaminationType({
    this.name,
    this.price,
    this.isActive,
    this.createdAt,
    this.updatedAt,
    this.id,
    this.duration,
    this.error,
  });

  String? name;
  num? price;
  bool? isActive;
  DateTime? createdAt;
  DateTime? updatedAt;
  String? id;
  num? duration;
  String? error;

  factory ExaminationType.fromJson(Map<String, dynamic> json) {
    return ExaminationType(
      name: json["name"],
      price: json["price"],
      isActive: json["isActive"],
      createdAt: DateTime.tryParse(json["createdAt"] ?? ""),
      updatedAt: DateTime.tryParse(json["updatedAt"] ?? ""),
      id: json["id"],
      duration: json["duration"],
      error: json["error"],
    );
  }

  Map<String, dynamic> toJson() => {
        "name": name,
        "price": price,
        "duration": duration,
      };
}
