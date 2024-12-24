import '../../../Branch/data/model/branches_model.dart';
import '../../../Clinics/data/model/clinics_model.dart';

class PatientModel {
  PatientModel({
    required this.patients,
    this.total,
    this.totalPages,
  });

  List<Patient> patients;
  num? total;
  num? totalPages;

  factory PatientModel.fromJson(Map<String, dynamic> json) {
    return PatientModel(
      patients: json["patients"] == null ? [] : List<Patient>.from(json["patients"]!.map((x) => Patient.fromJson(x))),
      total: json["total"],
      totalPages: json["totalPages"],
    );
  }

  Map<String, dynamic> toJson() => {
        "patients": patients.map((x) => x.toJson()).toList(),
        "total": total,
        "totalPages": totalPages,
      };
}

class Patient {
  Patient({
    this.error,
    this.name,
    this.birthDate,
    this.gender,
    this.nationality,
    this.nationalId,
    this.phone,
    this.email,
    this.address,
    this.username,
    this.password,
    this.branch,
    this.serialNumber,
    this.isActive,
    this.capabilities,
    this.createdAt,
    this.updatedAt,
    this.clinic,
    this.id,
    this.branchId,
  });

  String? error;
  String? name;
  DateTime? birthDate;
  String? gender;
  String? nationality;
  String? nationalId;
  String? phone;
  String? email;
  Clinic? clinic;
  String? address;
  String? username;
  String? password;
  Branch? branch;
  String? serialNumber;
  bool? isActive;
  List<dynamic>? capabilities;
  DateTime? createdAt;
  DateTime? updatedAt;
  String? id;
  String? branchId;

  factory Patient.fromJson(Map<String, dynamic> json) {
    return Patient(
      error: json["error"],
      name: json["name"],
      birthDate: DateTime.tryParse(json["birthDate"] ?? ""),
      gender: json["gender"],
      nationality: json["nationality"],
      nationalId: json["nationalID"],
      phone: json["phone"],
      email: json["email"],
      address: json["address"],
      username: json["username"],
      password: json["password"],
      clinic: json["clinic"] == null ? null : Clinic.fromJson(json["clinic"]),
      branch: json["branch"] == null ? null : Branch.fromJson(json["branch"]),
      serialNumber: json["serialNumber"],
      isActive: json["isActive"],
      capabilities: json["capabilities"] == null ? [] : List<dynamic>.from(json["capabilities"]!.map((x) => x)),
      createdAt: DateTime.tryParse(json["createdAt"] ?? ""),
      updatedAt: DateTime.tryParse(json["updatedAt"] ?? ""),
      id: json["id"],
    );
  }

  Map<String, dynamic> toJson() => {
        "name": name,
        "birthDate": birthDate?.toIso8601String(),
        "gender": gender,
        "nationality": nationality,
        "nationalID": nationalId,
        "phone": phone,
        "email": email,
        "address": address,
        "username": username,
        "password": password,
        "branch": branch?.id,
        "serialNumber": serialNumber,
        "clinic": clinic?.id,
        "isActive": isActive,
        "capabilities": capabilities?.map((x) => x).toList(),
        "createdAt": createdAt?.toIso8601String(),
        "updatedAt": updatedAt?.toIso8601String(),
        "id": id,
      };
}
