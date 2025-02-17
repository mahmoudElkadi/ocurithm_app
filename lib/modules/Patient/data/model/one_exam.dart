import 'package:ocurithm/modules/Patient/data/model/patients_model.dart';

import '../../../Doctor/data/model/doctor_model.dart';

class ExaminationModel {
  ExaminationModel({this.error, this.message, this.examination, this.finalization, this.doctor});

  final String? error;
  final String? message;
  final Examination? examination;
  final Doctor? doctor;
  final Finalization? finalization;

  factory ExaminationModel.fromJson(Map<String, dynamic> json) {
    return ExaminationModel(
      error: json["error"],
      message: json["message"],
      examination: json["examination"] == null ? null : Examination.fromJson(json["examination"]),
      finalization: json["finalization"] == null ? null : Finalization.fromJson(json["finalization"]),
      doctor: json["doctor"] == null ? null : Doctor.fromJson(json["doctor"]),
    );
  }

  Map<String, dynamic> toJson() => {
        "error": error,
        "message": message,
        "examination": examination?.toJson(),
        "doctor": doctor?.toJson(),
        "finalization": finalization?.toJson(),
      };
}

class Examination {
  Examination({
    this.clinic,
    this.patient,
    this.appointment,
    this.type,
    required this.measurements,
    this.createdAt,
    this.updatedAt,
    this.history,
    this.complain,
    this.id,
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
      measurements: json["measurements"] == null ? [] : List<Measurement>.from(json["measurements"]!.map((x) => Measurement.fromJson(x))),
      createdAt: DateTime.tryParse(json["createdAt"] ?? "")?.toLocal(),
      updatedAt: DateTime.tryParse(json["updatedAt"] ?? "")?.toLocal(),
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
    this.clinic,
    this.patient,
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
    this.examination,
    this.complainOne,
    this.complainTwo,
    this.complainThree,
    this.createdAt,
    this.updatedAt,
    this.id,
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
    this.examination,
    this.presentIllness,
    this.pastHistory,
    this.medicationHistory,
    this.familyHistory,
    this.createdAt,
    this.updatedAt,
    this.id,
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
    this.eye,
    this.examination,
    this.autorefSpherical,
    this.autorefCylindrical,
    this.autorefAxis,
    this.ucva,
    this.bcva,
    this.refinedRefractionSpherical,
    this.refinedRefractionCylindrical,
    this.refinedRefractionAxis,
    this.iop,
    this.meansOfMeasurement,
    this.acquireAnotherIopMeasurement,
    this.pupilsShape,
    this.pupilsLightReflexTest,
    this.pupilsNearReflexTest,
    this.pupilsSwingingFlashLightTest,
    this.pupilsOtherDisorders,
    this.eyelidPtosis,
    this.eyelidLagophthalmos,
    this.palpableLymphNodes,
    this.palpableTemporalArtery,
    this.exophthalmometry,
    this.cornea,
    this.anteriorChamber,
    this.iris,
    this.lens,
    this.anteriorVitreous,
    this.fundusOpticDisc,
    this.fundusMacula,
    this.fundusVessels,
    this.fundusPeriphery,
    this.lids,
    this.lashes,
    this.sclera,
    this.conjunctiva,
    this.lacrimalSystem,
    this.topLeft,
    this.topRight,
    this.bottomLeft,
    this.bottomRight,
    this.createdAt,
    this.updatedAt,
    this.id,
    this.nearVisionAddition,
  });

  final String? eye;
  final String? examination;
  final dynamic autorefSpherical;
  final dynamic autorefCylindrical;
  final dynamic autorefAxis;
  final dynamic ucva;
  final dynamic bcva;
  final dynamic refinedRefractionSpherical;
  final dynamic refinedRefractionCylindrical;
  final dynamic refinedRefractionAxis;
  final dynamic iop;
  final dynamic meansOfMeasurement;
  final dynamic acquireAnotherIopMeasurement;
  final dynamic pupilsShape;
  final dynamic pupilsLightReflexTest;
  final dynamic pupilsNearReflexTest;
  final dynamic pupilsSwingingFlashLightTest;
  final dynamic pupilsOtherDisorders;
  final dynamic eyelidPtosis;
  final dynamic eyelidLagophthalmos;
  final dynamic palpableLymphNodes;
  final dynamic palpableTemporalArtery;
  final dynamic exophthalmometry;
  final dynamic cornea;
  final dynamic anteriorChamber;
  final dynamic iris;
  final dynamic lens;
  final dynamic anteriorVitreous;
  final dynamic fundusOpticDisc;
  final dynamic fundusMacula;
  final dynamic fundusVessels;
  final dynamic fundusPeriphery;
  final dynamic nearVisionAddition;
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
      nearVisionAddition: json["nearVisionAddition"],
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
    this.clinic,
    this.name,
    this.price,
    this.duration,
    this.isActive,
    this.createdAt,
    this.updatedAt,
    this.id,
  });

  final String? clinic;
  final String? name;
  final num? price;
  final num? duration;
  final bool? isActive;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final String? id;

  factory Type.fromJson(Map<String, dynamic> json) {
    return Type(
      clinic: json["clinic"],
      name: json["name"],
      price: json["price"],
      duration: json["duration"],
      isActive: json["isActive"],
      createdAt: json["createdAt"] == null ? null : DateTime.tryParse(json["createdAt"] ?? "")!.toLocal(),
      updatedAt: json["updatedAt"] == null ? null : DateTime.tryParse(json["updatedAt"] ?? "")?.toLocal(),
      id: json["id"],
    );
  }

  Map<String, dynamic> toJson() => {
        "clinic": clinic,
        "name": name,
        "price": price,
        "duration": duration,
        "isActive": isActive,
        "createdAt": createdAt?.toIso8601String(),
        "updatedAt": updatedAt?.toIso8601String(),
        "id": id,
      };
}

class Finalization {
  Finalization({
    this.examination,
    this.diagnosis,
    required this.actions,
    this.createdAt,
    this.updatedAt,
    this.id,
  });

  final String? examination;
  final String? diagnosis;
  final List<Action> actions;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final String? id;

  factory Finalization.fromJson(Map<String, dynamic> json) {
    return Finalization(
      examination: json["examination"],
      diagnosis: json["diagnosis"],
      actions: json["actions"] == null ? [] : List<Action>.from(json["actions"]!.map((x) => Action.fromJson(x))),
      createdAt: DateTime.tryParse(json["createdAt"] ?? ""),
      updatedAt: DateTime.tryParse(json["updatedAt"] ?? ""),
      id: json["id"],
    );
  }

  Map<String, dynamic> toJson() => {
        "examination": examination,
        "diagnosis": diagnosis,
        "actions": actions.map((x) => x?.toJson()).toList(),
        "createdAt": createdAt?.toIso8601String(),
        "updatedAt": updatedAt?.toIso8601String(),
        "id": id,
      };
}

class Action {
  Action({
    this.action,
    this.eye,
    this.data,
    required this.metaData,
    this.id,
    this.actionId,
  });

  String? action;
  String? eye;
  String? data;
  List<String> metaData;
  String? id;
  String? actionId;

  factory Action.fromJson(Map<String, dynamic> json) {
    return Action(
      action: json["action"],
      eye: json["eye"],
      data: json["data"],
      metaData: json["metaData"] == null ? [] : List<String>.from(json["metaData"]!.map((x) => x)),
      id: json["_id"],
      actionId: json["id"],
    );
  }

  Map<String, dynamic> toJson() => {
        "action": action,
        "eye": eye,
        "data": data,
        "metaData": metaData.map((x) => x).toList(),
        "_id": id,
        "id": actionId,
      };
}
