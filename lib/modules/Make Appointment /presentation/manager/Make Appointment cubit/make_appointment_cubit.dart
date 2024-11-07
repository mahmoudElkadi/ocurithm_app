import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';

import '../../../../../core/utils/colors.dart';
import '../../../../Branch/data/model/branches_model.dart';
import '../../../../Doctor/data/model/doctor_model.dart';
import '../../../../Examination Type/data/model/examination_type_model.dart';
import '../../../../Patient/data/model/patients_model.dart';
import '../../../../Payment Methods/data/model/payment_method_model.dart';
import '../../../data/repos/make_appointment_repo.dart';
import 'make_appointment_state.dart';

class MakeAppointmentCubit extends Cubit<MakeAppointmentState> {
  MakeAppointmentCubit(this.makeAppointmentRepo) : super(AppointmentInitial());

  static MakeAppointmentCubit get(context) => BlocProvider.of(context);

  bool? connection;
  MakeAppointmentRepo makeAppointmentRepo;
  DoctorModel? doctors;
  Future<void> getDoctors() async {
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
  Future<void> getBranches() async {
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

  PatientModel? patients;
  int page = 1;
  TextEditingController searchController = TextEditingController();
  Future<void> getPatients() async {
    patients = null;
    emit(AdminPatientLoading());

    connection = await InternetConnection().hasInternetAccess;
    emit(AdminPatientLoading());
    try {
      if (connection == false) {
        Get.snackbar(
          "Error",
          "No Internet Connection",
          backgroundColor: Colorz.errorColor,
          colorText: Colorz.white,
          icon: Icon(Icons.error, color: Colorz.white),
        );
        emit(AdminPatientError());
      } else {
        patients = await makeAppointmentRepo.getAllPatients(page: page, search: searchController.text);
        if (patients!.patients.isNotEmpty) {
          emit(AdminPatientSuccess());
        } else {
          emit(AdminPatientError());
        }
      }
    } catch (e) {
      log(e.toString());
      emit(AdminPatientError());
    }
  }

  PaymentMethodsModel? paymentMethods;
  Future<void> getPaymentMethods() async {
    paymentMethods = null;
    emit(PaymentMethodLoading());

    connection = await InternetConnection().hasInternetAccess;
    emit(PaymentMethodLoading());
    try {
      if (connection == false) {
        Get.snackbar(
          "Error",
          "No Internet Connection",
          backgroundColor: Colorz.errorColor,
          colorText: Colorz.white,
          icon: Icon(Icons.error, color: Colorz.white),
        );
        emit(PaymentMethodError());
      } else {
        paymentMethods = await makeAppointmentRepo.getAllPaymentMethods(page: page, search: searchController.text);
        if (paymentMethods?.error == null && paymentMethods!.paymentMethods!.isNotEmpty) {
          emit(PaymentMethodSuccess());
        } else {
          emit(PaymentMethodError());
        }
      }
    } catch (e) {
      log(e.toString());
      emit(PaymentMethodError());
    }
  }

  ExaminationTypesModel? examinationTypes;
  Future<void> getExaminationTypes() async {
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
        examinationTypes = await makeAppointmentRepo.getAllExaminationTypes(page: page, search: searchController.text);
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

  getAllData() async {
    await Future.wait([
      getBranches(),
      getExaminationTypes(),
      getPaymentMethods(),
      getPatients(),
      getDoctors(),
    ]);
  }
}
