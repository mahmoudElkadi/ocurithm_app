import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';

import '../../../../../core/utils/colors.dart';
import '../../../../Branch/data/model/branches_model.dart' as branch;
import '../../../../Doctor/data/model/doctor_model.dart';
import '../../../data/models/appointment_model.dart' as model;
import '../../../data/repos/appointment_repo.dart';
import 'appointment_state.dart';

class AppointmentCubit extends Cubit<AppointmentState> {
  AppointmentCubit(this.appointmentRepo) : super(AppointmentInitial());

  static AppointmentCubit get(context) => BlocProvider.of(context);

  DateTime selectedDate = DateTime.now();

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

  branch.BranchesModel? branches;
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

  branch.Branch? selectedBranch;
  Doctor? selectedDoctor;

  Map<String, List<model.Appointment>>? groupedAppointments;
  model.AppointmentModel? appointments;
  getAppointments() async {
    appointments = null;
    emit(GetAppointmentLoading());
    connection = await InternetConnection().hasInternetAccess;
    emit(GetAppointmentLoading());
    try {
      if (connection == true) {
        appointments = await appointmentRepo.getAllAppointment(date: selectedDate, branch: selectedBranch?.id, doctor: selectedDoctor?.id);
        if (appointments?.error == null && appointments!.appointments.isNotEmpty) {
          // Group appointments by time slot
          groupedAppointments = AppointmentHelper.groupAppointmentsByTimeSlot(appointments!.appointments);

          emit(GetAppointmentSuccess());
        } else {
          emit(GetAppointmentError());
        }
      }
    } catch (e) {
      log(e.toString());
      loading = false;
      emit(GetAppointmentError());
    }
  }

  editAppointment({required BuildContext context, required String id, required String action, DateTime? date, String? doctor}) async {
    emit(EditAppointmentLoading());
    try {
      var result = await appointmentRepo.editAppointment(id: id, action: action, date: date, doctor: doctor);
      if (result != null && result.error == null) {
        Get.snackbar(
          "Success",
          "Appointment Updated successfully",
          backgroundColor: Colorz.primaryColor,
          colorText: Colorz.white,
          icon: Icon(Icons.check, color: Colorz.white),
        );
        int? index = appointments?.appointments.indexWhere((e) => e.id == id);
        if (index != null && index != -1) {
          appointments?.appointments[index].status = result.status;
        }
        Navigator.pop(context);
        Navigator.pop(context, true);
        emit(EditAppointmentSuccess());
      } else if (result != null && result.error != null) {
        Get.snackbar(
          result.error!,
          "Failed to $action appointment",
          backgroundColor: Colorz.errorColor,
          colorText: Colorz.white,
          icon: Icon(Icons.error, color: Colorz.white),
        );
        Navigator.pop(context);

        emit(EditAppointmentError());
      } else {
        Get.snackbar(
          "Error",
          "Failed to $action appointment",
          backgroundColor: Colorz.errorColor,
          colorText: Colorz.white,
          icon: Icon(Icons.error, color: Colorz.white),
        );
        Navigator.pop(context);
        emit(EditAppointmentError());
      }
    } catch (e) {
      emit(EditAppointmentError());
    }
  }

  DateTime? selectedTime;

  List<model.Appointment> get morningAppointments => groupedAppointments?['morning'] ?? [];

  List<model.Appointment> get afternoonAppointments => groupedAppointments?['afternoon'] ?? [];

  List<model.Appointment> get eveningAppointments => groupedAppointments?['evening'] ?? [];

  // Get count of appointments in a time slot
  int getAppointmentCount(String timeSlot) => groupedAppointments?[timeSlot]?.length ?? 0;
}

class AppointmentHelper {
  static Map<String, List<model.Appointment>> groupAppointmentsByTimeSlot(List<model.Appointment> appointments) {
    // Initialize empty lists for each time slot
    final Map<String, List<model.Appointment>> groupedAppointments = {
      'morning': [], // 00:00 - 11:59
      'afternoon': [], // 12:00 - 17:59
      'evening': [], // 18:00 - 23:59
    };

    for (var appointment in appointments) {
      if (appointment.datetime != null) {
        final hour = appointment.datetime!.hour;

        if (hour < 12) {
          groupedAppointments['morning']!.add(appointment);
        } else if (hour < 18) {
          groupedAppointments['afternoon']!.add(appointment);
        } else {
          groupedAppointments['evening']!.add(appointment);
        }
      }
    }

    // Sort appointments within each time slot
    groupedAppointments.forEach((_, appointments) {
      appointments.sort((a, b) => (a.datetime ?? DateTime.now()).compareTo(b.datetime ?? DateTime.now()));
    });

    return groupedAppointments;
  }
}
