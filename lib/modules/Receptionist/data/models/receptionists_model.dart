import '../../../Branch/data/model/branches_model.dart';

class ReceptionistsModel {
  ReceptionistsModel({
    required this.receptionists,
    this.total,
    this.totalPages,
  });

  List<Receptionist> receptionists;
  num? total;
  num? totalPages;

  factory ReceptionistsModel.fromJson(Map<String, dynamic> json) {
    return ReceptionistsModel(
      receptionists: json["receptionists"] == null ? [] : List<Receptionist>.from(json["receptionists"]!.map((x) => Receptionist.fromJson(x))),
      total: json["total"],
      totalPages: json["totalPages"],
    );
  }

  Map<String, dynamic> toJson() => {
        "receptionists": receptionists.map((x) => x.toJson()).toList(),
        "total": total,
        "totalPages": totalPages,
      };
}

class Receptionist {
  Receptionist({
    this.name,
    this.image,
    this.password,
    this.phone,
    this.birthDate,
    this.branch,
    this.branchId,
    this.isActive,
    this.capabilities,
    this.createdAt,
    this.updatedAt,
    this.id,
    this.error,
  });

  String? name;
  String? image;
  String? password;
  String? phone;
  DateTime? birthDate;
  Branch? branch;
  String? branchId;
  bool? isActive;
  List<dynamic>? capabilities;
  DateTime? createdAt;
  DateTime? updatedAt;
  String? id;
  String? error;

  factory Receptionist.fromJson(Map<String, dynamic> json) {
    return Receptionist(
      name: json["name"],
      image: json["image"],
      password: json["password"],
      phone: json["phone"],
      birthDate: DateTime.tryParse(json["birthDate"] ?? ""),
      branch: json["branch"] == null ? null : Branch.fromJson(json["branch"]),
      isActive: json["isActive"],
      capabilities: json["capabilities"] == null ? [] : List<dynamic>.from(json["capabilities"]!.map((x) => x)),
      createdAt: DateTime.tryParse(json["createdAt"] ?? ""),
      updatedAt: DateTime.tryParse(json["updatedAt"] ?? ""),
      id: json["id"],
      error: json["error"],
    );
  }

  Map<String, dynamic> toJson() => {
        "name": name,
        "image": image,
        "password": password,
        "phone": phone,
        "birthDate": birthDate?.toIso8601String(),
        "branch": branchId,
        "isActive": isActive,
        "capabilities": capabilities?.map((x) => x).toList(),
        "createdAt": createdAt?.toIso8601String(),
        "updatedAt": updatedAt?.toIso8601String(),
        "id": id,
        "error": error,
      };
}
