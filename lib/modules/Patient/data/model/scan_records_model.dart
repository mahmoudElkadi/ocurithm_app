/// Model for scan records response from the API
class ScanRecordsModel {
  final List<ScanRecord> scans;
  final int total;
  final int totalPages;
  final int currentPage;

  ScanRecordsModel({
    required this.scans,
    required this.total,
    required this.totalPages,
    required this.currentPage,
  });

  factory ScanRecordsModel.fromJson(Map<String, dynamic> json) {
    return ScanRecordsModel(
      scans: json["scans"] == null
          ? []
          : List<ScanRecord>.from(
              json["scans"]!.map((x) => ScanRecord.fromJson(x))),
      total: json["total"] ?? 0,
      totalPages: json["totalPages"] ?? 1,
      currentPage: json["currentPage"] ?? 1,
    );
  }
}

class ScanRecord {
  final String? id;
  final ScanPatient? patient;
  final ScanDoctor? doctor;
  final String? comment;
  final DateTime? scanDate;
  final List<ScanFile> files;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  ScanRecord({
    this.id,
    this.patient,
    this.doctor,
    this.comment,
    this.scanDate,
    this.files = const [],
    this.createdAt,
    this.updatedAt,
  });

  factory ScanRecord.fromJson(Map<String, dynamic> json) {
    return ScanRecord(
      id: json["id"] ?? json["_id"],
      patient: json["patient"] == null
          ? null
          : ScanPatient.fromJson(json["patient"]),
      doctor:
          json["doctor"] == null ? null : ScanDoctor.fromJson(json["doctor"]),
      comment: json["comment"],
      scanDate: json["scanDate"] != null
          ? DateTime.tryParse(json["scanDate"])?.toLocal()
          : null,
      files: json["files"] == null
          ? []
          : List<ScanFile>.from(
              json["files"]!.map((x) => ScanFile.fromJson(x))),
      createdAt: json["createdAt"] != null
          ? DateTime.tryParse(json["createdAt"])?.toLocal()
          : null,
      updatedAt: json["updatedAt"] != null
          ? DateTime.tryParse(json["updatedAt"])?.toLocal()
          : null,
    );
  }
}

class ScanPatient {
  final String? id;
  final String? name;
  final String? serialNumber;

  ScanPatient({this.id, this.name, this.serialNumber});

  factory ScanPatient.fromJson(Map<String, dynamic> json) {
    return ScanPatient(
      id: json["id"] ?? json["_id"],
      name: json["name"],
      serialNumber: json["serialNumber"],
    );
  }
}

class ScanDoctor {
  final String? id;
  final String? name;

  ScanDoctor({this.id, this.name});

  factory ScanDoctor.fromJson(Map<String, dynamic> json) {
    return ScanDoctor(
      id: json["id"] ?? json["_id"],
      name: json["name"],
    );
  }
}

class ScanFile {
  final String? key;
  final String? url;
  final DateTime? expiresAt;

  ScanFile({this.key, this.url, this.expiresAt});

  factory ScanFile.fromJson(Map<String, dynamic> json) {
    return ScanFile(
      key: json["key"],
      url: json["url"],
      expiresAt: json["expiresAt"] != null
          ? DateTime.tryParse(json["expiresAt"])?.toLocal()
          : null,
    );
  }
}
