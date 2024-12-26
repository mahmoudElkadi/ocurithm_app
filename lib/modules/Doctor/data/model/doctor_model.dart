import '../../../Branch/data/model/branches_model.dart';
import '../../../Clinics/data/model/clinics_model.dart';

class DoctorModel {
  DoctorModel({
    required this.doctors,
    this.total,
    this.totalPages,
    this.error,
  });

  List<Doctor> doctors;
  num? total;
  num? totalPages;
  String? error;

  factory DoctorModel.fromJson(Map<String, dynamic> json) {
    return DoctorModel(
      doctors: json["doctors"] == null ? [] : List<Doctor>.from(json["doctors"]!.map((x) => Doctor.fromJson(x))),
      total: json["total"],
      totalPages: json["totalPages"],
      error: json["error"],
    );
  }

  Map<String, dynamic> toJson() => {
        "doctors": doctors.map((x) => x?.toJson()).toList(),
        "total": total,
        "totalPages": totalPages,
        "error": error,
      };
}

class Doctor {
  Doctor({
    this.name,
    this.image,
    this.phone,
    this.birthDate,
    this.qualifications,
    this.branch,
    this.isActive,
    this.capabilities,
    this.createdAt,
    this.updatedAt,
    this.clinic,
    this.id,
    this.error,
    this.password,
  });

  String? name;
  String? image;
  String? phone;
  Clinic? clinic;
  String? password;
  DateTime? birthDate;
  String? qualifications;
  List<Branch>? branch;
  bool? isActive;
  List<dynamic>? capabilities;
  DateTime? createdAt;
  DateTime? updatedAt;

  String? id;
  String? error;

  factory Doctor.fromJson(Map<String, dynamic> json) {
    return Doctor(
      name: json["name"],
      image: json["image"],
      password: json["password"],
      phone: json["phone"],
      birthDate: DateTime.tryParse(json["birthDate"] ?? ""),
      qualifications: json["qualifications"],
      branch: json["branch"] == null ? [] : List<Branch>.from(json["branch"]!.map((x) => Branch.fromJson(x))),
      isActive: json["isActive"],
      capabilities: json["capabilities"] == null ? [] : List<dynamic>.from(json["capabilities"]!.map((x) => x)),
      createdAt: DateTime.tryParse(json["createdAt"] ?? ""),
      updatedAt: DateTime.tryParse(json["updatedAt"] ?? ""),
      clinic: json["clinic"] == null ? null : Clinic.fromJson(json["clinic"]),
      id: json["id"],
      error: json["error"],
    );
  }

  Map<String, dynamic> toJson() => {
        "name": name,
        "image": image,
        "phone": phone,
        "birthDate": birthDate?.toIso8601String(),
        "qualifications": qualifications,
        "isActive": isActive,
        "capabilities": capabilities?.map((x) => x).toList(),
        "createdAt": createdAt?.toIso8601String(),
        "updatedAt": updatedAt?.toIso8601String(),
        "id": id,
        "password": password,
        "clinic": clinic?.id,
        "error": error,
      };
}
