import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';
import 'package:ocurithm/core/utils/colors.dart';

import '../../data/model/examination_type_model.dart';
import '../../data/repos/examination_type_repo.dart';
import 'examination_type_state.dart';

class ExaminationTypeCubit extends Cubit<ExaminationTypeState> {
  ExaminationTypeCubit(this.examinationTypeRepo) : super(ExaminationTypeInitial());

  static ExaminationTypeCubit get(context) => BlocProvider.of(context);
  ExaminationTypeRepo examinationTypeRepo;
  TextEditingController searchController = TextEditingController();

  addExaminationType({required ExaminationType examinationType, context}) async {
    emit(ExaminationTypeLoading());
    try {
      final result = await examinationTypeRepo.createExaminationType(
        examinationType: examinationType,
      );
      if (result.error == null && (result.name != null || result.id != null)) {
        Get.snackbar(
          "Success",
          "ExaminationType Added Successfully",
          backgroundColor: Colorz.primaryColor,
          colorText: Colorz.white,
          icon: Icon(Icons.check, color: Colorz.white),
        );
        Navigator.pop(context);
        Navigator.pop(context);

        examinationTypes?.examinationTypes!.add(ExaminationType(
          id: result.id,
          name: result.name,
          price: result.price,
        ));

        emit(ExaminationTypeSuccess());
      } else {
        Get.snackbar(
          "Error",
          result.error!,
          backgroundColor: Colorz.errorColor,
          colorText: Colorz.white,
          icon: Icon(Icons.error, color: Colorz.white),
        );
        Navigator.pop(context);

        emit(ExaminationTypeError());
      }
    } catch (e) {
      log(e.toString());
      Navigator.pop(context);

      emit(ExaminationTypeError());
    }
  }

  updateExaminationType({required String id, required ExaminationType examinationType, context}) async {
    emit(ExaminationTypeLoading());
    try {
      final result = await examinationTypeRepo.updateExaminationType(
        examinationType: examinationType,
        id: id,
      );
      if (result.error == null && (result.name != null || result.id != null)) {
        Get.snackbar(
          "Success",
          "ExaminationType Updated Successfully",
          backgroundColor: Colorz.primaryColor,
          colorText: Colorz.white,
          icon: Icon(Icons.check, color: Colorz.white),
        );
        Navigator.pop(context);
        Navigator.pop(context);

        final index = examinationTypes?.examinationTypes?.indexWhere((ExaminationType) => ExaminationType.id == id);
        if (index != -1) {
          examinationTypes?.examinationTypes?[index!].name = result.name;
          examinationTypes?.examinationTypes?[index!].price = result.price;
        }

        emit(ExaminationTypeSuccess());
      } else {
        Get.snackbar(
          "Error",
          result.error!,
          backgroundColor: Colorz.errorColor,
          colorText: Colorz.white,
          icon: Icon(Icons.error, color: Colorz.white),
        );
        Navigator.pop(context);

        emit(ExaminationTypeError());
      }
    } catch (e) {
      log(e.toString());
      Navigator.pop(context);

      emit(ExaminationTypeError());
    }
  }

  deleteExaminationType({required String id, context}) async {
    emit(ExaminationTypeLoading());
    try {
      final result = await examinationTypeRepo.deleteExaminationType(
        id: id,
      );
      if (result.error == null && (result.message != null)) {
        Get.snackbar(
          "Success",
          result.message!,
          backgroundColor: Colorz.primaryColor,
          colorText: Colorz.white,
          icon: Icon(Icons.check, color: Colorz.white),
        );
        Navigator.pop(context);
        Navigator.pop(context);

        examinationTypes?.examinationTypes?.removeWhere((examinationType) => examinationType.id == id);

        emit(ExaminationTypeSuccess());
      } else {
        Get.snackbar(
          "Error",
          result.error!,
          backgroundColor: Colorz.errorColor,
          colorText: Colorz.white,
          icon: Icon(Icons.error, color: Colorz.white),
        );
        Navigator.pop(context);

        emit(ExaminationTypeError());
      }
    } catch (e) {
      log(e.toString());
      Navigator.pop(context);

      emit(ExaminationTypeError());
    }
  }

  ExaminationTypesModel? examinationTypes;
  int page = 1;
  getExaminationTypes() async {
    examinationTypes = null;
    emit(ExaminationTypeLoading());

    connection = await InternetConnection().hasInternetAccess;
    emit(ExaminationTypeLoading());
    try {
      if (connection == false) {
        Get.snackbar(
          "Error",
          "No Internet Connection",
          backgroundColor: Colorz.errorColor,
          colorText: Colorz.white,
          icon: Icon(Icons.error, color: Colorz.white),
        );
        emit(ExaminationTypeError());
      } else {
        examinationTypes = await examinationTypeRepo.getAllExaminationTypes(page: page, search: searchController.text);
        if (examinationTypes?.error == null && examinationTypes!.examinationTypes!.isNotEmpty) {
          emit(ExaminationTypeSuccess());
        } else {
          emit(ExaminationTypeError());
        }
      }
    } catch (e) {
      log(e.toString());
      emit(ExaminationTypeError());
    }
  }

  ExaminationType? examinationType;
  getExaminationType({required String id}) async {
    examinationType = null;
    emit(ExaminationTypeLoading());
    connection = await InternetConnection().hasInternetAccess;
    emit(ExaminationTypeLoading());
    try {
      if (connection == false) {
        Get.snackbar(
          "Error",
          "No Internet Connection",
          backgroundColor: Colorz.errorColor,
          colorText: Colorz.white,
          icon: Icon(Icons.error, color: Colorz.white),
        );
        emit(ExaminationTypeError());
      } else {
        examinationType = await examinationTypeRepo.getExaminationType(id: id);
        if (examinationType?.error == null) {
          emit(ExaminationTypeSuccess());
        } else {
          emit(ExaminationTypeError());
        }
      }
    } catch (e) {
      log(e.toString());
      emit(ExaminationTypeError());
    }
  }

  bool? connection;
}
