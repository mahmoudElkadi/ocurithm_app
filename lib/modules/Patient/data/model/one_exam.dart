import 'package:ocurithm/modules/Patient/data/model/patients_model.dart';

class ExaminationModel {
  ExaminationModel({
    required this.examination,
    required this.error,
  });

  final Examination? examination;
  final String? error;

  factory ExaminationModel.fromJson(Map<String, dynamic> json) {
    return ExaminationModel(
      examination: json["examination"] == null ? null : Examination.fromJson(json["examination"]),
      error: json["error"],
    );
  }

  Map<String, dynamic> toJson() => {
        "examination": examination?.toJson(),
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
  final List<Measurement> measurements;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final Complain? history;
  final Complain? complain;
  final String? id;

  factory Examination.fromJson(Map<String, dynamic> json) {
    return Examination(
      clinic: json["clinic"],
      patient: json["patient"] == null ? null : Patient.fromJson(json["patient"]),
      appointment: json["appointment"] == null ? null : Appointment.fromJson(json["appointment"]),
      type: json["type"] == null ? null : Type.fromJson(json["type"]),
      measurements: json["measurements"] == null ? [] : List<Measurement>.from(json["measurements"]!.map((x) => Measurement.fromJson(x))),
      createdAt: DateTime.tryParse(json["createdAt"] ?? ""),
      updatedAt: DateTime.tryParse(json["updatedAt"] ?? ""),
      history: json["history"] == null ? null : Complain.fromJson(json["history"]),
      complain: json["complain"] == null ? null : Complain.fromJson(json["complain"]),
      id: json["id"],
    );
  }

  Map<String, dynamic> toJson() => {
        "clinic": clinic,
        "patient": patient?.toJson(),
        "appointment": appointment?.toJson(),
        "type": type?.toJson(),
        "measurements": measurements.map((x) => x?.toJson()).toList(),
        "createdAt": createdAt?.toIso8601String(),
        "updatedAt": updatedAt?.toIso8601String(),
        "history": history?.toJson(),
        "complain": complain?.toJson(),
        "id": id,
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
  });

  final String? clinic;
  final String? patient;
  final String? branch;
  final String? doctor;
  final String? examinationType;
  final DateTime? datetime;
  final String? paymentMethod;
  final String? status;
  final String? note;
  final num? price;
  final dynamic createBy;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final String? id;

  factory Appointment.fromJson(Map<String, dynamic> json) {
    return Appointment(
      clinic: json["clinic"],
      patient: json["patient"],
      branch: json["branch"],
      doctor: json["doctor"],
      examinationType: json["examinationType"],
      datetime: DateTime.tryParse(json["datetime"] ?? ""),
      paymentMethod: json["paymentMethod"],
      status: json["status"],
      note: json["note"],
      price: json["price"],
      createBy: json["createBy"],
      createdAt: DateTime.tryParse(json["createdAt"] ?? ""),
      updatedAt: DateTime.tryParse(json["updatedAt"] ?? ""),
      id: json["id"],
    );
  }

  Map<String, dynamic> toJson() => {
        "clinic": clinic,
        "patient": patient,
        "branch": branch,
        "doctor": doctor,
        "examinationType": examinationType,
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

class Complain {
  Complain({
    required this.examination,
    required this.complain,
    required this.createdAt,
    required this.updatedAt,
    required this.id,
    required this.history,
  });

  final String? examination;
  final String? complain;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final String? id;
  final String? history;

  factory Complain.fromJson(Map<String, dynamic> json) {
    return Complain(
      examination: json["examination"],
      complain: json["complain"],
      createdAt: DateTime.tryParse(json["createdAt"] ?? ""),
      updatedAt: DateTime.tryParse(json["updatedAt"] ?? ""),
      id: json["id"],
      history: json["history"],
    );
  }

  Map<String, dynamic> toJson() => {
        "examination": examination,
        "complain": complain,
        "createdAt": createdAt?.toIso8601String(),
        "updatedAt": updatedAt?.toIso8601String(),
        "id": id,
        "history": history,
      };
}

class Measurement {
  Measurement({
    required this.eye,
    required this.examination,
    required this.autorefSpherical,
    required this.autorefCylindrical,
    required this.autorefAxis,
    required this.ucva,
    required this.bcva,
    required this.refinedRefractionSpherical,
    required this.refinedRefractionCylindrical,
    required this.refinedRefractionAxis,
    required this.iop,
    required this.meansOfMeasurement,
    required this.acquireAnotherIopMeasurement,
    required this.pupilsShape,
    required this.pupilsLightReflexTest,
    required this.pupilsNearReflexTest,
    required this.pupilsSwingingFlashLightTest,
    required this.pupilsOtherDisorders,
    required this.eyelidPtosis,
    required this.eyelidLagophthalmos,
    required this.palpableLymphNodes,
    required this.palpableTemporalArtery,
    required this.exophthalmometry,
    required this.cornea,
    required this.anteriorChamber,
    required this.iris,
    required this.lens,
    required this.anteriorVitreous,
    required this.fundusOpticDisc,
    required this.fundusMacula,
    required this.fundusVessels,
    required this.fundusPeriphery,
    required this.lids,
    required this.lashes,
    required this.sclera,
    required this.conjunctiva,
    required this.lacrimalSystem,
    required this.topLeft,
    required this.topRight,
    required this.bottomLeft,
    required this.bottomRight,
    required this.createdAt,
    required this.updatedAt,
    required this.id,
  });

  final String? eye;
  final String? examination;
  final String? autorefSpherical;
  final String? autorefCylindrical;
  final String? autorefAxis;
  final String? ucva;
  final String? bcva;
  final String? refinedRefractionSpherical;
  final String? refinedRefractionCylindrical;
  final String? refinedRefractionAxis;
  final dynamic iop;
  final dynamic meansOfMeasurement;
  final dynamic acquireAnotherIopMeasurement;
  final String? pupilsShape;
  final String? pupilsLightReflexTest;
  final String? pupilsNearReflexTest;
  final String? pupilsSwingingFlashLightTest;
  final String? pupilsOtherDisorders;
  final String? eyelidPtosis;
  final String? eyelidLagophthalmos;
  final String? palpableLymphNodes;
  final String? palpableTemporalArtery;
  final String? exophthalmometry;
  final dynamic cornea;
  final String? anteriorChamber;
  final String? iris;
  final String? lens;
  final String? anteriorVitreous;
  final String? fundusOpticDisc;
  final String? fundusMacula;
  final String? fundusVessels;
  final String? fundusPeriphery;
  final String? lids;
  final String? lashes;
  final String? sclera;
  final String? conjunctiva;
  final String? lacrimalSystem;
  final num? topLeft;
  final num? topRight;
  final num? bottomLeft;
  final num? bottomRight;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final String? id;

  factory Measurement.fromJson(Map<String, dynamic> json) {
    return Measurement(
      eye: json["eye"],
      examination: json["examination"],
      autorefSpherical: json["autorefSpherical"],
      autorefCylindrical: json["autorefCylindrical"],
      autorefAxis: json["autorefAxis"],
      ucva: json["ucva"],
      bcva: json["bcva"],
      refinedRefractionSpherical: json["refinedRefractionSpherical"],
      refinedRefractionCylindrical: json["refinedRefractionCylindrical"],
      refinedRefractionAxis: json["refinedRefractionAxis"],
      iop: json["iop"],
      meansOfMeasurement: json["meansOfMeasurement"],
      acquireAnotherIopMeasurement: json["acquireAnotherIOPMeasurement"],
      pupilsShape: json["pupilsShape"],
      pupilsLightReflexTest: json["pupilsLightReflexTest"],
      pupilsNearReflexTest: json["pupilsNearReflexTest"],
      pupilsSwingingFlashLightTest: json["pupilsSwingingFlashLightTest"],
      pupilsOtherDisorders: json["pupilsOtherDisorders"],
      eyelidPtosis: json["eyelidPtosis"],
      eyelidLagophthalmos: json["eyelidLagophthalmos"],
      palpableLymphNodes: json["palpableLymphNodes"],
      palpableTemporalArtery: json["palpableTemporalArtery"],
      exophthalmometry: json["exophthalmometry"],
      cornea: json["cornea"],
      anteriorChamber: json["anteriorChamber"],
      iris: json["iris"],
      lens: json["lens"],
      anteriorVitreous: json["anteriorVitreous"],
      fundusOpticDisc: json["fundusOpticDisc"],
      fundusMacula: json["fundusMacula"],
      fundusVessels: json["fundusVessels"],
      fundusPeriphery: json["fundusPeriphery"],
      lids: json["lids"],
      lashes: json["lashes"],
      sclera: json["sclera"],
      conjunctiva: json["conjunctiva"],
      lacrimalSystem: json["lacrimalSystem"],
      topLeft: json["topLeft"],
      topRight: json["topRight"],
      bottomLeft: json["bottomLeft"],
      bottomRight: json["bottomRight"],
      createdAt: DateTime.tryParse(json["createdAt"] ?? ""),
      updatedAt: DateTime.tryParse(json["updatedAt"] ?? ""),
      id: json["id"],
    );
  }

  Map<String, dynamic> toJson() => {
        "eye": eye,
        "examination": examination,
        "autorefSpherical": autorefSpherical,
        "autorefCylindrical": autorefCylindrical,
        "autorefAxis": autorefAxis,
        "ucva": ucva,
        "bcva": bcva,
        "refinedRefractionSpherical": refinedRefractionSpherical,
        "refinedRefractionCylindrical": refinedRefractionCylindrical,
        "refinedRefractionAxis": refinedRefractionAxis,
        "iop": iop,
        "meansOfMeasurement": meansOfMeasurement,
        "acquireAnotherIOPMeasurement": acquireAnotherIopMeasurement,
        "pupilsShape": pupilsShape,
        "pupilsLightReflexTest": pupilsLightReflexTest,
        "pupilsNearReflexTest": pupilsNearReflexTest,
        "pupilsSwingingFlashLightTest": pupilsSwingingFlashLightTest,
        "pupilsOtherDisorders": pupilsOtherDisorders,
        "eyelidPtosis": eyelidPtosis,
        "eyelidLagophthalmos": eyelidLagophthalmos,
        "palpableLymphNodes": palpableLymphNodes,
        "palpableTemporalArtery": palpableTemporalArtery,
        "exophthalmometry": exophthalmometry,
        "cornea": cornea,
        "anteriorChamber": anteriorChamber,
        "iris": iris,
        "lens": lens,
        "anteriorVitreous": anteriorVitreous,
        "fundusOpticDisc": fundusOpticDisc,
        "fundusMacula": fundusMacula,
        "fundusVessels": fundusVessels,
        "fundusPeriphery": fundusPeriphery,
        "lids": lids,
        "lashes": lashes,
        "sclera": sclera,
        "conjunctiva": conjunctiva,
        "lacrimalSystem": lacrimalSystem,
        "topLeft": topLeft,
        "topRight": topRight,
        "bottomLeft": bottomLeft,
        "bottomRight": bottomRight,
        "createdAt": createdAt?.toIso8601String(),
        "updatedAt": updatedAt?.toIso8601String(),
        "id": id,
      };
}

class Type {
  Type({
    required this.name,
    required this.price,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
    required this.duration,
    required this.clinic,
    required this.id,
  });

  final String? name;
  final num? price;
  final bool? isActive;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final num? duration;
  final String? clinic;
  final String? id;

  factory Type.fromJson(Map<String, dynamic> json) {
    return Type(
      name: json["name"],
      price: json["price"],
      isActive: json["isActive"],
      createdAt: DateTime.tryParse(json["createdAt"] ?? ""),
      updatedAt: DateTime.tryParse(json["updatedAt"] ?? ""),
      duration: json["duration"],
      clinic: json["clinic"],
      id: json["id"],
    );
  }

  Map<String, dynamic> toJson() => {
        "name": name,
        "price": price,
        "isActive": isActive,
        "createdAt": createdAt?.toIso8601String(),
        "updatedAt": updatedAt?.toIso8601String(),
        "duration": duration,
        "clinic": clinic,
        "id": id,
      };
}
