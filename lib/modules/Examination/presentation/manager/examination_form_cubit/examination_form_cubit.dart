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
    if (oneExamination.examination == null ||
        oneExamination.examination!.examination.isEmpty) return;

    final exam = oneExamination.examination!.examination[0];

    leftOldSpherical = exam.measurements[0].oldSpherical;
    leftOldCylindrical = exam.measurements[0].oldCylindrical;
    leftOldAxis = exam.measurements[0].oldAxis;

    rightOldSpherical = exam.measurements[1].oldSpherical;
    rightOldCylindrical = exam.measurements[1].oldCylindrical;
    rightOldAxis = exam.measurements[1].oldAxis;

    leftAurorefSpherical = exam.measurements[0].autorefSpherical;
    leftAurorefCylindrical = exam.measurements[0].autorefCylindrical;
    leftAurorefAxis = exam.measurements[0].autorefAxis;

    rightAurorefSpherical = exam.measurements[1].autorefSpherical;
    rightAurorefCylindrical = exam.measurements[1].autorefCylindrical;
    rightAurorefAxis = exam.measurements[1].autorefAxis;

    leftRefinedRefractionSpherical =
        exam.measurements[0].refinedRefractionSpherical;
    leftRefinedRefractionCylindrical =
        exam.measurements[0].refinedRefractionCylindrical;
    leftRefinedRefractionAxis = exam.measurements[0].refinedRefractionAxis;
    leftNearVisionAddition = exam.measurements[0].nearVisionAddition;

    rightRefinedRefractionSpherical =
        exam.measurements[1].refinedRefractionSpherical;
    rightRefinedRefractionCylindrical =
        exam.measurements[1].refinedRefractionCylindrical;
    rightRefinedRefractionAxis = exam.measurements[1].refinedRefractionAxis;
    rightNearVisionAddition = exam.measurements[1].nearVisionAddition;

    leftUCVA = exam.measurements[0].ucva;
    rightUCVA = exam.measurements[1].ucva;
    leftBCVA = exam.measurements[0].bcva;
    rightBCVA = exam.measurements[1].bcva;

    leftIOP = exam.measurements[0].iop;
    rightIOP = exam.measurements[1].iop;
    leftMeansOfMeasurement = exam.measurements[0].meansOfMeasurement;
    rightMeansOfMeasurement = exam.measurements[1].meansOfMeasurement;
    leftAcquireAnotherIOPMeasurement =
        exam.measurements[0].acquireAnotherIopMeasurement;
    rightAcquireAnotherIOPMeasurement =
        exam.measurements[1].acquireAnotherIopMeasurement;

    leftPupilsShape = exam.measurements[0].pupilsShape;
    rightPupilsShape = exam.measurements[1].pupilsShape;
    leftPupilsLightReflexTest = exam.measurements[0].pupilsLightReflexTest;
    rightPupilsLightReflexTest = exam.measurements[1].pupilsLightReflexTest;
    leftPupilsNearReflexTest = exam.measurements[0].pupilsNearReflexTest;
    rightPupilsNearReflexTest = exam.measurements[1].pupilsNearReflexTest;
    leftPupilsSwingingFlashLightTest =
        exam.measurements[0].pupilsSwingingFlashLightTest;
    rightPupilsSwingingFlashLightTest =
        exam.measurements[1].pupilsSwingingFlashLightTest;
    leftPupilsOtherDisorders = exam.measurements[0].pupilsOtherDisorders;
    rightPupilsOtherDisorders = exam.measurements[1].pupilsOtherDisorders;

    leftEyelidPtosis = exam.measurements[0].eyelidPtosis;
    rightEyelidPtosis = exam.measurements[1].eyelidPtosis;
    leftEyelidLagophthalmos = exam.measurements[0].eyelidLagophthalmos;
    rightEyelidLagophthalmos = exam.measurements[1].eyelidLagophthalmos;
    leftPalpableLymphNodes = exam.measurements[0].palpableLymphNodes;
    rightPalpableLymphNodes = exam.measurements[1].palpableLymphNodes;
    leftPapableTemporalArtery = exam.measurements[0].palpableTemporalArtery;
    rightPapableTemporalArtery = exam.measurements[1].palpableTemporalArtery;
    leftExophthalmometry = exam.measurements[0].exophthalmometry;
    rightExophthalmometry = exam.measurements[1].exophthalmometry;

    leftCornea = exam.measurements[0].cornea;
    rightCornea = exam.measurements[1].cornea;
    leftAnteriorChambre = exam.measurements[0].anteriorChamber;
    rightAnteriorChambre = exam.measurements[1].anteriorChamber;
    leftIris = exam.measurements[0].iris;
    rightIris = exam.measurements[1].iris;
    leftLens = exam.measurements[0].lens;
    rightLens = exam.measurements[1].lens;
    leftAnteriorVitreous = exam.measurements[0].anteriorVitreous;
    rightAnteriorVitreous = exam.measurements[1].anteriorVitreous;

    leftFundusOpticDisc = exam.measurements[0].fundusOpticDisc;
    rightFundusOpticDisc = exam.measurements[1].fundusOpticDisc;
    leftFundusMacula = exam.measurements[0].fundusMacula;
    rightFundusMacula = exam.measurements[1].fundusMacula;
    leftFundusVessels = exam.measurements[0].fundusVessels;
    rightFundusVessels = exam.measurements[1].fundusVessels;
    leftFundusPeriphery = exam.measurements[0].fundusPeriphery;
    rightFundusPeriphery = exam.measurements[1].fundusPeriphery;

    leftLidsController.text = exam.measurements[0].lids ?? '';
    rightLidsController.text = exam.measurements[1].lids ?? '';
    leftLashesController.text = exam.measurements[0].lashes ?? '';
    rightLashesController.text = exam.measurements[1].lashes ?? '';
    leftLacrimalController.text = exam.measurements[0].lacrimalSystem ?? '';
    rightLacrimalController.text = exam.measurements[1].lacrimalSystem ?? '';
    leftConjunctivaController.text = exam.measurements[0].conjunctiva ?? '';
    rightConjunctivaController.text = exam.measurements[1].conjunctiva ?? '';
    leftScleraController.text = exam.measurements[0].sclera ?? '';
    rightScleraController.text = exam.measurements[1].sclera ?? '';

    leftTopRightTapCount = exam.measurements[0].topRight ?? 0;
    rightTopRightTapCount = exam.measurements[1].topRight ?? 0;
    leftTopLeftTapCount = exam.measurements[0].topLeft ?? 0;
    rightTopLeftTapCount = exam.measurements[1].topLeft ?? 0;
    leftBottomLeftTapCount = exam.measurements[0].bottomLeft ?? 0;
    rightBottomLeftTapCount = exam.measurements[1].bottomLeft ?? 0;
    leftBottomRightTapCount = exam.measurements[0].bottomRight ?? 0;
    rightBottomRightTapCount = exam.measurements[1].bottomRight ?? 0;

    presentIllnessController.text = exam.history?.presentIllness ?? '';
    pastHistoryController.text = exam.history?.pastHistory ?? '';
    medicationHistoryController.text = exam.history?.medicationHistory ?? '';
    familyHistoryController.text = exam.history?.familyHistory ?? '';

    oneComplaintController.text = exam.complain?.complainOne ?? '';
    twoComplaintController.text = exam.complain?.complainTwo ?? '';
    threeComplaintController.text = exam.complain?.complainThree ?? '';

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
