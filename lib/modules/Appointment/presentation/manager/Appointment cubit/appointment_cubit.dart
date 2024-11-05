import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';

import '../../../../../core/utils/colors.dart';
import '../../../../Branch/data/model/branches_model.dart';
import '../../../../Doctor/data/model/doctor_model.dart';
import '../../../data/repos/appointment_repo.dart';
import 'appointment_state.dart';

class AppointmentCubit extends Cubit<AppointmentState> {
  AppointmentCubit(this.appointmentRepo) : super(AppointmentInitial());

  static AppointmentCubit get(context) => BlocProvider.of(context);

  bool? connection;
  AppointmentRepo appointmentRepo;
  DoctorModel? doctors;
  getDoctors() async {
    doctors = null;
    emit(AdminDoctorLoading());

    connection = await InternetConnection().hasInternetAccess;
    emit(AdminDoctorLoading());
    try {
      if (connection == false) {
        Get.snackbar(
          "Error",
          "No Internet Connection",
          backgroundColor: Colorz.errorColor,
          colorText: Colorz.white,
          icon: Icon(Icons.error, color: Colorz.white),
        );
        emit(AdminDoctorError());
      } else {
        doctors = await appointmentRepo.getAllDoctors();
        if (doctors!.doctors!.isNotEmpty) {
          emit(AdminDoctorSuccess());
        } else {
          emit(AdminDoctorError());
        }
      }
    } catch (e) {
      log(e.toString());
      emit(AdminDoctorError());
    }
  }

  BranchesModel? branches;
  bool loading = false;
  getBranches() async {
    branches = null;
    loading = true;
    emit(GetBranchLoading());

    connection = await InternetConnection().hasInternetAccess;
    emit(GetBranchLoading());
    try {
      if (connection == false) {
        Get.snackbar(
          "Error",
          "No Internet Connection",
          backgroundColor: Colorz.errorColor,
          colorText: Colorz.white,
          icon: Icon(Icons.error, color: Colorz.white),
        );
        loading = false;
        emit(GetBranchError());
      } else {
        branches = await appointmentRepo.getAllBranches();
        if (branches?.error == null && branches!.branches.isNotEmpty) {
          loading = false;
          emit(GetBranchSuccess());
        } else {
          loading = false;
          emit(GetBranchError());
        }
      }
    } catch (e) {
      log(e.toString());
      loading = false;
      emit(GetBranchError());
    }
  }

  BranchesModel? appointments;
  getAppointments() async {
    appointments = null;
    emit(GetBranchLoading());
    connection = await InternetConnection().hasInternetAccess;
    emit(GetBranchLoading());
    try {
      if (connection == true) {
        branches = await appointmentRepo.getAllAppointment();
        if (branches?.error == null && branches!.branches.isNotEmpty) {
          loading = false;
          emit(GetBranchSuccess());
        } else {
          loading = false;
          emit(GetBranchError());
        }
      }
    } catch (e) {
      log(e.toString());
      loading = false;
      emit(GetBranchError());
    }
  }
}
