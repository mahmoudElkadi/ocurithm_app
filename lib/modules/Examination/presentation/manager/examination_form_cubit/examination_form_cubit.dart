import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ocurithm/modules/Appointment/data/models/appointment_model.dart';
import 'package:ocurithm/modules/Examination/data/model/saved_Exam.dart'
    hide Appointment;

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

  // --- Left Eye Fields ---
  dynamic leftOldSpherical;
  dynamic leftOldCylindrical;
  dynamic leftOldAxis;
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
    return {
      "examinationMainData": {
        "clinic": appointmentData?.clinic?.id,
        "patient": appointmentData?.patient?.id,
        "appointment": appointmentData?.id,
        "type": appointmentData?.examinationType?.id,
        "action": action
      },
      "examinationHistory": {
        "familyHistory": familyHistoryController.text,
        "presentIllness": presentIllnessController.text,
        "pastHistory": pastHistoryController.text,
        "medicationHistory": medicationHistoryController.text,
      },
      "examinationComplain": {
        "complainOne": oneComplaintController.text,
        "complainTwo": twoComplaintController.text,
        "complainThree": threeComplaintController.text
      },
      "leftEyeMeasurement": {
        "eye": "Left",
        'oldSpherical': leftOldSpherical,
        'oldCylindrical': leftOldCylindrical,
        'oldAxis': leftOldAxis,
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

    rightOldSpherical = rightMeas.oldSpherical;
    rightOldCylindrical = rightMeas.oldCylindrical;
    rightOldAxis = rightMeas.oldAxis;

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
    }

    if (exam.complain != null) {
      oneComplaintController.text = exam.complain?.complainOne ?? '';
      twoComplaintController.text = exam.complain?.complainTwo ?? '';
      threeComplaintController.text = exam.complain?.complainThree ?? '';
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

  void mergeRefinedWithAuto() {
    leftRefinedRefractionSpherical = leftAurorefSpherical;
    leftRefinedRefractionCylindrical = leftAurorefCylindrical;
    leftRefinedRefractionAxis = leftAurorefAxis;

    rightRefinedRefractionSpherical = rightAurorefSpherical;
    rightRefinedRefractionCylindrical = rightAurorefCylindrical;
    rightRefinedRefractionAxis = rightAurorefAxis;
    emit(ExaminationFormUpdated());
  }
}
