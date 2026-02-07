class SavedExaminationModel {
  SavedExaminationModel({
    required this.success,
    required this.examinations,
    required this.total,
    required this.totalPages,
  });

  final bool? success;
  final List<Examination> examinations;
  final num? total;
  final num? totalPages;

  factory SavedExaminationModel.fromJson(Map<String, dynamic> json){
    return SavedExaminationModel(
      success: json["success"],
      examinations: json["examinations"] == null ? [] : List<Examination>.from(json["examinations"]!.map((x) => Examination.fromJson(x))),
      total: json["total"],
      totalPages: json["totalPages"],
    );
  }

}

class Examination {
  Examination({
    required this.clinic,
    required this.appointment,
    required this.deletedAt,
    required this.createdAt,
    required this.createdBy,
    required this.deletedBy,
    required this.measurements,
    required this.patient,
    required this.type,
    required this.updatedAt,
    required this.updatedBy,
    required this.complain,
    required this.history,
    required this.id,
  });

  final String? clinic;
  final Appointment? appointment;
  final dynamic deletedAt;
  final DateTime? createdAt;
  final String? createdBy;
  final dynamic deletedBy;
  final List<Measurement> measurements;
  final Patient? patient;
  final Patient? type;
  final DateTime? updatedAt;
  final String? updatedBy;
  final Complain? complain;
  final History? history;
  final String? id;

  factory Examination.fromJson(Map<String, dynamic> json){
    return Examination(
      clinic: json["clinic"],
      appointment: json["appointment"] == null ? null : Appointment.fromJson(json["appointment"]),
      deletedAt: json["deletedAt"],
      createdAt: DateTime.tryParse(json["createdAt"] ?? ""),
      createdBy: json["createdBy"],
      deletedBy: json["deletedBy"],
      measurements: json["measurements"] == null ? [] : List<Measurement>.from(json["measurements"]!.map((x) => Measurement.fromJson(x))),
      patient: json["patient"] == null ? null : Patient.fromJson(json["patient"]),
      type: json["type"] == null ? null : Patient.fromJson(json["type"]),
      updatedAt: DateTime.tryParse(json["updatedAt"] ?? ""),
      updatedBy: json["updatedBy"],
      complain: json["complain"] == null ? null : Complain.fromJson(json["complain"]),
      history: json["history"] == null ? null : History.fromJson(json["history"]),
      id: json["id"],
    );
  }

}

class Appointment {
  Appointment({
    required this.datetime,
    required this.id,
  });

  final DateTime? datetime;
  final String? id;

  factory Appointment.fromJson(Map<String, dynamic> json){
    return Appointment(
      datetime: DateTime.tryParse(json["datetime"] ?? ""),
      id: json["id"],
    );
  }

}

class Complain {
  Complain({
    required this.examination,
    required this.complainOne,
    required this.complainThree,
    required this.complainTwo,
    required this.createdAt,
    required this.createdBy,
    required this.deletedAt,
    required this.deletedBy,
    required this.updatedAt,
    required this.updatedBy,
    required this.id,
  });

  final String? examination;
  final String? complainOne;
  final String? complainThree;
  final String? complainTwo;
  final DateTime? createdAt;
  final String? createdBy;
  final dynamic deletedAt;
  final dynamic deletedBy;
  final DateTime? updatedAt;
  final String? updatedBy;
  final String? id;

  factory Complain.fromJson(Map<String, dynamic> json){
    return Complain(
      examination: json["examination"],
      complainOne: json["complainOne"],
      complainThree: json["complainThree"],
      complainTwo: json["complainTwo"],
      createdAt: DateTime.tryParse(json["createdAt"] ?? ""),
      createdBy: json["createdBy"],
      deletedAt: json["deletedAt"],
      deletedBy: json["deletedBy"],
      updatedAt: DateTime.tryParse(json["updatedAt"] ?? ""),
      updatedBy: json["updatedBy"],
      id: json["id"],
    );
  }

}

class History {
  History({
    required this.examination,
    required this.createdAt,
    required this.createdBy,
    required this.deletedAt,
    required this.deletedBy,
    required this.familyHistory,
    required this.medicationHistory,
    required this.pastHistory,
    required this.presentIllness,
    required this.updatedAt,
    required this.updatedBy,
    required this.id,
  });

  final String? examination;
  final DateTime? createdAt;
  final String? createdBy;
  final dynamic deletedAt;
  final dynamic deletedBy;
  final String? familyHistory;
  final String? medicationHistory;
  final String? pastHistory;
  final String? presentIllness;
  final DateTime? updatedAt;
  final String? updatedBy;
  final String? id;

  factory History.fromJson(Map<String, dynamic> json){
    return History(
      examination: json["examination"],
      createdAt: DateTime.tryParse(json["createdAt"] ?? ""),
      createdBy: json["createdBy"],
      deletedAt: json["deletedAt"],
      deletedBy: json["deletedBy"],
      familyHistory: json["familyHistory"],
      medicationHistory: json["medicationHistory"],
      pastHistory: json["pastHistory"],
      presentIllness: json["presentIllness"],
      updatedAt: DateTime.tryParse(json["updatedAt"] ?? ""),
      updatedBy: json["updatedBy"],
      id: json["id"],
    );
  }

}

class Measurement {
  Measurement({
    required this.examination,
    required this.eye,
    required this.acquireAnotherIopMeasurement,
    required this.anteriorChamber,
    required this.anteriorVitreous,
    required this.autorefAxis,
    required this.autorefCylindrical,
    required this.autorefSpherical,
    required this.bcva,
    required this.bottomLeft,
    required this.bottomRight,
    required this.conjunctiva,
    required this.cornea,
    required this.createdAt,
    required this.createdBy,
    required this.deletedAt,
    required this.deletedBy,
    required this.exophthalmometry,
    required this.eyelidLagophthalmos,
    required this.eyelidPtosis,
    required this.fundusMacula,
    required this.fundusOpticDisc,
    required this.fundusPeriphery,
    required this.fundusVessels,
    required this.iop,
    required this.iris,
    required this.lacrimalSystem,
    required this.lashes,
    required this.lens,
    required this.lids,
    required this.meansOfMeasurement,
    required this.nearVisionAddition,
    required this.oldAxis,
    required this.oldCylindrical,
    required this.oldSpherical,
    required this.palpableLymphNodes,
    required this.palpableTemporalArtery,
    required this.pupilsLightReflexTest,
    required this.pupilsNearReflexTest,
    required this.pupilsOtherDisorders,
    required this.pupilsShape,
    required this.pupilsSwingingFlashLightTest,
    required this.refinedRefractionAxis,
    required this.refinedRefractionCylindrical,
    required this.refinedRefractionSpherical,
    required this.sclera,
    required this.topLeft,
    required this.topRight,
    required this.ucva,
    required this.updatedAt,
    required this.updatedBy,
    required this.id,
  });

  final String? examination;
  final String? eye;
  final String? acquireAnotherIopMeasurement;
  final List<String> anteriorChamber;
  final List<String> anteriorVitreous;
  final String? autorefAxis;
  final String? autorefCylindrical;
  final String? autorefSpherical;
  final String? bcva;
  final num? bottomLeft;
  final num? bottomRight;
  final String? conjunctiva;
  final List<String> cornea;
  final DateTime? createdAt;
  final String? createdBy;
  final dynamic deletedAt;
  final dynamic deletedBy;
  final String? exophthalmometry;
  final String? eyelidLagophthalmos;
  final String? eyelidPtosis;
  final List<String> fundusMacula;
  final List<String> fundusOpticDisc;
  final List<String> fundusPeriphery;
  final List<String> fundusVessels;
  final String? iop;
  final List<String> iris;
  final String? lacrimalSystem;
  final String? lashes;
  final List<String> lens;
  final String? lids;
  final String? meansOfMeasurement;
  final String? nearVisionAddition;
  final String? oldAxis;
  final String? oldCylindrical;
  final String? oldSpherical;
  final String? palpableLymphNodes;
  final String? palpableTemporalArtery;
  final String? pupilsLightReflexTest;
  final String? pupilsNearReflexTest;
  final String? pupilsOtherDisorders;
  final String? pupilsShape;
  final String? pupilsSwingingFlashLightTest;
  final String? refinedRefractionAxis;
  final String? refinedRefractionCylindrical;
  final String? refinedRefractionSpherical;
  final String? sclera;
  final num? topLeft;
  final num? topRight;
  final String? ucva;
  final DateTime? updatedAt;
  final String? updatedBy;
  final String? id;

  factory Measurement.fromJson(Map<String, dynamic> json){
    return Measurement(
      examination: json["examination"],
      eye: json["eye"],
      acquireAnotherIopMeasurement: json["acquireAnotherIOPMeasurement"],
      anteriorChamber: json["anteriorChamber"] == null ? [] : List<String>.from(json["anteriorChamber"]!.map((x) => x)),
      anteriorVitreous: json["anteriorVitreous"] == null ? [] : List<String>.from(json["anteriorVitreous"]!.map((x) => x)),
      autorefAxis: json["autorefAxis"],
      autorefCylindrical: json["autorefCylindrical"],
      autorefSpherical: json["autorefSpherical"],
      bcva: json["bcva"],
      bottomLeft: json["bottomLeft"],
      bottomRight: json["bottomRight"],
      conjunctiva: json["conjunctiva"],
      cornea: json["cornea"] == null ? [] : List<String>.from(json["cornea"]!.map((x) => x)),
      createdAt: DateTime.tryParse(json["createdAt"] ?? ""),
      createdBy: json["createdBy"],
      deletedAt: json["deletedAt"],
      deletedBy: json["deletedBy"],
      exophthalmometry: json["exophthalmometry"],
      eyelidLagophthalmos: json["eyelidLagophthalmos"],
      eyelidPtosis: json["eyelidPtosis"],
      fundusMacula: json["fundusMacula"] == null ? [] : List<String>.from(json["fundusMacula"]!.map((x) => x)),
      fundusOpticDisc: json["fundusOpticDisc"] == null ? [] : List<String>.from(json["fundusOpticDisc"]!.map((x) => x)),
      fundusPeriphery: json["fundusPeriphery"] == null ? [] : List<String>.from(json["fundusPeriphery"]!.map((x) => x)),
      fundusVessels: json["fundusVessels"] == null ? [] : List<String>.from(json["fundusVessels"]!.map((x) => x)),
      iop: json["iop"],
      iris: json["iris"] == null ? [] : List<String>.from(json["iris"]!.map((x) => x)),
      lacrimalSystem: json["lacrimalSystem"],
      lashes: json["lashes"],
      lens: json["lens"] == null ? [] : List<String>.from(json["lens"]!.map((x) => x)),
      lids: json["lids"],
      meansOfMeasurement: json["meansOfMeasurement"],
      nearVisionAddition: json["nearVisionAddition"],
      oldAxis: json["oldAxis"],
      oldCylindrical: json["oldCylindrical"],
      oldSpherical: json["oldSpherical"],
      palpableLymphNodes: json["palpableLymphNodes"],
      palpableTemporalArtery: json["palpableTemporalArtery"],
      pupilsLightReflexTest: json["pupilsLightReflexTest"],
      pupilsNearReflexTest: json["pupilsNearReflexTest"],
      pupilsOtherDisorders: json["pupilsOtherDisorders"],
      pupilsShape: json["pupilsShape"],
      pupilsSwingingFlashLightTest: json["pupilsSwingingFlashLightTest"],
      refinedRefractionAxis: json["refinedRefractionAxis"],
      refinedRefractionCylindrical: json["refinedRefractionCylindrical"],
      refinedRefractionSpherical: json["refinedRefractionSpherical"],
      sclera: json["sclera"],
      topLeft: json["topLeft"],
      topRight: json["topRight"],
      ucva: json["ucva"],
      updatedAt: DateTime.tryParse(json["updatedAt"] ?? ""),
      updatedBy: json["updatedBy"],
      id: json["id"],
    );
  }

}

class Patient {
  Patient({
    required this.name,
    required this.id,
  });

  final String? name;
  final String? id;

  factory Patient.fromJson(Map<String, dynamic> json){
    return Patient(
      name: json["name"],
      id: json["id"],
    );
  }

}
