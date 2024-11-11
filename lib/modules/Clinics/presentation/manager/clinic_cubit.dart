import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';
import 'package:ocurithm/core/utils/colors.dart';

import '../../data/model/clinics_model.dart';
import '../../data/repos/clinic_repo.dart';
import 'clinic_state.dart';

class ClinicCubit extends Cubit<ClinicState> {
  ClinicCubit(this.clinicRepo) : super(ClinicInitial());

  static ClinicCubit get(context) => BlocProvider.of(context);
  ClinicRepo clinicRepo;
  TextEditingController searchController = TextEditingController();

  addClinic({required Clinic clinic, context}) async {
    emit(ClinicLoading());
    try {
      final result = await clinicRepo.createClinic(
        clinic: clinic,
      );
      if (result.error == null && (result.name != null || result.id != null)) {
        Get.snackbar(
          "Success",
          "Clinic Added Successfully",
          backgroundColor: Colorz.primaryColor,
          colorText: Colorz.white,
          icon: Icon(Icons.check, color: Colorz.white),
        );
        Navigator.pop(context);
        Navigator.pop(context);

        clinics?.clinics!.add(Clinic(
          id: result.id,
          name: result.name,
          description: result.description,
        ));

        emit(ClinicSuccess());
      } else {
        Get.snackbar(
          "Error",
          result.error!,
          backgroundColor: Colorz.errorColor,
          colorText: Colorz.white,
          icon: Icon(Icons.error, color: Colorz.white),
        );
        Navigator.pop(context);

        emit(ClinicError());
      }
    } catch (e) {
      log(e.toString());
      Navigator.pop(context);

      emit(ClinicError());
    }
  }

  updateClinic({required String id, required Clinic clinic, context}) async {
    emit(ClinicLoading());
    try {
      final result = await clinicRepo.updateClinic(
        clinic: clinic,
        id: id,
      );
      if (result.error == null && (result.name != null || result.id != null)) {
        Get.snackbar(
          "Success",
          "Clinic Updated Successfully",
          backgroundColor: Colorz.primaryColor,
          colorText: Colorz.white,
          icon: Icon(Icons.check, color: Colorz.white),
        );
        Navigator.pop(context);
        Navigator.pop(context);

        final index = clinics?.clinics?.indexWhere((Clinic) => Clinic.id == id);
        if (index != -1) {
          clinics?.clinics?[index!].name = result.name;
          clinics?.clinics?[index!].description = result.description;
        }

        emit(ClinicSuccess());
      } else {
        Get.snackbar(
          "Error",
          result.error!,
          backgroundColor: Colorz.errorColor,
          colorText: Colorz.white,
          icon: Icon(Icons.error, color: Colorz.white),
        );
        Navigator.pop(context);

        emit(ClinicError());
      }
    } catch (e) {
      log(e.toString());
      Navigator.pop(context);

      emit(ClinicError());
    }
  }

  deleteClinic({required String id, context}) async {
    emit(ClinicLoading());
    try {
      final result = await clinicRepo.deleteClinic(
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

        clinics?.clinics?.removeWhere((clinic) => clinic.id == id);

        emit(ClinicSuccess());
      } else {
        Get.snackbar(
          "Error",
          result.error!,
          backgroundColor: Colorz.errorColor,
          colorText: Colorz.white,
          icon: Icon(Icons.error, color: Colorz.white),
        );
        Navigator.pop(context);

        emit(ClinicError());
      }
    } catch (e) {
      log(e.toString());
      Navigator.pop(context);

      emit(ClinicError());
    }
  }

  ClinicsModel? clinics;
  int page = 1;
  getClinics() async {
    clinics = null;
    emit(ClinicLoading());

    connection = await InternetConnection().hasInternetAccess;
    emit(ClinicLoading());
    try {
      if (connection == false) {
        Get.snackbar(
          "Error",
          "No Internet Connection",
          backgroundColor: Colorz.errorColor,
          colorText: Colorz.white,
          icon: Icon(Icons.error, color: Colorz.white),
        );
        emit(ClinicError());
      } else {
        clinics = await clinicRepo.getAllClinics(page: page, search: searchController.text);
        if (clinics?.error == null && clinics!.clinics!.isNotEmpty) {
          emit(ClinicSuccess());
        } else {
          emit(ClinicError());
        }
      }
    } catch (e) {
      log(e.toString());
      emit(ClinicError());
    }
  }

  Clinic? clinic;
  getClinic({required String id}) async {
    clinic = null;
    emit(ClinicLoading());
    connection = await InternetConnection().hasInternetAccess;
    emit(ClinicLoading());
    try {
      if (connection == false) {
        Get.snackbar(
          "Error",
          "No Internet Connection",
          backgroundColor: Colorz.errorColor,
          colorText: Colorz.white,
          icon: Icon(Icons.error, color: Colorz.white),
        );
        emit(ClinicError());
      } else {
        clinic = await clinicRepo.getClinic(id: id);
        if (clinic?.error == null) {
          emit(ClinicSuccess());
        } else {
          emit(ClinicError());
        }
      }
    } catch (e) {
      log(e.toString());
      emit(ClinicError());
    }
  }

  bool? connection;
}
