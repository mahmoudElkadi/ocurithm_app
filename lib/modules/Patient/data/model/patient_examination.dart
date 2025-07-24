import 'package:ocurithm/modules/Patient/data/model/patients_model.dart';

class PatientExaminationModel {
  PatientExaminationModel({
    required this.examinations,
    required this.error,
    required this.message,
  });

  final Examinations? examinations;
  final String? error;
  final String? message;

  factory PatientExaminationModel.fromJson(Map<String, dynamic> json) {
    return PatientExaminationModel(
      examinations: json["examinations"] == null ? null : Examinations.fromJson(json["examinations"]),
      error: json["error"],
      message: json["message"],
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
  final int? total;
  final dynamic totalPages;

  factory Examinations.fromJson(Map<String, dynamic> json) {
    return Examinations(
      examinations: json["examinations"] == null
          ? []
          : List<Examination>.from(json["examinations"]!.map((x) => Examination.fromJson(x))),
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
  final List<Measurement> measurements;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final History? history;
  final Complain? complain;
  final String? id;

  factory Examination.fromJson(Map<String, dynamic> json) {
    return Examination(
      clinic: json["clinic"],
      patient: json["patient"] == null ? null : Patient.fromJson(json["patient"]),
      appointment: json["appointment"] == null ? null : Appointment.fromJson(json["appointment"]),
      type: json["type"] == null ? null : Type.fromJson(json["type"]),
      measurements: json["measurements"] == null
          ? []
          : List<Measurement>.from(json["measurements"]!.map((x) => Measurement.fromJson(x))),
      createdAt: json["createdAt"] == null ? null : DateTime.tryParse(json["createdAt"])?.toLocal(),
      updatedAt: DateTime.tryParse(json["updatedAt"] ?? ""),
      history: json["history"] == null ? null : History.fromJson(json["history"]),
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

class Complain {
  Complain({
    required this.examination,
    required this.complainOne,
    required this.complainTwo,
    required this.complainThree,
    required this.createdAt,
    required this.updatedAt,
    required this.id,
  });

  final String? examination;
  final String? complainOne;
  final String? complainTwo;
  final String? complainThree;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final String? id;

  factory Complain.fromJson(Map<String, dynamic> json) {
    return Complain(
      examination: json["examination"],
      complainOne: json["complainOne"],
      complainTwo: json["complainTwo"],
      complainThree: json["complainThree"],
      createdAt: DateTime.tryParse(json["createdAt"] ?? ""),
      updatedAt: DateTime.tryParse(json["updatedAt"] ?? ""),
      id: json["id"],
    );
  }

  Map<String, dynamic> toJson() => {
        "examination": examination,
        "complainOne": complainOne,
        "complainTwo": complainTwo,
        "complainThree": complainThree,
        "createdAt": createdAt?.toIso8601String(),
        "updatedAt": updatedAt?.toIso8601String(),
        "id": id,
      };
}

class History {
  History({
    required this.examination,
    required this.presentIllness,
    required this.pastHistory,
    required this.medicationHistory,
    required this.familyHistory,
    required this.createdAt,
    required this.updatedAt,
    required this.id,
  });

  final String? examination;
  final String? presentIllness;
  final String? pastHistory;
  final String? medicationHistory;
  final String? familyHistory;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final String? id;

  factory History.fromJson(Map<String, dynamic> json) {
    return History(
      examination: json["examination"],
      presentIllness: json["presentIllness"],
      pastHistory: json["pastHistory"],
      medicationHistory: json["medicationHistory"],
      familyHistory: json["familyHistory"],
      createdAt: DateTime.tryParse(json["createdAt"] ?? ""),
      updatedAt: DateTime.tryParse(json["updatedAt"] ?? ""),
      id: json["id"],
    );
  }

  Map<String, dynamic> toJson() => {
        "examination": examination,
        "presentIllness": presentIllness,
        "pastHistory": pastHistory,
        "medicationHistory": medicationHistory,
        "familyHistory": familyHistory,
        "createdAt": createdAt?.toIso8601String(),
        "updatedAt": updatedAt?.toIso8601String(),
        "id": id,
      };
}

class Measurement {
  Measurement({
    required this.eye,
    required this.examination,
    required this.oldSpherical,
    required this.oldCylindrical,
    required this.oldAxis,
    required this.autorefSpherical,
    required this.autorefCylindrical,
    required this.autorefAxis,
    required this.nearVisionAddition,
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
  final String? oldSpherical;
  final String? oldCylindrical;
  final String? oldAxis;
  final String? autorefSpherical;
  final String? autorefCylindrical;
  final String? autorefAxis;
  final String? nearVisionAddition;
  final String? ucva;
  final String? bcva;
  final String? refinedRefractionSpherical;
  final String? refinedRefractionCylindrical;
  final String? refinedRefractionAxis;
  final String? iop;
  final String? meansOfMeasurement;
  final String? acquireAnotherIopMeasurement;
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
  final List<String> cornea;
  final List<String> anteriorChamber;
  final List<String> iris;
  final List<String> lens;
  final List<String> anteriorVitreous;
  final List<String> fundusOpticDisc;
  final List<String> fundusMacula;
  final List<String> fundusVessels;
  final List<String> fundusPeriphery;
  final String? lids;
  final String? lashes;
  final String? sclera;
  final String? conjunctiva;
  final String? lacrimalSystem;
  final int? topLeft;
  final int? topRight;
  final int? bottomLeft;
  final int? bottomRight;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final String? id;

  factory Measurement.fromJson(Map<String, dynamic> json) {
    return Measurement(
      eye: json["eye"],
      examination: json["examination"],
      oldSpherical: json["oldSpherical"],
      oldCylindrical: json["oldCylindrical"],
      oldAxis: json["oldAxis"],
      autorefSpherical: json["autorefSpherical"],
      autorefCylindrical: json["autorefCylindrical"],
      autorefAxis: json["autorefAxis"],
      nearVisionAddition: json["nearVisionAddition"],
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
      cornea: json["cornea"] == null ? [] : List<String>.from(json["cornea"]!.map((x) => x)),
      anteriorChamber: json["anteriorChamber"] == null ? [] : List<String>.from(json["anteriorChamber"]!.map((x) => x)),
      iris: json["iris"] == null ? [] : List<String>.from(json["iris"]!.map((x) => x)),
      lens: json["lens"] == null ? [] : List<String>.from(json["lens"]!.map((x) => x)),
      anteriorVitreous:
          json["anteriorVitreous"] == null ? [] : List<String>.from(json["anteriorVitreous"]!.map((x) => x)),
      fundusOpticDisc: json["fundusOpticDisc"] == null ? [] : List<String>.from(json["fundusOpticDisc"]!.map((x) => x)),
      fundusMacula: json["fundusMacula"] == null ? [] : List<String>.from(json["fundusMacula"]!.map((x) => x)),
      fundusVessels: json["fundusVessels"] == null ? [] : List<String>.from(json["fundusVessels"]!.map((x) => x)),
      fundusPeriphery: json["fundusPeriphery"] == null ? [] : List<String>.from(json["fundusPeriphery"]!.map((x) => x)),
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
        "oldSpherical": oldSpherical,
        "oldCylindrical": oldCylindrical,
        "oldAxis": oldAxis,
        "autorefSpherical": autorefSpherical,
        "autorefCylindrical": autorefCylindrical,
        "autorefAxis": autorefAxis,
        "nearVisionAddition": nearVisionAddition,
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
        "cornea": cornea.map((x) => x).toList(),
        "anteriorChamber": anteriorChamber.map((x) => x).toList(),
        "iris": iris.map((x) => x).toList(),
        "lens": lens.map((x) => x).toList(),
        "anteriorVitreous": anteriorVitreous.map((x) => x).toList(),
        "fundusOpticDisc": fundusOpticDisc.map((x) => x).toList(),
        "fundusMacula": fundusMacula.map((x) => x).toList(),
        "fundusVessels": fundusVessels.map((x) => x).toList(),
        "fundusPeriphery": fundusPeriphery.map((x) => x).toList(),
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
