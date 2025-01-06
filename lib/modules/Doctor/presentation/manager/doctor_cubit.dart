import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';
import 'package:ocurithm/core/utils/colors.dart';
import 'package:ocurithm/modules/Doctor/data/model/capability_model.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../Services/services_api.dart';
import '../../../Branch/data/model/branches_model.dart';
import '../../../Clinics/data/model/clinics_model.dart';
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
  List<String> availableDays = [];
  String availableFrom = "";
  String availableTo = "";
  Branch? selectedBranch;
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
        doctors = await doctorRepo.getAllDoctors(page: page, search: searchController.text, clinic: filterByClinic?.id, branch: filterByBranch?.id);
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

  bool chooseClinic = true;
  bool isValidate = false;

  validateFirstPage() {
    if (date == null) {
      picDate = false;
    } else {
      picDate = true;
    }

    if (selectedClinic == null) {
      chooseClinic = false;
    } else {
      chooseClinic = true;
    }

    if (picDate && chooseClinic) {
      log(isValidate.toString());
      isValidate = true;
    } else {
      isValidate = false;
    }

    emit(ValidateForm());
  }

  ClinicsModel? clinics;
  Future getClinics() async {
    clinics = null;
    emit(AdminClinicLoading());

    connection = await InternetConnection().hasInternetAccess;
    emit(AdminClinicLoading());
    try {
      if (connection == false) {
        Get.snackbar(
          "Error",
          "No Internet Connection",
          backgroundColor: Colorz.errorColor,
          colorText: Colorz.white,
          icon: Icon(Icons.error, color: Colorz.white),
        );
        emit(AdminClinicError());
      } else {
        clinics = await ServicesApi().getAllClinics(page: page, search: searchController.text);
        log(clinics.toString());
        if (clinics?.error == null && clinics!.clinics.isNotEmpty) {
          emit(AdminClinicSuccess());
        } else {
          emit(AdminClinicError());
        }
      }
    } catch (e) {
      log(e.toString());
      emit(AdminClinicError());
    }
  }

  CapabilityModel? capabilities;
  Future getCapabilities() async {
    clinics = null;
    emit(GetCapabilityLoading());

    connection = await InternetConnection().hasInternetAccess;
    emit(GetCapabilityLoading());
    try {
      if (connection == false) {
        Get.snackbar(
          "Error",
          "No Internet Connection",
          backgroundColor: Colorz.errorColor,
          colorText: Colorz.white,
          icon: Icon(Icons.error, color: Colorz.white),
        );
        emit(GetCapabilitiesError());
      } else {
        capabilities = await ServicesApi().getAllCapability();
        emit(GetCapabilitySuccess());
      }
    } catch (e) {
      log(e.toString());
      emit(GetCapabilitiesError());
    }
  }

  List<String?> capabilitiesList = [];
  String? imageUrl;
  Clinic? selectedClinic;

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
          qualifications: qualificationController.text,
          clinic: selectedClinic,
        ),
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

        doctors?.doctors?.add(Doctor(
          id: result.id,
          name: result.name,
          phone: result.phone,
          image: result.image,
        ));

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

  addBranch({context, required String doctorId, required String branchId}) async {
    emit(AddBranchLoading());
    try {
      var result = await doctorRepo.addBranch(
          doctorId: doctorId, branchId: branchId, availableFrom: availableFrom, availableTo: availableTo, availableDays: availableDays);
      if (result.error == null && (result.name != null || result.id != null)) {
        Get.snackbar(
          "Success",
          "Branch Added Successfully",
          backgroundColor: Colorz.primaryColor,
          colorText: Colorz.white,
          icon: Icon(Icons.check, color: Colorz.white),
        );
        Navigator.pop(context);
        Navigator.pop(context);

        doctor = result;
        emit(AddBranchSuccess());
      } else {
        Get.snackbar(
          "Error",
          result.error!,
          backgroundColor: Colorz.errorColor,
          colorText: Colorz.white,
          icon: Icon(Icons.error, color: Colorz.white),
        );
        Navigator.pop(context);

        emit(AddBranchError());
      }
    } catch (e) {
      log(e.toString());
      Navigator.pop(context);

      emit(AddBranchError());
    }
  }

  deleteBranch({context, required String doctorId, required String branchId}) async {
    emit(DeleteBranchLoading());
    // try {
    var result = await doctorRepo.deleteBranch(doctorId: doctorId, branchId: branchId);
    log(result.toJson().toString());
    if (result.error == null && (result.name != null || result.id != null)) {
      Get.snackbar(
        "Success",
        "Branch Deleted Successfully",
        backgroundColor: Colorz.primaryColor,
        colorText: Colorz.white,
        icon: Icon(Icons.check, color: Colorz.white),
      );
      Navigator.pop(context);
      Navigator.pop(context);

      doctor = result;
      emit(DeleteBranchSuccess());
    } else {
      Get.snackbar(
        "Error",
        result.error ?? "Something went wrong",
        backgroundColor: Colorz.errorColor,
        colorText: Colorz.white,
        icon: Icon(Icons.error, color: Colorz.white),
      );
      Navigator.pop(context);

      emit(DeleteBranchError());
    }
    // } catch (e) {
    //   log(e.toString());
    //   Navigator.pop(context);
    //
    //   emit(DeleteBranchError());
    // }
  }

  bool? connection;
  BranchesModel? branches;

  Clinic? filterByClinic;
  Branch? filterByBranch;

  bool loading = false;
  Future getBranches({String? clinic}) async {
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
        branches = await ServicesApi().getAllBranches(clinic: clinic ?? selectedClinic?.id);
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
            clinic: selectedClinic,
            capability: capabilitiesList,
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
        readOnly = true;
        doctor?.clinic = result.clinic;
        doctor?.capabilities = result.capabilities;
        doctor?.birthDate = result.birthDate;
        doctor?.image = result.image;
        doctor?.name = result.name;
        doctor?.phone = result.phone;

        emit(AdminBranchSuccess());

        final index = doctors?.doctors?.indexWhere((Doctor) => Doctor.id == id);
        if (index != -1) {
          doctors?.doctors[index!].name = result.name;
          doctors?.doctors[index!].image = result.image;
          doctors?.doctors[index!].clinic = result.clinic;
          doctors?.doctors[index!].password = result.password;
          doctors?.doctors[index!].phone = result.phone;
          doctors?.doctors[index!].birthDate = result.birthDate;
          doctors?.doctors[index!].capabilities = result.capabilities;
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

  bool chooseTime = true;
  bool chooseDays = true;
  bool chooseBranch = true;

  bool validateAddBranch() {
    if (selectedBranch == null) {
      chooseBranch = false;
    } else {
      chooseBranch = true;
    }
    if (availableFrom == "" && availableTo == "") {
      chooseTime = false;
    } else {
      chooseTime = true;
    }
    if (availableDays.isEmpty) {
      chooseDays = false;
    } else {
      chooseDays = true;
    }
    if (chooseBranch && chooseTime && chooseDays) {
      log("true");
      return true;
    } else {
      log("false");

      return false;
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
    selectedClinic = null;
    selectedBranch = null;
    availableDays = [];
    availableFrom = "";
    availableTo = "";
    isValidate = false;
  }
}
