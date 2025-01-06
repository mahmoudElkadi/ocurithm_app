import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';
import 'package:ocurithm/core/utils/colors.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../../Services/services_api.dart';
import '../../../../Branch/data/model/branches_model.dart';
import '../../../../Clinics/data/model/clinics_model.dart';
import '../../../../Doctor/data/model/capability_model.dart';
import '../../../data/models/receptionists_model.dart';
import '../../../data/repos/receptionist_details_repo.dart';
import 'receptionist_details_state.dart';

class ReceptionistCubit extends Cubit<ReceptionistState> {
  ReceptionistCubit(this.receptionistRepo) : super(ReceptionistInitial());

  static ReceptionistCubit get(context) => BlocProvider.of(context);
  ReceptionistRepo receptionistRepo;

  TextEditingController nameController = TextEditingController();
  TextEditingController phoneNumberController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  bool readOnly = true;

  @override
  Future<void> close() {
    nameController.dispose();
    phoneNumberController.dispose();
    passwordController.dispose();
    return super.close();
  }

  ClinicsModel? clinics;
  Clinic? selectedClinic;
  Future<void> getClinics() async {
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
        clinics = await ServicesApi().getAllClinics();
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

  bool isConfirm = false;
  Branch? selectedBranch;

  ReceptionistsModel? receptionists;
  int page = 1;
  TextEditingController searchController = TextEditingController();
  getReceptionists() async {
    receptionists = null;
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
        receptionists = await receptionistRepo.getAllReceptionists(page: page, search: searchController.text);
        if (receptionists!.receptionists.isNotEmpty) {
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

  bool picDate = true;
  bool chooseBranch = true;
  bool chooseClinic = true;
  bool isValidate = false;

  bool validateFirstPage() {
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

    if (selectedClinic == null) {
      chooseClinic = false;
    } else {
      chooseClinic = true;
    }

    log(picDate.toString());
    log(chooseBranch.toString());

    if (picDate && chooseBranch && chooseClinic) {
      log(isValidate.toString());
      isValidate = true;
    } else {
      isValidate = false;
    }

    return isValidate;
  }

  List<String?>? capabilitiesList = [];
  String? imageUrl;

  addReceptionist({context}) async {
    emit(AddReceptionistLoading());
    try {
      var result = await receptionistRepo.createReceptionist(
        receptionist: Receptionist(
            name: nameController.text,
            image: imageUrl,
            password: passwordController.text,
            phone: phoneNumberController.text,
            birthDate: date,
            branch: selectedBranch,
            clinic: selectedClinic),
      );
      if (result.error == null && (result.name != null || result.id != null)) {
        Get.snackbar(
          "Success",
          "Receptionist Added Successfully",
          backgroundColor: Colorz.primaryColor,
          colorText: Colorz.white,
          icon: Icon(Icons.check, color: Colorz.white),
        );
        Navigator.pop(context);
        Navigator.pop(context);

        receptionists?.receptionists.add(Receptionist(
          id: result.id,
          name: result.name,
          phone: result.phone,
        ));

        clearData();
        emit(AddReceptionistSuccess());
      } else {
        Get.snackbar(
          "Error",
          result.error!,
          backgroundColor: Colorz.errorColor,
          colorText: Colorz.white,
          icon: Icon(Icons.error, color: Colorz.white),
        );
        Navigator.pop(context);

        emit(AddReceptionistError());
      }
    } catch (e) {
      log(e.toString());
      Navigator.pop(context);

      emit(AddReceptionistError());
    }
  }

  bool? connection;
  BranchesModel? branches;
  bool loading = false;
  Future<void> getBranches() async {
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
        branches = await ServicesApi().getAllBranches(clinic: selectedClinic?.id);
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

  deleteReceptionist({required String id, context}) async {
    emit(AdminBranchLoading());
    try {
      final result = await receptionistRepo.deleteReceptionist(
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

        receptionists?.receptionists.removeWhere((receptionist) => receptionist.id == id);

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

  Receptionist? receptionist;
  getReceptionist({required String id}) async {
    receptionist = null;
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
        receptionist = await receptionistRepo.getReceptionist(id: id);
        if (receptionist?.error == null) {
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

  updateReceptionist({required String id, context}) async {
    emit(AdminBranchLoading());
    try {
      final result = await receptionistRepo.updateReceptionist(
        receptionist: Receptionist(
            name: nameController.text,
            image: imageUrl,
            password: passwordController.text,
            phone: phoneNumberController.text,
            birthDate: date,
            branch: selectedBranch,
            clinic: selectedClinic,
            capability: capabilitiesList),
        id: id,
      );
      if (result.error == null && (result.name != null || result.id != null)) {
        Get.snackbar(
          "Success",
          "Receptionist Updated Successfully",
          backgroundColor: Colorz.primaryColor,
          colorText: Colorz.white,
          icon: Icon(Icons.check, color: Colorz.white),
        );
        Navigator.pop(context);
        readOnly = true;

        receptionist?.branch = result.branch;
        receptionist?.name = result.name;
        receptionist?.image = result.image;
        receptionist?.phone = result.phone;
        receptionist?.birthDate = result.birthDate;
        receptionist?.branchId = result.branchId;
        receptionist?.capabilities = result.capabilities;

        final index = receptionists?.receptionists.indexWhere((receptionist) => receptionist.id == id);
        if (index != -1) {
          receptionists?.receptionists[index!].name = result.name;
          receptionists?.receptionists[index!].image = result.image;
          receptionists?.receptionists[index!].password = result.password;
          receptionists?.receptionists[index!].phone = result.phone;
          receptionists?.receptionists[index!].birthDate = result.birthDate;
          receptionists?.receptionists[index!].branchId = result.branchId;
          receptionists?.receptionists[index!].capabilities = result.capabilities;
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
    date = null;
    capabilitiesList = [];
    selectedBranch = null;
    selectedClinic = null;
    picDate = true;
    chooseBranch = true;
    isValidate = false;
  }
}
