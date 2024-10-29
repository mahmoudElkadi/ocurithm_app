import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';
import 'package:ocurithm/core/utils/colors.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../Branch/data/model/branches_model.dart';
import '../../data/model/doctor_model.dart';
import '../../data/repos/doctor_repo.dart';
import 'doctor_state.dart';

class DoctorCubit extends Cubit<DoctorState> {
  DoctorCubit(this.doctorRepo) : super(DoctorInitial());

  static DoctorCubit get(context) => BlocProvider.of(context);
  DoctorRepo doctorRepo;

  TextEditingController nameController = TextEditingController();
  TextEditingController phoneNumberController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController qualificationController = TextEditingController();
  bool readOnly = true;

  @override
  Future<void> close() {
    nameController.dispose();
    phoneNumberController.dispose();
    passwordController.dispose();
    return super.close();
  }

  bool isConfirm = false;
  var selectedBranch;
  chooseBranchId(selected) {
    log(selected.branchId.toString());
    selectedBranch = selected;
    emit(ChooseBranch());
  }

  DoctorModel? doctors;
  int page = 1;
  TextEditingController searchController = TextEditingController();
  getDoctors() async {
    doctors = null;
    emit(AdminBranchLoading());

    connection = await InternetConnection().hasInternetAccess;
    emit(AdminBranchLoading());
    try {
      if (connection == false) {
        Get.snackbar(
          "Error",
          "No Internet Connection",
          backgroundColor: Colorz.errorColor,
          colorText: Colorz.white,
          icon: Icon(Icons.error, color: Colorz.white),
        );
        emit(AdminBranchError());
      } else {
        doctors = await doctorRepo.getAllDoctors(page: page, search: searchController.text);
        if (doctors!.doctors!.isNotEmpty) {
          emit(AdminBranchSuccess());
        } else {
          emit(AdminBranchError());
        }
      }
    } catch (e) {
      log(e.toString());
      emit(AdminBranchError());
    }
  }

  Future<void> sendWhatsAppMessage(String phone, String message) async {
    // Ensure the phone number is formatted correctly for Egypt
    final formattedPhone = "20" + phone.replaceFirst(RegExp(r'^0'), '');

    final whatsappUrl = Uri.parse("whatsapp://send?phone=$formattedPhone&text=${Uri.encodeComponent(message)}");

    // Print URL for debugging purposes
    print("WhatsApp URL: $whatsappUrl");

    try {
      if (await canLaunch(whatsappUrl.toString())) {
        await launch(whatsappUrl.toString());
      } else {
        // Print error if canLaunch returns false
        print("WhatsApp is not installed or the URL scheme is not supported.");
        Get.snackbar(
          "WhatsApp not installed",
          "Please install WhatsApp to send messages.",
          padding: EdgeInsets.only(top: 30.h),
          colorText: Colorz.white,
          backgroundColor: Colors.red,
          icon: const Icon(Icons.error),
        );
      }
    } catch (e) {
      print("Error launching WhatsApp: $e");
      Get.snackbar(
        "Error",
        "Failed to launch WhatsApp.",
        padding: EdgeInsets.only(top: 30.h),
        colorText: Colorz.white,
        backgroundColor: Colors.red,
        icon: const Icon(Icons.error),
      );
    }
  }

  bool _obscureText = true;

  bool get obscureText => _obscureText;

  set obscureText(bool newState) {
    _obscureText = newState;
    emit(ObscureText());
  }

  DateTime? date;
  String? branchId;

  bool picDate = true;
  bool chooseBranch = true;
  bool isValidate = false;

  validateFirstPage() {
    if (date == null) {
      picDate = false;
    } else {
      picDate = true;
    }

    if (selectedBranch == null) {
      chooseBranch = false;
    } else {
      chooseBranch = true;
    }

    log(picDate.toString());
    log(chooseBranch.toString());

    if (picDate && chooseBranch) {
      log(isValidate.toString());
      isValidate = true;
    } else {
      isValidate = false;
    }

    emit(ValidateForm());
  }

  List<String> capabilitiesList = [];
  String? imageUrl;

  addDoctor({context}) async {
    emit(AddDoctorLoading());
    try {
      var result = await doctorRepo.createDoctor(
        doctor: Doctor(
            name: nameController.text,
            image: imageUrl,
            password: passwordController.text,
            phone: phoneNumberController.text,
            birthDate: date,
            branchId: branchId,
            qualifications: qualificationController.text,
            capabilities: capabilitiesList),
      );
      if (result.error == null && (result.name != null || result.id != null)) {
        Get.snackbar(
          "Success",
          "Doctor Added Successfully",
          backgroundColor: Colorz.primaryColor,
          colorText: Colorz.white,
          icon: Icon(Icons.check, color: Colorz.white),
        );
        Navigator.pop(context);
        Navigator.pop(context);

        doctors?.doctors?.add(Doctor(id: result.id, name: result.name, phone: result.phone, image: result.image));

        clearData();
        emit(AddDoctorSuccess());
      } else {
        Get.snackbar(
          "Error",
          result.error!,
          backgroundColor: Colorz.errorColor,
          colorText: Colorz.white,
          icon: Icon(Icons.error, color: Colorz.white),
        );
        Navigator.pop(context);

        emit(AddDoctorError());
      }
    } catch (e) {
      log(e.toString());
      Navigator.pop(context);

      emit(AddDoctorError());
    }
  }

  bool? connection;
  BranchesModel? branches;
  bool loading = false;
  getBranches() async {
    branches = null;
    loading = true;
    emit(AdminBranchLoading());

    connection = await InternetConnection().hasInternetAccess;
    emit(AdminBranchLoading());
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
        emit(AdminBranchError());
      } else {
        branches = await doctorRepo.getAllBranches();
        if (branches?.error == null && branches!.branches.isNotEmpty) {
          loading = false;
          emit(AdminBranchSuccess());
        } else {
          loading = false;
          emit(AdminBranchError());
        }
      }
    } catch (e) {
      log(e.toString());
      loading = false;
      emit(AdminBranchError());
    }
  }

  deleteDoctor({required String id, context}) async {
    emit(AdminBranchLoading());
    try {
      final result = await doctorRepo.deleteDoctor(
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

        doctors?.doctors?.removeWhere((Doctor) => Doctor.id == id);

        emit(AdminBranchSuccess());
      } else {
        Get.snackbar(
          "Error",
          result.error!,
          backgroundColor: Colorz.errorColor,
          colorText: Colorz.white,
          icon: Icon(Icons.error, color: Colorz.white),
        );
        Navigator.pop(context);

        emit(AdminBranchError());
      }
    } catch (e) {
      log(e.toString());
      Navigator.pop(context);

      emit(AdminBranchError());
    }
  }

  Doctor? doctor;
  getDoctor({required String id}) async {
    doctor = null;
    emit(AdminBranchLoading());
    connection = await InternetConnection().hasInternetAccess;
    emit(AdminBranchLoading());
    try {
      if (connection == false) {
        Get.snackbar(
          "Error",
          "No Internet Connection",
          backgroundColor: Colorz.errorColor,
          colorText: Colorz.white,
          icon: Icon(Icons.error, color: Colorz.white),
        );
        emit(AdminBranchError());
      } else {
        doctor = await doctorRepo.getDoctor(id: id);
        if (doctor?.error == null) {
          emit(AdminBranchSuccess());
        } else {
          emit(AdminBranchError());
        }
      }
    } catch (e) {
      log(e.toString());
      emit(AdminBranchError());
    }
  }

  updateDoctor({required String id, context}) async {
    emit(AdminBranchLoading());
    try {
      final result = await doctorRepo.updateDoctor(
        doctor: Doctor(
            name: nameController.text,
            image: imageUrl,
            password: passwordController.text,
            phone: phoneNumberController.text,
            birthDate: date,
            branchId: branchId,
            capabilities: capabilitiesList,
            qualifications: qualificationController.text),
        id: id,
      );
      if (result.error == null && (result.name != null || result.id != null)) {
        Get.snackbar(
          "Success",
          "Doctor Updated Successfully",
          backgroundColor: Colorz.primaryColor,
          colorText: Colorz.white,
          icon: Icon(Icons.check, color: Colorz.white),
        );
        Navigator.pop(context);
        Navigator.pop(context);

        final index = doctors?.doctors?.indexWhere((Doctor) => Doctor.id == id);
        if (index != -1) {
          doctors?.doctors?[index!].name = result.name;
          doctors?.doctors?[index!].image = result.image;
          doctors?.doctors?[index!].password = result.password;
          doctors?.doctors?[index!].phone = result.phone;
          doctors?.doctors?[index!].birthDate = result.birthDate;
          doctors?.doctors?[index!].branch = result.branch;
          doctors?.doctors?[index!].capabilities = result.capabilities;
        }

        emit(AdminBranchSuccess());
      } else {
        Get.snackbar(
          "Error",
          result.error!,
          backgroundColor: Colorz.errorColor,
          colorText: Colorz.white,
          icon: Icon(Icons.error, color: Colorz.white),
        );
        Navigator.pop(context);

        emit(AdminBranchError());
      }
    } catch (e) {
      log(e.toString());
      Navigator.pop(context);

      emit(AdminBranchError());
    }
  }

  clearData() {
    nameController.clear();
    imageUrl = null;
    passwordController.clear();
    phoneNumberController.clear();
    qualificationController.clear();
    date = null;
    branchId = null;
    capabilitiesList = [];
    selectedBranch = null;
    picDate = true;
    chooseBranch = true;
    isValidate = false;
  }
}
