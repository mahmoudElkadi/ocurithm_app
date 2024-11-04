import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';

import '../../../../../core/utils/colors.dart';
import '../../../../Branch/data/model/branches_model.dart';
import '../../../../Doctor/data/model/doctor_model.dart';
import '../../../data/repos/make_appointment_repo.dart';
import 'make_appointment_state.dart';

class MakeAppointmentCubit extends Cubit<MakeAppointmentState> {
  MakeAppointmentCubit(this.makeAppointmentRepo) : super(AppointmentInitial());

  static MakeAppointmentCubit get(context) => BlocProvider.of(context);

  bool? connection;
  MakeAppointmentRepo makeAppointmentRepo;
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
        doctors = await makeAppointmentRepo.getAllDoctors();
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
        branches = await makeAppointmentRepo.getAllBranches();
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
