class MakeAppointmentModel {
  MakeAppointmentModel({
    this.patient,
    this.branch,
    this.doctor,
    this.examinationType,
    this.datetime,
    this.paymentMethod,
    this.status,
    this.createBy,
    this.note,
    this.clinic,
  });

  String? patient;
  String? branch;
  String? doctor;
  String? examinationType;
  DateTime? datetime;
  String? paymentMethod;
  String? status;
  String? createBy;
  String? note;
  String? clinic;

  factory MakeAppointmentModel.fromJson(Map<String, dynamic> json) {
    return MakeAppointmentModel(
      patient: json["patient"],
      branch: json["branch"],
      clinic: json["clinic"],
      doctor: json["doctor"],
      examinationType: json["examinationType"],
      datetime: DateTime.tryParse(json["datetime"] ?? ""),
      paymentMethod: json["paymentMethod"],
      status: json["status"],
      createBy: json["createBy"],
      note: json["note"],
    );
  }

  Map<String, dynamic> toJson() => {
        "patient": patient,
        "branch": branch,
        "doctor": doctor,
        "examinationType": examinationType,
        "datetime": datetime?.toIso8601String(),
        "paymentMethod": paymentMethod,
        "status": status,
        "createBy": createBy,
        "note": note,
        "clinic": clinic,
      };
}
