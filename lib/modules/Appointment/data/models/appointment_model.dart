class AppointmentModel {
  AppointmentModel({
    required this.appointments,
    this.total,
    this.totalPages,
    this.error,
  });

  List<Appointment> appointments;
  num? total;
  num? totalPages;
  String? error;

  factory AppointmentModel.fromJson(Map<String, dynamic> json) {
    return AppointmentModel(
      appointments: json["appointments"] == null ? [] : List<Appointment>.from(json["appointments"]!.map((x) => Appointment.fromJson(x))),
      total: json["total"],
      totalPages: json["totalPages"],
      error: json["error"],
    );
  }

  Map<String, dynamic> toJson() => {
        "appointments": appointments.map((x) => x?.toJson()).toList(),
        "total": total,
        "totalPages": totalPages,
      };
}

class Appointment {
  Appointment({
    this.patient,
    this.error,
    this.branch,
    this.doctor,
    this.examinationType,
    this.datetime,
    this.paymentMethod,
    this.status,
    this.note,
    this.price,
    this.createBy,
    this.createdAt,
    this.updatedAt,
    this.id,
  });

  Patient? patient;
  Branch? branch;
  Doctor? doctor;
  Doctor? examinationType;
  DateTime? datetime;
  dynamic paymentMethod;
  String? status;
  String? note;
  num? price;
  String? createBy;
  DateTime? createdAt;
  DateTime? updatedAt;
  String? id;
  String? error;

  factory Appointment.fromJson(Map<String, dynamic> json) {
    return Appointment(
      patient: json["patient"] == null ? null : Patient.fromJson(json["patient"]),
      branch: json["branch"] == null ? null : Branch.fromJson(json["branch"]),
      doctor: json["doctor"] == null ? null : Doctor.fromJson(json["doctor"]),
      examinationType: json["examinationType"] == null ? null : Doctor.fromJson(json["examinationType"]),
      datetime: DateTime.tryParse(json["datetime"] ?? ""),
      paymentMethod: json["paymentMethod"],
      status: json["status"],
      note: json["note"],
      price: json["price"],
      createBy: json["createBy"],
      createdAt: DateTime.tryParse(json["createdAt"] ?? ""),
      updatedAt: DateTime.tryParse(json["updatedAt"] ?? ""),
      id: json["id"],
      error: json["error"],
    );
  }

  Map<String, dynamic> toJson() => {
        "patient": patient?.id,
        "branch": branch?.id,
        "doctor": doctor?.id,
        "examinationType": examinationType?.toJson(),
        "datetime": datetime?.toIso8601String(),
        "paymentMethod": paymentMethod,
        "status": status,
        "note": note,
        "price": price,
        "createBy": createBy,
        "createdAt": createdAt?.toIso8601String(),
        "updatedAt": updatedAt?.toIso8601String(),
        "id": id,
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

class Doctor {
  Doctor({
    this.name,
    this.id,
  });

  String? name;
  String? id;

  factory Doctor.fromJson(Map<String, dynamic> json) {
    return Doctor(
      name: json["name"],
      id: json["id"],
    );
  }

  Map<String, dynamic> toJson() => {
        "name": name,
        "id": id,
      };
}

class Patient {
  Patient({
    this.name,
    this.phone,
    this.id,
  });

  String? name;
  String? phone;
  String? id;

  factory Patient.fromJson(Map<String, dynamic> json) {
    return Patient(
      name: json["name"],
      phone: json["phone"],
      id: json["id"],
    );
  }

  Map<String, dynamic> toJson() => {
        "name": name,
        "phone": phone,
        "id": id,
      };
}
