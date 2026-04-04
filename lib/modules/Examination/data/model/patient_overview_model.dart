class PatientOverviewModel {
  final PatientOverviewInfo? patient;
  final List<PatientAppointment> appointments;
  final List<dynamic> investigations;

  PatientOverviewModel({
    this.patient,
    this.appointments = const [],
    this.investigations = const [],
  });

  factory PatientOverviewModel.fromJson(Map<String, dynamic> json) {
    return PatientOverviewModel(
      patient: json['patient'] != null
          ? PatientOverviewInfo.fromJson(json['patient'])
          : null,
      appointments: json['appointments'] != null
          ? List<PatientAppointment>.from(
              json['appointments'].map((x) => PatientAppointment.fromJson(x)))
          : [],
      investigations: json['investigations'] ?? [],
    );
  }
}

class PatientOverviewInfo {
  final String? id;
  final String? name;
  final String? birthDate;
  final String? gender;
  final String? nationality;
  final String? nationalId;
  final String? phone;
  final String? email;
  final String? address;
  final String? branchName;
  final String? clinicName;

  PatientOverviewInfo({
    this.id,
    this.name,
    this.birthDate,
    this.gender,
    this.nationality,
    this.nationalId,
    this.phone,
    this.email,
    this.address,
    this.branchName,
    this.clinicName,
  });

  factory PatientOverviewInfo.fromJson(Map<String, dynamic> json) {
    return PatientOverviewInfo(
      id: json['id'],
      name: json['name'],
      birthDate: json['birthDate'],
      gender: json['gender'],
      nationality: json['nationality'],
      nationalId: json['nationalId'],
      phone: json['phone'],
      email: json['email'],
      address: json['address'],
      branchName: json['branchName'],
      clinicName: json['clinicName'],
    );
  }
}

class PatientAppointment {
  final String? id;
  final String? typeName;
  final String? status;
  final String? doctorName;
  final String? date;
  final String? branchName;
  final String? description;

  PatientAppointment({
    this.id,
    this.typeName,
    this.status,
    this.doctorName,
    this.date,
    this.branchName,
    this.description,
  });

  factory PatientAppointment.fromJson(Map<String, dynamic> json) {
    return PatientAppointment(
      id: json['id'],
      typeName: json['typeName'],
      status: json['status'],
      doctorName: json['doctorName'],
      date: json['date'],
      branchName: json['branchName'],
      description: json['description'],
    );
  }
}
