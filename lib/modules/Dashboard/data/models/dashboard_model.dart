class DashboardModel {
  DashboardModel({
    required this.examinationTypes,
    required this.branches,
    required this.doctors,
    required this.patients,
    required this.statuses,
    required this.count,
    required this.yesterday,
    required this.tomorrow,
    required this.error,
  });

  final List<ExaminationType> examinationTypes;
  final List<Branch> branches;
  final List<Branch> doctors;
  final List<Patient> patients;
  final List<Branch> statuses;
  final num? count;
  final num? yesterday;
  final num? tomorrow;
  final String? error;

  factory DashboardModel.fromJson(Map<String, dynamic> json) {
    return DashboardModel(
      examinationTypes:
          json["examinationTypes"] == null ? [] : List<ExaminationType>.from(json["examinationTypes"]!.map((x) => ExaminationType.fromJson(x))),
      branches: json["branches"] == null ? [] : List<Branch>.from(json["branches"]!.map((x) => Branch.fromJson(x))),
      doctors: json["doctors"] == null ? [] : List<Branch>.from(json["doctors"]!.map((x) => Branch.fromJson(x))),
      patients: json["patients"] == null ? [] : List<Patient>.from(json["patients"]!.map((x) => Patient.fromJson(x))),
      statuses: json["statuses"] == null ? [] : List<Branch>.from(json["statuses"]!.map((x) => Branch.fromJson(x))),
      count: json["count"],
      yesterday: json["yesterday"],
      tomorrow: json["tomorrow"],
      error: json["error"],
    );
  }

  Map<String, dynamic> toJson() => {
        "examinationTypes": examinationTypes.map((x) => x?.toJson()).toList(),
        "branches": branches.map((x) => x?.toJson()).toList(),
        "doctors": doctors.map((x) => x?.toJson()).toList(),
        "patients": patients.map((x) => x?.toJson()).toList(),
        "statuses": statuses.map((x) => x?.toJson()).toList(),
        "count": count,
        "yesterday": yesterday,
        "tomorrow": tomorrow,
      };
}

class Branch {
  Branch({
    required this.name,
    required this.count,
  });

  final String? name;
  final num? count;

  factory Branch.fromJson(Map<String, dynamic> json) {
    return Branch(
      name: json["name"],
      count: json["count"],
    );
  }

  Map<String, dynamic> toJson() => {
        "name": name,
        "count": count,
      };
}

class ExaminationType {
  ExaminationType({
    required this.name,
    required this.duration,
    required this.count,
  });

  final String? name;
  final num? duration;
  final num? count;

  factory ExaminationType.fromJson(Map<String, dynamic> json) {
    return ExaminationType(
      name: json["name"],
      duration: json["duration"],
      count: json["count"],
    );
  }

  Map<String, dynamic> toJson() => {
        "name": name,
        "duration": duration,
        "count": count,
      };
}

class Patient {
  Patient({
    required this.name,
    required this.examinationType,
    required this.count,
  });

  final String? name;
  final String? examinationType;
  final num? count;

  factory Patient.fromJson(Map<String, dynamic> json) {
    return Patient(
      name: json["name"],
      examinationType: json["examinationType"],
      count: json["count"],
    );
  }

  Map<String, dynamic> toJson() => {
        "name": name,
        "examinationType": examinationType,
        "count": count,
      };
}
