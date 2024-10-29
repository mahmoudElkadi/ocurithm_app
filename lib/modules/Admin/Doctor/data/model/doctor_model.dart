class DoctorModel {
  DoctorModel({
    this.doctors,
    this.total,
    this.totalPages,
  });

  List<Doctor>? doctors;
  num? total;
  num? totalPages;

  factory DoctorModel.fromJson(Map<String, dynamic> json) {
    return DoctorModel(
      doctors: json["doctors"] == null ? [] : List<Doctor>.from(json["doctors"]!.map((x) => Doctor.fromJson(x))),
      total: json["total"],
      totalPages: json["totalPages"],
    );
  }

  Map<String, dynamic> toJson() => {
        "doctors": doctors?.map((x) => x?.toJson()).toList(),
        "total": total,
        "totalPages": totalPages,
      };
}

class Doctor {
  Doctor({
    this.name,
    this.image,
    this.phone,
    this.birthDate,
    this.password,
    this.qualifications,
    this.branch,
    this.isActive,
    this.capabilities,
    this.createdAt,
    this.updatedAt,
    this.id,
    this.error,
    this.branchId,
  });

  String? name;
  String? image;
  String? phone;
  String? error;
  DateTime? birthDate;
  String? password;
  String? qualifications;
  bool? isActive;
  List<dynamic>? capabilities;
  DateTime? createdAt;
  DateTime? updatedAt;
  String? id;
  String? branchId;
  Branch? branch;

  factory Doctor.fromJson(Map<String, dynamic> json) {
    return Doctor(
      name: json["name"],
      error: json["error"],
      image: json["image"],
      phone: json["phone"],
      birthDate: DateTime.tryParse(json["birthDate"] ?? ""),
      password: json["password"],
      qualifications: json["qualifications"],
      isActive: json["isActive"],
      capabilities: json["capabilities"] == null ? [] : List<dynamic>.from(json["capabilities"]!.map((x) => x)),
      createdAt: DateTime.tryParse(json["createdAt"] ?? ""),
      updatedAt: DateTime.tryParse(json["updatedAt"] ?? ""),
      id: json["id"],
      branch: json["branch"] == null ? null : Branch.fromJson(json["branch"]),
    );
  }

  Map<String, dynamic> toJson() => {
        "name": name,
        "image": image,
        "phone": phone,
        "birthDate": birthDate?.toIso8601String(),
        "password": password,
        "qualifications": qualifications,
        "isActive": isActive,
        "capabilities": capabilities?.map((x) => x).toList(),
        "createdAt": createdAt?.toIso8601String(),
        "updatedAt": updatedAt?.toIso8601String(),
        "id": id,
        "branch": branch?.toJson(),
        "branchId": branchId,
      };
}

class Branch {
  Branch({
    this.code,
    this.name,
    this.id,
  });

  String? code;
  String? name;
  String? id;

  factory Branch.fromJson(Map<String, dynamic> json) {
    return Branch(
      code: json["code"],
      name: json["name"],
      id: json["id"],
    );
  }

  Map<String, dynamic> toJson() => {
        "code": code,
        "name": name,
        "id": id,
      };
}
