import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';

import '../../../../core/utils/colors.dart';
import '../../../Appointment/data/models/appointment_model.dart';
import '../../data/repos/examination_repo.dart';
import '../views/widgets/prescription.dart';
import 'examination_state.dart';

class ExaminationCubit extends Cubit<ExaminationState> {
  ExaminationCubit(this.examinationRepo) : super(ExaminationInitial()) {}

  ExaminationRepo examinationRepo;
  static ExaminationCubit get(context) => BlocProvider.of(context);
  final TextEditingController familyHistoryController = TextEditingController();
  final TextEditingController presentIllnessController = TextEditingController();
  final TextEditingController pastHistoryController = TextEditingController();
  final TextEditingController medicationHistoryController = TextEditingController();
  final TextEditingController oneComplaintController = TextEditingController();
  final TextEditingController twoComplaintController = TextEditingController();
  final TextEditingController threeComplaintController = TextEditingController();
  final int totalSteps = 4;

  int _currentStep = 0;
  int get currentStep => _currentStep;

  void nextStep() {
    if (_currentStep < totalSteps - 1) {
      _currentStep++;
      emit(ExaminationStepChanged());
    }
    // else if (currentStep == 2){
    //   makeAppointment(context: context)
    // }
  }

  Appointment? appointmentData;

  void setAppointment(Appointment appointment) {
    appointmentData = appointment;
    emit(ExaminationStepChanged());
  }

  void previousStep() {
    if (_currentStep > 0) {
      _currentStep--;
      emit(ExaminationStepChanged());
    } else {
      Get.back();
    }
  }

  void goToStep(int step) {
    if (step >= 0 && step < totalSteps) {
      _currentStep = step;
      emit(ExaminationStepChanged());
    }
  }

  Map<String, dynamic> data = {};

  Future<void> readJson() async {
    try {
      final response = await rootBundle.loadString('assets/files/autoref.json');
      data = await json.decode(response);
      emit(ReadJson());
    } catch (e) {
      debugPrint('Error loading JSON: $e');
    }
  }

  dynamic leftAurorefSpherical;
  dynamic leftAurorefCylindrical;
  dynamic leftAurorefAxis;

  // Visual Acuity
  dynamic leftUCVA;
  dynamic leftBCVA;

  // Refined Refraction
  dynamic leftRefinedRefractionSpherical;
  dynamic leftRefinedRefractionCylindrical;
  dynamic leftRefinedRefractionAxis;
  dynamic leftNearVisionAddition;

  // IOP
  dynamic leftIOP;
  dynamic leftMeansOfMeasurement;
  dynamic leftAcquireAnotherIOPMeasurement;

  // Pupils
  dynamic leftPupilsShape;
  dynamic leftPupilsLightReflexTest;
  dynamic leftPupilsNearReflexTest;
  dynamic leftPupilsSwingingFlashLightTest;
  dynamic leftPupilsOtherDisorders;

  // External Examination
  dynamic leftEyelidPtosis;
  dynamic leftEyelidLagophthalmos;
  dynamic leftPalpableLymphNodes;
  dynamic leftPapableTemporalArtery;

  // Slitlamp Examination Controllers
  TextEditingController leftLidsController = TextEditingController();
  TextEditingController leftLashesController = TextEditingController();
  TextEditingController leftLacrimalController = TextEditingController();
  TextEditingController leftConjunctivaController = TextEditingController();
  TextEditingController leftScleraController = TextEditingController();
  TextEditingController leftShapeController = TextEditingController();
  TextEditingController rightShapeController = TextEditingController();

  // Additional Fields
  List leftCornea = [];
  List leftAnteriorChambre = [];
  List leftIris = [];
  List leftLens = [];
  List leftAnteriorVitreous = [];

  // Fundus Examination
  List leftFundusOpticDisc = [];
  List leftFundusMacula = [];
  List leftFundusVessels = [];
  List leftFundusPeriphery = [];
  dynamic leftExophthalmometry;

  //circle data

  int leftTopRightTapCount = 0;
  int leftTopLeftTapCount = 0;
  int leftBottomRightTapCount = 0;
  int leftBottomLeftTapCount = 0;

  // Right Eye Fields
  // Autoref
  dynamic rightAurorefSpherical;
  dynamic rightAurorefCylindrical;
  dynamic rightAurorefAxis;

  // Visual Acuity
  dynamic rightUCVA;
  dynamic rightBCVA;

  // Refined Refraction
  dynamic rightRefinedRefractionSpherical;
  dynamic rightRefinedRefractionCylindrical;
  dynamic rightRefinedRefractionAxis;
  dynamic rightNearVisionAddition;

  // IOP
  dynamic rightIOP;
  dynamic rightMeansOfMeasurement;
  dynamic rightAcquireAnotherIOPMeasurement;

  // Pupils
  dynamic rightPupilsShape;
  dynamic rightPupilsLightReflexTest;
  dynamic rightPupilsNearReflexTest;
  dynamic rightPupilsSwingingFlashLightTest;
  dynamic rightPupilsOtherDisorders;

  // External Examination
  dynamic rightEyelidPtosis;
  dynamic rightEyelidLagophthalmos;
  dynamic rightPalpableLymphNodes;
  dynamic rightPapableTemporalArtery;
  dynamic rightExophthalmometry;

  // Slitlamp Examination Controllers
  TextEditingController rightLidsController = TextEditingController();
  TextEditingController rightLashesController = TextEditingController();
  TextEditingController rightLacrimalController = TextEditingController();
  TextEditingController rightConjunctivaController = TextEditingController();
  TextEditingController rightScleraController = TextEditingController();

  // Additional Fields
  List rightCornea = [];
  List rightAnteriorChambre = [];
  List rightIris = [];
  List rightLens = [];
  List rightAnteriorVitreous = [];

  // circle data
  int rightTopRightTapCount = 0;
  int rightTopLeftTapCount = 0;
  int rightBottomRightTapCount = 0;
  int rightBottomLeftTapCount = 0;

  // Fundus Examination
  List rightFundusOpticDisc = [];
  List rightFundusMacula = [];
  List rightFundusVessels = [];
  List rightFundusPeriphery = [];
  @override
  Future<void> close() {
    // Dispose all controllers
    leftLidsController.dispose();
    leftLashesController.dispose();
    leftLacrimalController.dispose();
    leftConjunctivaController.dispose();
    leftScleraController.dispose();

    rightLidsController.dispose();
    rightLashesController.dispose();
    rightLacrimalController.dispose();
    rightConjunctivaController.dispose();
    rightScleraController.dispose();

    leftTopLeftTapCount = 0;
    leftTopRightTapCount = 0;
    leftBottomLeftTapCount = 0;
    leftBottomRightTapCount = 0;
    rightTopLeftTapCount = 0;
    rightTopRightTapCount = 0;
    rightBottomLeftTapCount = 0;
    rightBottomRightTapCount = 0;

    return super.close();
  }

  void updateLeftEyeField(String field, dynamic value) {
    switch (field) {
      case 'aurorefSpherical':
        leftAurorefSpherical = value;
        emit(ChooseData());
        break;
      case 'aurorefCylindrical':
        leftAurorefCylindrical = value;
        emit(ChooseData());
        break;
      case 'aurorefAxis':
        leftAurorefAxis = value;
        emit(ChooseData());
        break;
      case 'ucva':
        leftUCVA = value;
        emit(ChooseData());
        break;
      case 'bcva':
        leftBCVA = value;
        emit(ChooseData());
        break;
      case 'refinedRefractionSpherical':
        leftRefinedRefractionSpherical = value;
        emit(ChooseData());
        break;
      case 'refinedRefractionCylindrical':
        leftRefinedRefractionCylindrical = value;
        emit(ChooseData());
        break;
      case 'refinedRefractionAxis':
        leftRefinedRefractionAxis = value;
        emit(ChooseData());
        break;
      case 'nearVisionAddition':
        leftNearVisionAddition = value;
        emit(ChooseData());
        break;
      case 'iop':
        leftIOP = value;
        emit(ChooseData());
        break;
      case 'meansOfMeasurement':
        leftMeansOfMeasurement = value;
        emit(ChooseData());
        break;
      case 'acquireAnotherIOPMeasurement':
        leftAcquireAnotherIOPMeasurement = value;
        emit(ChooseData());
        break;
      case 'pupilsShape':
        leftPupilsShape = value;
        emit(ChooseData());
        break;
      case 'pupilsLightReflexTest':
        leftPupilsLightReflexTest = value;
        emit(ChooseData());
        break;
      case 'exophthalmometry':
        leftExophthalmometry = value;
        emit(ChooseData());
        break;
      case 'pupilsNearReflexTest':
        leftPupilsNearReflexTest = value;
        emit(ChooseData());
        break;
      case 'pupilsSwingingFlashLightTest':
        leftPupilsSwingingFlashLightTest = value;
        emit(ChooseData());
        break;
      case 'pupilsOtherDisorders':
        leftPupilsOtherDisorders = value;
        emit(ChooseData());
        break;
      case 'eyelidPtosis':
        leftEyelidPtosis = value;
        emit(ChooseData());
        break;
      case 'eyelidLagophthalmos':
        leftEyelidLagophthalmos = value;
        emit(ChooseData());
        break;
      case 'palpableLymphNodes':
        leftPalpableLymphNodes = value;
        emit(ChooseData());
        break;
      case 'papableTemporalArtery':
        leftPapableTemporalArtery = value;
        emit(ChooseData());
        break;
      case 'cornea':
        leftCornea = value;
        emit(ChooseData());
        break;
      case 'anteriorChambre':
        leftAnteriorChambre = value;
        emit(ChooseData());
        break;
      case 'iris':
        leftIris = value;
        emit(ChooseData());
        break;
      case 'lens':
        leftLens = value;
        emit(ChooseData());
        break;
      case 'anteriorVitreous':
        leftAnteriorVitreous = value;
        emit(ChooseData());
        break;
      case 'fundusOpticDisc':
        leftFundusOpticDisc = value;
        emit(ChooseData());
        break;
      case 'fundusMacula':
        leftFundusMacula = value;
        emit(ChooseData());
        break;
      case 'fundusVessels':
        leftFundusVessels = value;
        emit(ChooseData());
        break;
      case 'fundusPeriphery':
        leftFundusPeriphery = value;
        emit(ChooseData());
        break;
    }
  }

  void updateRightEyeField(String field, dynamic value, {List? values}) {
    switch (field) {
      case 'aurorefSpherical':
        rightAurorefSpherical = value;
        emit(ChooseData());
        break;
      case 'aurorefCylindrical':
        rightAurorefCylindrical = value;
        emit(ChooseData());
        break;
      case 'aurorefAxis':
        rightAurorefAxis = value;
        emit(ChooseData());
        break;
      case 'ucva':
        rightUCVA = value;
        emit(ChooseData());
        break;
      case 'bcva':
        rightBCVA = value;
        emit(ChooseData());
        break;
      case 'refinedRefractionSpherical':
        rightRefinedRefractionSpherical = value;
        emit(ChooseData());
        break;
      case 'refinedRefractionCylindrical':
        rightRefinedRefractionCylindrical = value;
        emit(ChooseData());
        break;
      case 'refinedRefractionAxis':
        rightRefinedRefractionAxis = value;
        emit(ChooseData());
        break;
      case 'nearVisionAddition':
        rightNearVisionAddition = value;
        emit(ChooseData());
        break;
      case 'iop':
        rightIOP = value;
        emit(ChooseData());
        break;
      case 'meansOfMeasurement':
        rightMeansOfMeasurement = value;
        emit(ChooseData());
        break;
      case 'acquireAnotherIOPMeasurement':
        rightAcquireAnotherIOPMeasurement = value;
        emit(ChooseData());
        break;
      case 'pupilsShape':
        rightPupilsShape = value;
        emit(ChooseData());
        break;
      case 'pupilsLightReflexTest':
        rightPupilsLightReflexTest = value;
        emit(ChooseData());
        break;
      case 'pupilsNearReflexTest':
        rightPupilsNearReflexTest = value;
        emit(ChooseData());
        break;
      case 'pupilsSwingingFlashLightTest':
        rightPupilsSwingingFlashLightTest = value;
        emit(ChooseData());
        break;
      case 'pupilsOtherDisorders':
        rightPupilsOtherDisorders = value;
        emit(ChooseData());
        break;
      case 'eyelidPtosis':
        rightEyelidPtosis = value;
        emit(ChooseData());
        break;
      case 'eyelidLagophthalmos':
        rightEyelidLagophthalmos = value;
        emit(ChooseData());
        break;
      case 'palpableLymphNodes':
        rightPalpableLymphNodes = value;
        emit(ChooseData());
        break;
      case 'papableTemporalArtery':
        rightPapableTemporalArtery = value;
        emit(ChooseData());
        break;
      case 'cornea':
        rightCornea = values ?? [];
        emit(ChooseData());
        break;
      case 'anteriorChambre':
        rightAnteriorChambre = value;
        emit(ChooseData());
        break;
      case 'iris':
        rightIris = value;
        emit(ChooseData());
        break;
      case 'lens':
        rightLens = value;
        emit(ChooseData());
        break;
      case 'anteriorVitreous':
        rightAnteriorVitreous = value;
        emit(ChooseData());
        break;
      case 'fundusOpticDisc':
        rightFundusOpticDisc = value;
        emit(ChooseData());
        break;
      case 'fundusMacula':
        rightFundusMacula = value;
        emit(ChooseData());
        break;
      case 'fundusVessels':
        rightFundusVessels = value;
        emit(ChooseData());
        break;
      case 'exophthalmometry':
        rightExophthalmometry = value;
        emit(ChooseData());
        break;
      case 'fundusPeriphery':
        rightFundusPeriphery = value;

        emit(ChooseData());
    }
  }

  void leftTopLeftHandleTap() {
    leftTopLeftTapCount = (leftTopLeftTapCount + 1) % 3;

    emit(CircleDateChanged());
  }

  void leftTopRightHandleTap() {
    leftTopRightTapCount = (leftTopRightTapCount + 1) % 3;
    emit(CircleDateChanged());
  }

  void leftBottomLeftHandleTap() {
    leftBottomLeftTapCount = (leftBottomLeftTapCount + 1) % 3;
    emit(CircleDateChanged());
  }

  void leftBottomRightHandleTap() {
    leftBottomRightTapCount = (leftBottomRightTapCount + 1) % 3;
    emit(CircleDateChanged());
  }

  void rightTopLeftHandleTap() {
    rightTopLeftTapCount = (rightTopLeftTapCount + 1) % 3;
    emit(CircleDateChanged());
  }

  void rightTopRightHandleTap() {
    rightTopRightTapCount = (rightTopRightTapCount + 1) % 3;
    emit(CircleDateChanged());
  }

  void rightBottomLeftHandleTap() {
    rightBottomLeftTapCount = (rightBottomLeftTapCount + 1) % 3;
    emit(CircleDateChanged());
  }

  void rightBottomRightHandleTap() {
    rightBottomRightTapCount = (rightBottomRightTapCount + 1) % 3;
    emit(CircleDateChanged());
  }

  Map<String, dynamic> examinationData() {
    data = {
      "examinationMainData": {
        "clinic": appointmentData?.clinic?.id,
        "patient": appointmentData?.patient?.id,
        "appointment": appointmentData?.id,
        "type": appointmentData?.examinationType?.id
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
        "pupilsShape": leftPupilsShape == "others" ? leftShapeController.text : leftPupilsShape,
        "pupilsLightReflexTest": leftPupilsLightReflexTest,
        "pupilsNearReflexTest": leftPupilsNearReflexTest,
        "pupilsSwingingFlashLightTest": leftPupilsSwingingFlashLightTest,
        "pupilsOtherDisorders": leftPupilsOtherDisorders,
        "eyelidPtosis": leftEyelidPtosis,
        "eyelidLagophthalmos": leftEyelidLagophthalmos,
        "palpableLymphNodes": leftPalpableLymphNodes,
        "palpableTemporalArtery": leftPapableTemporalArtery,
        "exophthalmometry": leftExophthalmometry,
        "cornea": rightCornea,
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
        "pupilsShape": rightPupilsShape == "others" ? rightShapeController.text : rightPupilsShape,
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
    return data;
  }

  makeExamination({required BuildContext context}) async {
    emit(MakeExaminationLoading());
    try {
      var result = await examinationRepo.makeExamination(data: examinationData());
      if (result.message != null && result.error == null) {
        Get.snackbar(
          "Success",
          result.message!,
          backgroundColor: Colorz.primaryColor,
          colorText: Colorz.white,
          icon: Icon(Icons.check, color: Colorz.white),
        );

        Navigator.pop(context);
        Get.to(() => MedicalTreeForm(
              examination: result.examination,
              doctor: result.doctor,
            ));
        emit(MakeExaminationSuccess());
      } else if (result != null && result.error != null) {
        Get.snackbar(
          result.error!,
          "Failed to create Examination",
          backgroundColor: Colorz.errorColor,
          colorText: Colorz.white,
          icon: Icon(Icons.error, color: Colorz.white),
        );
        Navigator.pop(context);
        emit(MakeExaminationError());
      } else {
        Get.snackbar(
          "Error",
          "Failed to create Examination",
          backgroundColor: Colorz.errorColor,
          colorText: Colorz.white,
          icon: Icon(Icons.error, color: Colorz.white),
        );
        Navigator.pop(context);

        emit(MakeExaminationError());
      }
    } catch (e) {
      Get.snackbar(
        "Error",
        "Failed to create Examination",
        backgroundColor: Colorz.errorColor,
        colorText: Colorz.white,
        icon: Icon(Icons.error, color: Colorz.white),
      );
      Navigator.pop(context);
      emit(MakeExaminationError());
    }
  }

  makeFinalization({required BuildContext context, required String id, required Map<String, dynamic> data}) async {
    emit(MakeFinalizationLoading());
    try {
      var result = await examinationRepo.makeFinalization(id: id, data: data);
      if (result.message != null && result.error == null) {
        Get.snackbar(
          "Success",
          result.message!,
          backgroundColor: Colorz.primaryColor,
          colorText: Colorz.white,
          icon: Icon(Icons.check, color: Colorz.white),
        );

        Navigator.pop(context, true);
        Navigator.pop(context, true);
        Navigator.pop(context, true);
        Navigator.pop(context, true);

        emit(MakeFinalizationSuccess());
      } else if (result != null && result.error != null) {
        Get.snackbar(
          result.error!,
          "Failed to create Examination",
          backgroundColor: Colorz.errorColor,
          colorText: Colorz.white,
          icon: Icon(Icons.error, color: Colorz.white),
        );
        Navigator.pop(context);
        emit(MakeFinalizationError());
      } else {
        Get.snackbar(
          "Error",
          "Failed to create Finalization",
          backgroundColor: Colorz.errorColor,
          colorText: Colorz.white,
          icon: Icon(Icons.error, color: Colorz.white),
        );
        Navigator.pop(context);

        emit(MakeFinalizationError());
      }
    } catch (e) {
      Get.snackbar(
        "Error",
        "Failed to create Finalization",
        backgroundColor: Colorz.errorColor,
        colorText: Colorz.white,
        icon: Icon(Icons.error, color: Colorz.white),
      );
      Navigator.pop(context);
      emit(MakeFinalizationError());
    }
  }
}
