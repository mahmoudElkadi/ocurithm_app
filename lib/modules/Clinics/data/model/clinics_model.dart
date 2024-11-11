class ClinicsModel {
  ClinicsModel({
    required this.clinics,
    this.total,
    this.totalPages,
    this.error,
  });

  List<Clinic> clinics;
  num? total;
  num? totalPages;
  String? error;

  factory ClinicsModel.fromJson(Map<String, dynamic> json) {
    return ClinicsModel(
      clinics: json["clinics"] == null ? [] : List<Clinic>.from(json["clinics"]!.map((x) => Clinic.fromJson(x))),
      total: json["total"],
      totalPages: json["totalPages"],
      error: json["error"],
    );
  }

  Map<String, dynamic> toJson() => {
        "clinics": clinics.map((x) => x?.toJson()).toList(),
        "total": total,
        "totalPages": totalPages,
        "error": error,
      };
}

class Clinic {
  Clinic({
    this.name,
    this.description,
    this.isActive,
    this.createdAt,
    this.updatedAt,
    this.id,
    this.error,
  });

  String? name;
  String? description;
  bool? isActive;
  DateTime? createdAt;
  DateTime? updatedAt;
  String? id;
  String? error;

  factory Clinic.fromJson(Map<String, dynamic> json) {
    return Clinic(
      name: json["name"],
      description: json["description"],
      isActive: json["isActive"],
      createdAt: DateTime.tryParse(json["createdAt"] ?? ""),
      updatedAt: DateTime.tryParse(json["updatedAt"] ?? ""),
      id: json["id"],
      error: json["error"],
    );
  }

  Map<String, dynamic> toJson() => {
        "name": name,
        "description": description,
        "id": id,
        "error": error,
      };
}
