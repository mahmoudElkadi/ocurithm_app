import 'package:ocurithm/modules/Patient/data/model/patients_model.dart';

class PatientExaminationModel {
  PatientExaminationModel({required this.examinations, this.error});

  final Examinations? examinations;
  final String? error;

  factory PatientExaminationModel.fromJson(Map<String, dynamic> json) {
    return PatientExaminationModel(
      examinations: json["examinations"] == null ? null : Examinations.fromJson(json["examinations"]),
      error: json["error"],
    );
  }

  Map<String, dynamic> toJson() => {
        "examinations": examinations?.toJson(),
      };
}

class Examinations {
  Examinations({
    required this.examinations,
    required this.total,
    required this.totalPages,
  });

  final List<Examination> examinations;
  final num? total;
  final dynamic totalPages;

  factory Examinations.fromJson(Map<String, dynamic> json) {
    return Examinations(
      examinations: json["examinations"] == null ? [] : List<Examination>.from(json["examinations"]!.map((x) => Examination.fromJson(x))),
      total: json["total"],
      totalPages: json["totalPages"],
    );
  }

  Map<String, dynamic> toJson() => {
        "examinations": examinations.map((x) => x?.toJson()).toList(),
        "total": total,
        "totalPages": totalPages,
      };
}

class Examination {
  Examination({
    required this.clinic,
    required this.patient,
    required this.appointment,
    required this.type,
    required this.measurements,
    required this.createdAt,
    required this.updatedAt,
    required this.history,
    required this.complain,
    required this.id,
  });

  final String? clinic;
  final Patient? patient;
  final Appointment? appointment;
  final Type? type;
  final List<String?> measurements;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final String? history;
  final String? complain;
  final String? id;

  factory Examination.fromJson(Map<String, dynamic> json) {
    return Examination(
      clinic: json["clinic"],
      patient: json["patient"] == null ? null : Patient.fromJson(json["patient"]),
      appointment: json["appointment"] == null ? null : Appointment.fromJson(json["appointment"]),
      type: json["type"] == null ? null : Type.fromJson(json["type"]),
      measurements: json["measurements"] == null ? [] : List<String?>.from(json["measurements"]!.map((x) => x)),
      createdAt: DateTime.tryParse(json["createdAt"] ?? "")?.toLocal(),
      updatedAt: DateTime.tryParse(json["updatedAt"] ?? ""),
      history: json["history"],
      complain: json["complain"],
      id: json["id"],
    );
  }

  Map<String, dynamic> toJson() => {
        "clinic": clinic,
        "patient": patient?.toJson(),
        "appointment": appointment?.toJson(),
        "type": type?.toJson(),
        "measurements": measurements.map((x) => x).toList(),
        "createdAt": createdAt?.toIso8601String(),
        "updatedAt": updatedAt?.toIso8601String(),
        "history": history,
        "complain": complain,
        "id": id,
      };
}

class Appointment {
  Appointment({
    required this.datetime,
    required this.id,
  });

  final DateTime? datetime;
  final String? id;

  factory Appointment.fromJson(Map<String, dynamic> json) {
    return Appointment(
      datetime: DateTime.tryParse(json["datetime"] ?? ""),
      id: json["id"],
    );
  }

  Map<String, dynamic> toJson() => {
        "datetime": datetime?.toIso8601String(),
        "id": id,
      };
}

class Type {
  Type({
    required this.name,
    required this.id,
  });

  final String? name;
  final String? id;

  factory Type.fromJson(Map<String, dynamic> json) {
    return Type(
      name: json["name"],
      id: json["id"],
    );
  }

  Map<String, dynamic> toJson() => {
        "name": name,
        "id": id,
      };
}
