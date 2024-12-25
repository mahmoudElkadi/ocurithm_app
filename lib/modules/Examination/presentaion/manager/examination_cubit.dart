import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'examination_state.dart';

class ExaminationCubit extends Cubit<ExaminationState> {
  ExaminationCubit() : super(ExaminationInitial()) {}

  static ExaminationCubit get(context) => BlocProvider.of(context);
  final TextEditingController historyController = TextEditingController();
  final TextEditingController complaintController = TextEditingController();

  final int totalSteps = 4;

  int _currentStep = 0;
  int get currentStep => _currentStep;

  void nextStep() {
    if (_currentStep < totalSteps - 1) {
      _currentStep++;
      emit(ExaminationStepChanged());
    }
  }

  void previousStep() {
    if (_currentStep > 0) {
      _currentStep--;
      emit(ExaminationStepChanged());
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
      log(data.toString());
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

  // Additional Fields
  dynamic leftCornea;
  dynamic leftAnteriorChambre;
  dynamic leftIris;
  dynamic leftLens;
  dynamic leftAnteriorVitreous;

  // Fundus Examination
  dynamic leftFundusOpticDisc;
  dynamic leftFundusMacula;
  dynamic leftFundusVessels;
  dynamic leftFundusPeriphery;

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

  // Slitlamp Examination Controllers
  TextEditingController rightLidsController = TextEditingController();
  TextEditingController rightLashesController = TextEditingController();
  TextEditingController rightLacrimalController = TextEditingController();
  TextEditingController rightConjunctivaController = TextEditingController();
  TextEditingController rightScleraController = TextEditingController();

  // Additional Fields
  dynamic rightCornea;
  dynamic rightAnteriorChambre;
  dynamic rightIris;
  dynamic rightLens;
  dynamic rightAnteriorVitreous;

  // Fundus Examination
  dynamic rightFundusOpticDisc;
  dynamic rightFundusMacula;
  dynamic rightFundusVessels;
  dynamic rightFundusPeriphery;

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

    return super.close();
  }

  void updateLeftEyeField(String field, dynamic value) {
    log(value.toString());
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
        log("in");
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

  void updateRightEyeField(String field, dynamic value) {
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
        rightCornea = value;
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
      case 'fundusPeriphery':
        rightFundusPeriphery = value;

        emit(ChooseData());
    }
  }
}
