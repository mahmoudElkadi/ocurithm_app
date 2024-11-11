import 'package:ocurithm/modules/Examination%20Type/data/model/examination_type_model.dart';
import 'package:ocurithm/modules/Payment%20Methods/data/model/payment_method_model.dart';

import '../../../Branch/data/model/branches_model.dart';
import '../../../Doctor/data/model/doctor_model.dart';
import '../../../Patient/data/model/patients_model.dart';

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
  ExaminationType? examinationType;
  DateTime? datetime;
  PaymentMethod? paymentMethod;
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
      examinationType: json["examinationType"] == null ? null : ExaminationType.fromJson(json["examinationType"]),
      datetime: DateTime.tryParse(json["datetime"] ?? ""),
      paymentMethod: json["paymentMethod"] == null ? null : PaymentMethod.fromJson(json["paymentMethod"]),
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
