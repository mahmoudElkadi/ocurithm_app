import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ocurithm/modules/Appointment/data/models/appointment_model.dart';
import 'package:ocurithm/modules/Examination/data/model/saved_Exam.dart'
    hide Appointment;
import 'package:ocurithm/modules/Examination/data/catalog/history_catalog.dart';
import 'package:ocurithm/modules/Examination/data/catalog/complain_catalog.dart';
import 'package:ocurithm/modules/Examination/data/catalog/measurements_constants.dart';

part 'examination_form_state.dart';

class ExaminationFormCubit extends Cubit<ExaminationFormState> {
  ExaminationFormCubit() : super(ExaminationFormInitial());

  static ExaminationFormCubit get(BuildContext context) =>
      BlocProvider.of(context);

  final TextEditingController familyHistoryController = TextEditingController();
  final TextEditingController presentIllnessController =
      TextEditingController();
  final TextEditingController pastHistoryController = TextEditingController();
  final TextEditingController medicationHistoryController =
      TextEditingController();
  final TextEditingController oneComplaintController = TextEditingController();
  final TextEditingController twoComplaintController = TextEditingController();
  final TextEditingController threeComplaintController =
      TextEditingController();

  final int totalSteps = 4;
  int _currentStep = 0;
  int get currentStep => _currentStep;

  Appointment? appointmentData;
  Map<String, dynamic> data = {};

  // ── Structured History (config-driven catalog) ──
  // Ticked category keys and the flat, globally-keyed values map. The 4 free-text
  // controllers above remain the legacy "Other notes" surface.
  final List<String> selectedHistoryCategories = [];
  final Map<String, dynamic> historyValues = {};

  /// Field keys that belong ONLY to [categoryKey] (not shared with any other
  /// still-selected category). Used to prune orphaned values on uncheck without
  /// dropping canonical keys (hba1c, bpSystolic, …) that another section still owns.
  List<String> _exclusiveFieldKeys(String categoryKey) {
    final category = historyCategories.firstWhere((c) => c.key == categoryKey,
        orElse: () => const CategoryDef(key: '', label: '', fieldKeys: []));
    final keptByOthers = <String>{};
    for (final other in selectedHistoryCategories) {
      if (other == categoryKey) continue;
      final c = historyCategories.firstWhere((c) => c.key == other,
          orElse: () => const CategoryDef(key: '', label: '', fieldKeys: []));
      keptByOthers.addAll(c.fieldKeys);
    }
    return category.fieldKeys.where((k) => !keptByOthers.contains(k)).toList();
  }

  void toggleHistoryCategory(String categoryKey, bool selected) {
    if (selected) {
      if (!selectedHistoryCategories.contains(categoryKey)) {
        selectedHistoryCategories.add(categoryKey);
      }
    } else {
      // Prune this category's exclusive values before deselecting.
      for (final key in _exclusiveFieldKeys(categoryKey)) {
        historyValues.remove(key);
      }
      selectedHistoryCategories.remove(categoryKey);
    }
    recomputeHistory(historyValues);
    emit(ExaminationFormUpdated());
  }

  void setHistoryValue(String key, dynamic value) {
    if (value == null || (value is String && value.isEmpty) || (value is List && value.isEmpty)) {
      historyValues.remove(key);
    } else {
      historyValues[key] = value;
    }
    // Clear-on-hide: any field whose showIf no longer matches is dropped so a
    // changed answer wipes its dependent sub-fields.
    for (final def in historyFields.values) {
      if (def.key == key) continue;
      if (!isFieldVisible(def, historyValues)) {
        historyValues.remove(def.key);
      }
    }
    recomputeHistory(historyValues);
    emit(ExaminationFormUpdated());
  }

  // ── Structured Complain (config-driven catalog) ──
  // Ticked option keys and the flat, option-namespaced values map. The 3 legacy
  // complain controllers remain the "Other complaints" free-text surface.
  final List<String> selectedComplaints = [];
  final Map<String, dynamic> complainValues = {};

  void toggleComplaint(String optionKey, bool selected) {
    if (selected) {
      if (!selectedComplaints.contains(optionKey)) {
        selectedComplaints.add(optionKey);
      }
    } else {
      // Complain keys are option-scoped (never shared), so prune this option's
      // fields unconditionally on uncheck.
      final option = complainOptionsByKey[optionKey];
      if (option != null) {
        for (final key in option.fieldKeys) {
          complainValues.remove(key);
        }
      }
      selectedComplaints.remove(optionKey);
    }
    emit(ExaminationFormUpdated());
  }

  void setComplainValue(String key, dynamic value) {
    if (value == null || (value is String && value.isEmpty) || (value is List && value.isEmpty)) {
      complainValues.remove(key);
    } else {
      complainValues[key] = value;
    }
    // Clear-on-hide for any field whose showIf no longer matches (complain has
    // no showIf today, but this keeps the two stages behaving identically).
    for (final def in complainFields.values) {
      if (def.key == key) continue;
      if (!isFieldVisible(def, complainValues)) {
        complainValues.remove(def.key);
      }
    }
    emit(ExaminationFormUpdated());
  }

  // --- Left Eye Fields ---
  dynamic leftOldSpherical;
  dynamic leftOldCylindrical;
  dynamic leftOldAxis;
  dynamic leftOldGlassesVa;
  dynamic leftAurorefSpherical;
  dynamic leftAurorefCylindrical;
  dynamic leftAurorefAxis;
  dynamic leftUCVA;
  dynamic leftBCVA;
  dynamic leftRefinedRefractionSpherical;
  dynamic leftRefinedRefractionCylindrical;
  dynamic leftRefinedRefractionAxis;
  dynamic leftNearVisionAddition;
  dynamic leftIOP;
  dynamic leftMeansOfMeasurement;
  dynamic leftAcquireAnotherIOPMeasurement;
  dynamic leftPupilsShape;
  dynamic leftPupilsLightReflexTest;
  dynamic leftPupilsNearReflexTest;
  dynamic leftPupilsSwingingFlashLightTest;
  dynamic leftPupilsOtherDisorders;
  dynamic leftEyelidPtosis;
  dynamic leftEyelidLagophthalmos;
  dynamic leftPalpableLymphNodes;
  dynamic leftPapableTemporalArtery;
  dynamic leftExophthalmometry;

  TextEditingController leftLidsController = TextEditingController();
  TextEditingController leftLashesController = TextEditingController();
  TextEditingController leftLacrimalController = TextEditingController();
  TextEditingController leftConjunctivaController = TextEditingController();
  TextEditingController leftScleraController = TextEditingController();
  TextEditingController leftShapeController = TextEditingController();

  List leftCornea = [];
  List leftAnteriorChambre = [];
  List leftIris = [];
  List leftLens = [];
  List leftAnteriorVitreous = [];
  List leftFundusOpticDisc = [];
  List leftFundusMacula = [];
  List leftFundusVessels = [];
  List leftFundusPeriphery = [];

  num leftTopRightTapCount = 0;
  num leftTopLeftTapCount = 0;
  num leftBottomRightTapCount = 0;
  num leftBottomLeftTapCount = 0;

  // --- Right Eye Fields ---
  dynamic rightOldSpherical;
  dynamic rightOldCylindrical;
  dynamic rightOldAxis;
  dynamic rightOldGlassesVa;
  dynamic rightAurorefSpherical;
  dynamic rightAurorefCylindrical;
  dynamic rightAurorefAxis;
  dynamic rightUCVA;
  dynamic rightBCVA;
  dynamic rightRefinedRefractionSpherical;
  dynamic rightRefinedRefractionCylindrical;
  dynamic rightRefinedRefractionAxis;
  dynamic rightNearVisionAddition;
  dynamic rightIOP;
  dynamic rightMeansOfMeasurement;
  dynamic rightAcquireAnotherIOPMeasurement;
  dynamic rightPupilsShape;
  dynamic rightPupilsLightReflexTest;
  dynamic rightPupilsNearReflexTest;
  dynamic rightPupilsSwingingFlashLightTest;
  dynamic rightPupilsOtherDisorders;
  dynamic rightEyelidPtosis;
  dynamic rightEyelidLagophthalmos;
  dynamic rightPalpableLymphNodes;
  dynamic rightPapableTemporalArtery;
  dynamic rightExophthalmometry;

  TextEditingController rightLidsController = TextEditingController();
  TextEditingController rightLashesController = TextEditingController();
  TextEditingController rightLacrimalController = TextEditingController();
  TextEditingController rightConjunctivaController = TextEditingController();
  TextEditingController rightScleraController = TextEditingController();
  TextEditingController rightShapeController = TextEditingController();

  List rightCornea = [];
  List rightAnteriorChambre = [];
  List rightIris = [];
  List rightLens = [];
  List rightAnteriorVitreous = [];
  List rightFundusOpticDisc = [];
  List rightFundusMacula = [];
  List rightFundusVessels = [];
  List rightFundusPeriphery = [];

  num rightTopRightTapCount = 0;
  num rightTopLeftTapCount = 0;
  num rightBottomRightTapCount = 0;
  num rightBottomLeftTapCount = 0;

  // ── Measurements V1 additive fields (per eye) ──
  dynamic leftCupDiscRatio;
  dynamic rightCupDiscRatio;
  dynamic leftVitreousHemorrhageGrade;
  dynamic rightVitreousHemorrhageGrade;

  /// Set an eye's vitreous findings. Clears that eye's VH grade when "Vitreous
  /// Hemorrhage" is no longer selected. Emits so the conditional VH-grade field
  /// shows/hides.
  void setAnteriorVitreous(bool isLeft, List<dynamic> selected) {
    if (isLeft) {
      leftAnteriorVitreous = selected;
    } else {
      rightAnteriorVitreous = selected;
    }
    final hasVH = selected.contains(vitreousHemorrhageOption);
    if (!hasVH) {
      if (isLeft) {
        leftVitreousHemorrhageGrade = null;
      } else {
        rightVitreousHemorrhageGrade = null;
      }
    }
    emit(ExaminationFormUpdated());
  }

  void setVitreousHemorrhageGrade(bool isLeft, dynamic value) {
    if (isLeft) {
      leftVitreousHemorrhageGrade = value;
    } else {
      rightVitreousHemorrhageGrade = value;
    }
    emit(ExaminationFormUpdated());
  }

  void setCupDiscRatio(bool isLeft, dynamic value) {
    if (isLeft) {
      leftCupDiscRatio = value;
    } else {
      rightCupDiscRatio = value;
    }
  }

  String? action;

  @override
  Future<void> close() {
    familyHistoryController.dispose();
    presentIllnessController.dispose();
    pastHistoryController.dispose();
    medicationHistoryController.dispose();
    oneComplaintController.dispose();
    twoComplaintController.dispose();
    threeComplaintController.dispose();

    leftLidsController.dispose();
    leftLashesController.dispose();
    leftLacrimalController.dispose();
    leftConjunctivaController.dispose();
    leftScleraController.dispose();
    leftShapeController.dispose();

    rightLidsController.dispose();
    rightLashesController.dispose();
    rightLacrimalController.dispose();
    rightConjunctivaController.dispose();
    rightScleraController.dispose();
    rightShapeController.dispose();
    return super.close();
  }

  void nextStep() {
    if (_currentStep < totalSteps - 1) {
      _currentStep++;
      emit(ExaminationFormStepChanged());
    }
  }

  void previousStep() {
    if (_currentStep > 0) {
      _currentStep--;
      emit(ExaminationFormStepChanged());
    }
  }

  void setAppointment(Appointment appointment) {
    appointmentData = appointment;
    emit(ExaminationFormUpdated());
  }

  Future<void> readJson() async {
    try {
      final response = await rootBundle.loadString('assets/files/autoref.json');
      data = await json.decode(response);
      emit(ExaminationFormJsonLoaded());
    } catch (e) {
      debugPrint('Error loading JSON: $e');
    }
  }

  Map<String, dynamic> examinationData() {
    // Legacy free-text history (also the "Other notes" surface). Structured
    // catalog data is additive — sent only when present so a purely free-text
    // save stays on the backend's legacy path (no catalogVersion stamped).
    final Map<String, dynamic> examinationHistory = {
      "familyHistory": familyHistoryController.text,
      "presentIllness": presentIllnessController.text,
      "pastHistory": pastHistoryController.text,
      "medicationHistory": medicationHistoryController.text,
    };
    if (selectedHistoryCategories.isNotEmpty || historyValues.isNotEmpty) {
      recomputeHistory(historyValues);
      examinationHistory["selectedCategories"] =
          List<String>.from(selectedHistoryCategories);
      examinationHistory["values"] = Map<String, dynamic>.from(historyValues);
    }

    // Legacy free-text complaints + additive structured complain (sent only when
    // present so a free-text-only save stays on the backend's legacy path).
    final Map<String, dynamic> examinationComplain = {
      "complainOne": oneComplaintController.text,
      "complainTwo": twoComplaintController.text,
      "complainThree": threeComplaintController.text
    };
    if (selectedComplaints.isNotEmpty || complainValues.isNotEmpty) {
      examinationComplain["selectedComplaints"] =
          List<String>.from(selectedComplaints);
      examinationComplain["values"] = Map<String, dynamic>.from(complainValues);
    }

    return {
      "examinationMainData": {
        "clinic": appointmentData?.clinic?.id,
        "patient": appointmentData?.patient?.id,
        "appointment": appointmentData?.id,
        "type": appointmentData?.examinationType?.id,
        "action": action
      },
      "examinationHistory": examinationHistory,
      "examinationComplain": examinationComplain,
      "leftEyeMeasurement": {
        "eye": "Left",
        'oldSpherical': leftOldSpherical,
        'oldCylindrical': leftOldCylindrical,
        'oldAxis': leftOldAxis,
        'oldGlassesVa': leftOldGlassesVa,
        "autorefSpherical": leftAurorefSpherical,
        "autorefCylindrical": leftAurorefCylindrical,
        "autorefAxis": leftAurorefAxis,
        "ucva": leftUCVA,
        "bcva": leftBCVA,
        "refinedRefractionSpherical": leftRefinedRefractionSpherical,
        "refinedRefractionCylindrical": leftRefinedRefractionCylindrical,
        "refinedRefractionAxis": leftRefinedRefractionAxis,
        "nearVisionAddition": leftNearVisionAddition,
        "iop": leftIOP,
        "meansOfMeasurement": leftMeansOfMeasurement,
        "acquireAnotherIOPMeasurement": leftAcquireAnotherIOPMeasurement,
        "pupilsShape": leftPupilsShape == "others"
            ? leftShapeController.text
            : leftPupilsShape,
        "pupilsLightReflexTest": leftPupilsLightReflexTest,
        "pupilsNearReflexTest": leftPupilsNearReflexTest,
        "pupilsSwingingFlashLightTest": leftPupilsSwingingFlashLightTest,
        "pupilsOtherDisorders": leftPupilsOtherDisorders,
        "eyelidPtosis": leftEyelidPtosis,
        "eyelidLagophthalmos": leftEyelidLagophthalmos,
        "palpableLymphNodes": leftPalpableLymphNodes,
        "palpableTemporalArtery": leftPapableTemporalArtery,
        "exophthalmometry": leftExophthalmometry,
        "cornea": leftCornea,
        "anteriorChamber": leftAnteriorChambre,
        "iris": leftIris,
        "lens": leftLens,
        "anteriorVitreous": leftAnteriorVitreous,
        "fundusOpticDisc": leftFundusOpticDisc,
        "fundusMacula": leftFundusMacula,
        "fundusVessels": leftFundusVessels,
        "fundusPeriphery": leftFundusPeriphery,
        "cupDiscRatio": leftCupDiscRatio,
        "vitreousHemorrhageGrade": leftVitreousHemorrhageGrade,
        "lids": leftLidsController.text,
        "lashes": leftLashesController.text,
        "sclera": leftScleraController.text,
        "conjunctiva": leftConjunctivaController.text,
        "lacrimalSystem": leftLacrimalController.text,
        "topLeft": leftTopLeftTapCount,
        "topRight": leftTopRightTapCount,
        "bottomLeft": leftBottomLeftTapCount,
        "bottomRight": leftBottomRightTapCount,
      },
      "rightEyeMeasurement": {
        "eye": "Right",
        'oldSpherical': rightOldSpherical,
        'oldCylindrical': rightOldCylindrical,
        'oldAxis': rightOldAxis,
        'oldGlassesVa': rightOldGlassesVa,
        "autorefSpherical": rightAurorefSpherical,
        "autorefCylindrical": rightAurorefCylindrical,
        "autorefAxis": rightAurorefAxis,
        "ucva": rightUCVA,
        "bcva": rightBCVA,
        "refinedRefractionSpherical": rightRefinedRefractionSpherical,
        "refinedRefractionCylindrical": rightRefinedRefractionCylindrical,
        "refinedRefractionAxis": rightRefinedRefractionAxis,
        "iop": rightIOP,
        "meansOfMeasurement": rightMeansOfMeasurement,
        "acquireAnotherIOPMeasurement": rightAcquireAnotherIOPMeasurement,
        "pupilsShape": rightPupilsShape == "others"
            ? rightShapeController.text
            : rightPupilsShape,
        "pupilsLightReflexTest": rightPupilsLightReflexTest,
        "pupilsNearReflexTest": rightPupilsNearReflexTest,
        "pupilsSwingingFlashLightTest": rightPupilsSwingingFlashLightTest,
        "pupilsOtherDisorders": rightPupilsOtherDisorders,
        "eyelidPtosis": rightEyelidPtosis,
        "eyelidLagophthalmos": rightEyelidLagophthalmos,
        "palpableLymphNodes": rightPalpableLymphNodes,
        "palpableTemporalArtery": rightPapableTemporalArtery,
        "exophthalmometry": rightExophthalmometry,
        "nearVisionAddition": rightNearVisionAddition,
        "cornea": rightCornea,
        "anteriorChamber": rightAnteriorChambre,
        "iris": rightIris,
        "lens": rightLens,
        "anteriorVitreous": rightAnteriorVitreous,
        "fundusOpticDisc": rightFundusOpticDisc,
        "fundusMacula": rightFundusMacula,
        "fundusVessels": rightFundusVessels,
        "fundusPeriphery": rightFundusPeriphery,
        "cupDiscRatio": rightCupDiscRatio,
        "vitreousHemorrhageGrade": rightVitreousHemorrhageGrade,
        "lids": rightLidsController.text,
        "lashes": rightLashesController.text,
        "sclera": rightScleraController.text,
        "conjunctiva": rightConjunctivaController.text,
        "lacrimalSystem": rightLacrimalController.text,
        "topLeft": rightTopLeftTapCount,
        "topRight": rightTopRightTapCount,
        "bottomLeft": rightBottomLeftTapCount,
        "bottomRight": rightBottomRightTapCount,
      },
    };
  }

  void populateFromModel(SavedExaminationModel oneExamination) {
    if (oneExamination.examinations.isEmpty) return;

    final exam = oneExamination.examinations[0];
    if (exam.measurements.isEmpty) return;

    // Find measurements by eye label
    Measurement? leftMeas;
    Measurement? rightMeas;

    for (var m in exam.measurements) {
      if (m.eye?.toLowerCase() == 'left') leftMeas = m;
      if (m.eye?.toLowerCase() == 'right') rightMeas = m;
    }

    // Fallbacks if not found by label
    leftMeas ??= exam.measurements[0];
    rightMeas ??= exam.measurements.length > 1
        ? exam.measurements[1]
        : exam.measurements[0];

    leftOldSpherical = leftMeas.oldSpherical;
    leftOldCylindrical = leftMeas.oldCylindrical;
    leftOldAxis = leftMeas.oldAxis;
    leftOldGlassesVa = leftMeas.oldGlassesVa;

    rightOldSpherical = rightMeas.oldSpherical;
    rightOldCylindrical = rightMeas.oldCylindrical;
    rightOldAxis = rightMeas.oldAxis;
    rightOldGlassesVa = rightMeas.oldGlassesVa;

    leftAurorefSpherical = leftMeas.autorefSpherical;
    leftAurorefCylindrical = leftMeas.autorefCylindrical;
    leftAurorefAxis = leftMeas.autorefAxis;

    rightAurorefSpherical = rightMeas.autorefSpherical;
    rightAurorefCylindrical = rightMeas.autorefCylindrical;
    rightAurorefAxis = rightMeas.autorefAxis;

    leftRefinedRefractionSpherical = leftMeas.refinedRefractionSpherical;
    leftRefinedRefractionCylindrical = leftMeas.refinedRefractionCylindrical;
    leftRefinedRefractionAxis = leftMeas.refinedRefractionAxis;
    leftNearVisionAddition = leftMeas.nearVisionAddition;

    rightRefinedRefractionSpherical = rightMeas.refinedRefractionSpherical;
    rightRefinedRefractionCylindrical = rightMeas.refinedRefractionCylindrical;
    rightRefinedRefractionAxis = rightMeas.refinedRefractionAxis;
    rightNearVisionAddition = rightMeas.nearVisionAddition;

    leftUCVA = leftMeas.ucva;
    rightUCVA = rightMeas.ucva;
    leftBCVA = leftMeas.bcva;
    rightBCVA = rightMeas.bcva;

    leftIOP = leftMeas.iop;
    rightIOP = rightMeas.iop;
    leftMeansOfMeasurement = leftMeas.meansOfMeasurement;
    rightMeansOfMeasurement = rightMeas.meansOfMeasurement;
    leftAcquireAnotherIOPMeasurement = leftMeas.acquireAnotherIopMeasurement;
    rightAcquireAnotherIOPMeasurement = rightMeas.acquireAnotherIopMeasurement;

    // Pupils Shape Left
    final leftPupilsShapeVal = leftMeas.pupilsShape;
    if (leftPupilsShapeVal != null &&
        !["rounded", "irregular"].contains(leftPupilsShapeVal)) {
      leftPupilsShape = "others";
      leftShapeController.text = leftPupilsShapeVal;
    } else {
      leftPupilsShape = leftPupilsShapeVal;
    }

    // Pupils Shape Right
    final rightPupilsShapeVal = rightMeas.pupilsShape;
    if (rightPupilsShapeVal != null &&
        !["rounded", "irregular"].contains(rightPupilsShapeVal)) {
      rightPupilsShape = "others";
      rightShapeController.text = rightPupilsShapeVal;
    } else {
      rightPupilsShape = rightPupilsShapeVal;
    }

    leftPupilsLightReflexTest = leftMeas.pupilsLightReflexTest;
    rightPupilsLightReflexTest = rightMeas.pupilsLightReflexTest;
    leftPupilsNearReflexTest = leftMeas.pupilsNearReflexTest;
    rightPupilsNearReflexTest = rightMeas.pupilsNearReflexTest;
    leftPupilsSwingingFlashLightTest = leftMeas.pupilsSwingingFlashLightTest;
    rightPupilsSwingingFlashLightTest = rightMeas.pupilsSwingingFlashLightTest;
    leftPupilsOtherDisorders = leftMeas.pupilsOtherDisorders;
    rightPupilsOtherDisorders = rightMeas.pupilsOtherDisorders;

    leftEyelidPtosis = leftMeas.eyelidPtosis;
    rightEyelidPtosis = rightMeas.eyelidPtosis;
    leftEyelidLagophthalmos = leftMeas.eyelidLagophthalmos;
    rightEyelidLagophthalmos = rightMeas.eyelidLagophthalmos;
    leftPalpableLymphNodes = leftMeas.palpableLymphNodes;
    rightPalpableLymphNodes = rightMeas.palpableLymphNodes;
    leftPapableTemporalArtery = leftMeas.palpableTemporalArtery;
    rightPapableTemporalArtery = rightMeas.palpableTemporalArtery;
    leftExophthalmometry = leftMeas.exophthalmometry;
    rightExophthalmometry = rightMeas.exophthalmometry;

    leftCornea = leftMeas.cornea;
    rightCornea = rightMeas.cornea;
    leftAnteriorChambre = leftMeas.anteriorChamber;
    rightAnteriorChambre = rightMeas.anteriorChamber;
    leftIris = leftMeas.iris;
    rightIris = rightMeas.iris;
    leftLens = leftMeas.lens;
    rightLens = rightMeas.lens;
    leftAnteriorVitreous = leftMeas.anteriorVitreous;
    rightAnteriorVitreous = rightMeas.anteriorVitreous;

    leftFundusOpticDisc = leftMeas.fundusOpticDisc;
    rightFundusOpticDisc = rightMeas.fundusOpticDisc;
    leftFundusMacula = leftMeas.fundusMacula;
    rightFundusMacula = rightMeas.fundusMacula;
    leftFundusVessels = leftMeas.fundusVessels;
    rightFundusVessels = rightMeas.fundusVessels;
    leftFundusPeriphery = leftMeas.fundusPeriphery;
    rightFundusPeriphery = rightMeas.fundusPeriphery;

    leftCupDiscRatio = leftMeas.cupDiscRatio;
    rightCupDiscRatio = rightMeas.cupDiscRatio;
    leftVitreousHemorrhageGrade = leftMeas.vitreousHemorrhageGrade;
    rightVitreousHemorrhageGrade = rightMeas.vitreousHemorrhageGrade;

    leftLidsController.text = leftMeas.lids ?? '';
    rightLidsController.text = rightMeas.lids ?? '';
    leftLashesController.text = leftMeas.lashes ?? '';
    rightLashesController.text = rightMeas.lashes ?? '';
    leftLacrimalController.text = leftMeas.lacrimalSystem ?? '';
    rightLacrimalController.text = rightMeas.lacrimalSystem ?? '';
    leftConjunctivaController.text = leftMeas.conjunctiva ?? '';
    rightConjunctivaController.text = rightMeas.conjunctiva ?? '';
    leftScleraController.text = leftMeas.sclera ?? '';
    rightScleraController.text = rightMeas.sclera ?? '';

    leftTopRightTapCount = leftMeas.topRight ?? 0;
    rightTopRightTapCount = rightMeas.topRight ?? 0;
    leftTopLeftTapCount = leftMeas.topLeft ?? 0;
    rightTopLeftTapCount = rightMeas.topLeft ?? 0;
    leftBottomLeftTapCount = leftMeas.bottomLeft ?? 0;
    rightBottomLeftTapCount = rightMeas.bottomLeft ?? 0;
    leftBottomRightTapCount = leftMeas.bottomRight ?? 0;
    rightBottomRightTapCount = rightMeas.bottomRight ?? 0;

    if (exam.history != null) {
      presentIllnessController.text = exam.history?.presentIllness ?? '';
      pastHistoryController.text = exam.history?.pastHistory ?? '';
      medicationHistoryController.text = exam.history?.medicationHistory ?? '';
      familyHistoryController.text = exam.history?.familyHistory ?? '';

      // Structured history round-trip (absent on legacy free-text-only docs).
      selectedHistoryCategories
        ..clear()
        ..addAll(exam.history?.selectedCategories ?? const []);
      historyValues
        ..clear()
        ..addAll(exam.history?.values ?? const {});
    }

    if (exam.complain != null) {
      oneComplaintController.text = exam.complain?.complainOne ?? '';
      twoComplaintController.text = exam.complain?.complainTwo ?? '';
      threeComplaintController.text = exam.complain?.complainThree ?? '';

      // Structured complain round-trip (absent on legacy free-text-only docs).
      selectedComplaints
        ..clear()
        ..addAll(exam.complain?.selectedComplaints ?? const []);
      complainValues
        ..clear()
        ..addAll(exam.complain?.values ?? const {});
    }

    emit(ExaminationFormUpdated());
  }

  void updateLeftEyeField(String field, dynamic value) {
    switch (field) {
      case 'oldSpherical':
        leftOldSpherical = value;
        break;
      case 'oldCylindrical':
        leftOldCylindrical = value;
        break;
      case 'oldAxis':
        leftOldAxis = value;
        break;
      case 'oldGlassesVa':
        leftOldGlassesVa = value;
        break;
      case 'aurorefSpherical':
        leftAurorefSpherical = value;
        break;
      case 'aurorefCylindrical':
        leftAurorefCylindrical = value;
        break;
      case 'aurorefAxis':
        leftAurorefAxis = value;
        break;
      case 'ucva':
        leftUCVA = value;
        break;
      case 'bcva':
        leftBCVA = value;
        break;
      case 'refinedRefractionSpherical':
        leftRefinedRefractionSpherical = value;
        break;
      case 'refinedRefractionCylindrical':
        leftRefinedRefractionCylindrical = value;
        break;
      case 'refinedRefractionAxis':
        leftRefinedRefractionAxis = value;
        break;
      case 'nearVisionAddition':
        leftNearVisionAddition = value;
        break;
      case 'iop':
        leftIOP = value;
        break;
      case 'meansOfMeasurement':
        leftMeansOfMeasurement = value;
        break;
      case 'acquireAnotherIOPMeasurement':
        leftAcquireAnotherIOPMeasurement = value;
        break;
      case 'pupilsShape':
        leftPupilsShape = value;
        break;
      case 'pupilsLightReflexTest':
        leftPupilsLightReflexTest = value;
        break;
      case 'exophthalmometry':
        leftExophthalmometry = value;
        break;
      case 'pupilsNearReflexTest':
        leftPupilsNearReflexTest = value;
        break;
      case 'pupilsSwingingFlashLightTest':
        leftPupilsSwingingFlashLightTest = value;
        break;
      case 'pupilsOtherDisorders':
        leftPupilsOtherDisorders = value;
        break;
      case 'eyelidPtosis':
        leftEyelidPtosis = value;
        break;
      case 'eyelidLagophthalmos':
        leftEyelidLagophthalmos = value;
        break;
      case 'palpableLymphNodes':
        leftPalpableLymphNodes = value;
        break;
      case 'papableTemporalArtery':
        leftPapableTemporalArtery = value;
        break;
      case 'cornea':
        leftCornea = value;
        break;
      case 'anteriorChambre':
        leftAnteriorChambre = value;
        break;
      case 'iris':
        leftIris = value;
        break;
      case 'lens':
        leftLens = value;
        break;
      case 'anteriorVitreous':
        leftAnteriorVitreous = value;
        break;
      case 'fundusOpticDisc':
        leftFundusOpticDisc = value;
        break;
      case 'fundusMacula':
        leftFundusMacula = value;
        break;
      case 'fundusVessels':
        leftFundusVessels = value;
        break;
      case 'fundusPeriphery':
        leftFundusPeriphery = value;
        break;
    }
    emit(ExaminationFormUpdated());
  }

  void updateRightEyeField(String field, dynamic value, {List? values}) {
    switch (field) {
      case 'oldSpherical':
        rightOldSpherical = value;
        break;
      case 'oldCylindrical':
        rightOldCylindrical = value;
        break;
      case 'oldAxis':
        rightOldAxis = value;
        break;
      case 'oldGlassesVa':
        rightOldGlassesVa = value;
        break;
      case 'aurorefSpherical':
        rightAurorefSpherical = value;
        break;
      case 'aurorefCylindrical':
        rightAurorefCylindrical = value;
        break;
      case 'aurorefAxis':
        rightAurorefAxis = value;
        break;
      case 'ucva':
        rightUCVA = value;
        break;
      case 'bcva':
        rightBCVA = value;
        break;
      case 'refinedRefractionSpherical':
        rightRefinedRefractionSpherical = value;
        break;
      case 'refinedRefractionCylindrical':
        rightRefinedRefractionCylindrical = value;
        break;
      case 'refinedRefractionAxis':
        rightRefinedRefractionAxis = value;
        break;
      case 'nearVisionAddition':
        rightNearVisionAddition = value;
        break;
      case 'iop':
        rightIOP = value;
        break;
      case 'meansOfMeasurement':
        rightMeansOfMeasurement = value;
        break;
      case 'acquireAnotherIOPMeasurement':
        rightAcquireAnotherIOPMeasurement = value;
        break;
      case 'pupilsShape':
        rightPupilsShape = value;
        break;
      case 'pupilsLightReflexTest':
        rightPupilsLightReflexTest = value;
        break;
      case 'pupilsNearReflexTest':
        rightPupilsNearReflexTest = value;
        break;
      case 'pupilsSwingingFlashLightTest':
        rightPupilsSwingingFlashLightTest = value;
        break;
      case 'pupilsOtherDisorders':
        rightPupilsOtherDisorders = value;
        break;
      case 'eyelidPtosis':
        rightEyelidPtosis = value;
        break;
      case 'eyelidLagophthalmos':
        rightEyelidLagophthalmos = value;
        break;
      case 'palpableLymphNodes':
        rightPalpableLymphNodes = value;
        break;
      case 'papableTemporalArtery':
        rightPapableTemporalArtery = value;
        break;
      case 'cornea':
        rightCornea = values ?? [];
        break;
      case 'anteriorChambre':
        rightAnteriorChambre = value;
        break;
      case 'iris':
        rightIris = value;
        break;
      case 'lens':
        rightLens = value;
        break;
      case 'anteriorVitreous':
        rightAnteriorVitreous = value;
        break;
      case 'fundusOpticDisc':
        rightFundusOpticDisc = value;
        break;
      case 'fundusMacula':
        rightFundusMacula = value;
        break;
      case 'fundusVessels':
        rightFundusVessels = value;
        break;
      case 'exophthalmometry':
        rightExophthalmometry = value;
        break;
      case 'fundusPeriphery':
        rightFundusPeriphery = value;
        break;
    }
    emit(ExaminationFormUpdated());
  }

  void leftTopLeftHandleTap() {
    leftTopLeftTapCount = (leftTopLeftTapCount + 1) % 3;
    emit(ExaminationFormUpdated());
  }

  void leftTopRightHandleTap() {
    leftTopRightTapCount = (leftTopRightTapCount + 1) % 3;
    emit(ExaminationFormUpdated());
  }

  void leftBottomLeftHandleTap() {
    leftBottomLeftTapCount = (leftBottomLeftTapCount + 1) % 3;
    emit(ExaminationFormUpdated());
  }

  void leftBottomRightHandleTap() {
    leftBottomRightTapCount = (leftBottomRightTapCount + 1) % 3;
    emit(ExaminationFormUpdated());
  }

  void rightTopLeftHandleTap() {
    rightTopLeftTapCount = (rightTopLeftTapCount + 1) % 3;
    emit(ExaminationFormUpdated());
  }

  void rightTopRightHandleTap() {
    rightTopRightTapCount = (rightTopRightTapCount + 1) % 3;
    emit(ExaminationFormUpdated());
  }

  void rightBottomLeftHandleTap() {
    rightBottomLeftTapCount = (rightBottomLeftTapCount + 1) % 3;
    emit(ExaminationFormUpdated());
  }

  void rightBottomRightHandleTap() {
    rightBottomRightTapCount = (rightBottomRightTapCount + 1) % 3;
    emit(ExaminationFormUpdated());
  }

  /// A measurement is only worth merging when it actually holds a reading —
  /// copying an unset autorefraction over a refined value the doctor already
  /// entered is what made Merge look like it had done nothing.
  static bool _hasReading(dynamic value) {
    if (value == null) return false;
    final text = value.toString().trim();
    return text.isNotEmpty && text != '-';
  }

  /// Copy autorefraction into refined refraction for one eye. Per-eye rather than
  /// both at once, matching the web form, so each side can be merged on its own.
  void mergeRefinedWithAuto({required bool isLeftEye}) {
    if (isLeftEye) {
      if (_hasReading(leftAurorefSpherical)) {
        leftRefinedRefractionSpherical = leftAurorefSpherical;
      }
      if (_hasReading(leftAurorefCylindrical)) {
        leftRefinedRefractionCylindrical = leftAurorefCylindrical;
      }
      if (_hasReading(leftAurorefAxis)) {
        leftRefinedRefractionAxis = leftAurorefAxis;
      }
    } else {
      if (_hasReading(rightAurorefSpherical)) {
        rightRefinedRefractionSpherical = rightAurorefSpherical;
      }
      if (_hasReading(rightAurorefCylindrical)) {
        rightRefinedRefractionCylindrical = rightAurorefCylindrical;
      }
      if (_hasReading(rightAurorefAxis)) {
        rightRefinedRefractionAxis = rightAurorefAxis;
      }
    }

    emit(ExaminationFormUpdated());
  }
}
