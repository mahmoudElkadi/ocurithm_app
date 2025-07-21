import 'dart:developer';

import '../../../Branch/data/model/branches_model.dart';
import '../../../Clinics/data/model/clinics_model.dart';
import '../../../Doctor/data/model/doctor_model.dart';
import '../../../Examination Type/data/model/examination_type_model.dart';
import '../../../Patient/data/model/patients_model.dart';
import '../../../Payment Methods/data/model/payment_method_model.dart';

class AppointmentModel {
  AppointmentModel({
    required this.appointments,
    required this.total,
    required this.totalPages,
    required this.error,
  });

  List<Appointment> appointments;
  num? total;
  num? totalPages;
  String? error;

  factory AppointmentModel.fromJson(Map<String, dynamic> json) {
    return AppointmentModel(
      appointments: json["appointments"] == null
          ? []
          : List<Appointment>.from(
              json["appointments"]!.map((x) => Appointment.fromJson(x))),
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
    required this.clinic,
    required this.patient,
    required this.branch,
    required this.doctor,
    required this.examinationType,
    required this.datetime,
    required this.paymentMethod,
    required this.status,
    required this.note,
    required this.price,
    required this.createBy,
    required this.createdAt,
    required this.updatedAt,
    required this.id,
    this.error,
  });

  Clinic? clinic;
  Patient? patient;
  Branch? branch;
  Doctor? doctor;
  ExaminationType? examinationType;
  DateTime? datetime;
  PaymentMethod? paymentMethod;
  String? status;
  String? note;
  String? error;
  num? price;
  dynamic createBy;
  DateTime? createdAt;
  DateTime? updatedAt;
  String? id;

  factory Appointment.fromJson(Map<String, dynamic> json) {
    try {
      return Appointment(
        clinic: json["clinic"] == null ? null : Clinic.fromJson(json["clinic"]),
        patient:
            json["patient"] == null ? null : Patient.fromJson(json["patient"]),
        branch: json["branch"] == null ? null : Branch.fromJson(json["branch"]),
        doctor: json["doctor"] == null ? null : Doctor.fromJson(json["doctor"]),
        examinationType: json["examinationType"] == null
            ? null
            : ExaminationType.fromJson(json["examinationType"]),
        datetime: json["datetime"] == null
            ? null
            : DateTime.tryParse(json["datetime"])!.toLocal(),
        paymentMethod: json["paymentMethod"] == null
            ? null
            : PaymentMethod.fromJson(json["paymentMethod"]),
        status: json["status"],
        note: json["note"],
        error: json["error"],
        price: json["price"],
        createBy: json["createBy"],
        createdAt: DateTime.tryParse(json["createdAt"] ?? ""),
        updatedAt: DateTime.tryParse(json["updatedAt"] ?? ""),
        id: json["id"],
      );
    } catch (e) {
      log(e.toString());
      throw e;
    }
  }

  Map<String, dynamic> toJson() => {
        "clinic": clinic?.toJson(),
        "patient": patient?.toJson(),
        "branch": branch?.toJson(),
        "doctor": doctor?.toJson(),
        "examinationType": examinationType?.toJson(),
        "datetime": datetime?.toIso8601String(),
        "paymentMethod": paymentMethod?.toJson(),
        "status": status,
        "note": note,
        "price": price,
        "createBy": createBy,
        "createdAt": createdAt?.toIso8601String(),
        "updatedAt": updatedAt?.toIso8601String(),
        "id": id,
      };
}

class AppointmentClinic {
  AppointmentClinic({
    required this.name,
    required this.id,
  });

  String? name;
  String? id;

  factory AppointmentClinic.fromJson(Map<String, dynamic> json) {
    return AppointmentClinic(
      name: json["name"],
      id: json["id"],
    );
  }

  Map<String, dynamic> toJson() => {
        "name": name,
        "id": id,
      };
}

class BranchElement {
  BranchElement({
    required this.branch,
    required this.availableFrom,
    required this.availableTo,
    required this.availableDays,
    required this.id,
    required this.branchId,
  });

  BranchBranch? branch;
  String? availableFrom;
  String? availableTo;
  List<String> availableDays;
  String? id;
  String? branchId;

  factory BranchElement.fromJson(Map<String, dynamic> json) {
    return BranchElement(
      branch:
          json["branch"] == null ? null : BranchBranch.fromJson(json["branch"]),
      availableFrom: json["availableFrom"],
      availableTo: json["availableTo"],
      availableDays: json["availableDays"] == null
          ? []
          : List<String>.from(json["availableDays"]!.map((x) => x)),
      id: json["_id"],
      branchId: json["id"],
    );
  }

  Map<String, dynamic> toJson() => {
        "branch": branch?.toJson(),
        "availableFrom": availableFrom,
        "availableTo": availableTo,
        "availableDays": availableDays.map((x) => x).toList(),
        "_id": id,
        "id": branchId,
      };
}

class BranchBranch {
  BranchBranch({
    required this.clinic,
    required this.code,
    required this.name,
    required this.address,
    required this.phone,
    required this.openTime,
    required this.closeTime,
    required this.workDays,
    required this.createdAt,
    required this.updatedAt,
    required this.id,
  });

  String? clinic;
  String? code;
  String? name;
  String? address;
  String? phone;
  String? openTime;
  String? closeTime;
  List<String> workDays;
  DateTime? createdAt;
  DateTime? updatedAt;
  String? id;

  factory BranchBranch.fromJson(Map<String, dynamic> json) {
    return BranchBranch(
      clinic: json["clinic"],
      code: json["code"],
      name: json["name"],
      address: json["address"],
      phone: json["phone"],
      openTime: json["openTime"],
      closeTime: json["closeTime"],
      workDays: json["workDays"] == null
          ? []
          : List<String>.from(json["workDays"]!.map((x) => x)),
      createdAt: DateTime.tryParse(json["createdAt"] ?? ""),
      updatedAt: DateTime.tryParse(json["updatedAt"] ?? ""),
      id: json["id"],
    );
  }

  Map<String, dynamic> toJson() => {
        "clinic": clinic,
        "code": code,
        "name": name,
        "address": address,
        "phone": phone,
        "openTime": openTime,
        "closeTime": closeTime,
        "workDays": workDays.map((x) => x).toList(),
        "createdAt": createdAt?.toIso8601String(),
        "updatedAt": updatedAt?.toIso8601String(),
        "id": id,
      };
}

class DoctorClinic {
  DoctorClinic({
    required this.name,
    required this.description,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
    required this.id,
  });

  String? name;
  String? description;
  bool? isActive;
  DateTime? createdAt;
  DateTime? updatedAt;
  String? id;

  factory DoctorClinic.fromJson(Map<String, dynamic> json) {
    return DoctorClinic(
      name: json["name"],
      description: json["description"],
      isActive: json["isActive"],
      createdAt: DateTime.tryParse(json["createdAt"] ?? ""),
      updatedAt: DateTime.tryParse(json["updatedAt"] ?? ""),
      id: json["id"],
    );
  }

  Map<String, dynamic> toJson() => {
        "name": name,
        "description": description,
        "isActive": isActive,
        "createdAt": createdAt?.toIso8601String(),
        "updatedAt": updatedAt?.toIso8601String(),
        "id": id,
      };
}
