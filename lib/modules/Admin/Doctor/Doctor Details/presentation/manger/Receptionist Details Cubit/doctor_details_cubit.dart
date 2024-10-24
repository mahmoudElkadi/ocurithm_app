import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:ocurithm/core/utils/colors.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../data/repos/doctor_details_repo.dart';
import 'doctor_details_state.dart';

class DoctorDetailsCubit extends Cubit<DoctorDetailsState> {
  DoctorDetailsCubit(this.doctorDetailsRepo) : super(DoctorDetailsInitial());

  static DoctorDetailsCubit get(context) => BlocProvider.of(context);
  DoctorDetailsRepo doctorDetailsRepo;

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

  bool isConfirm = false;

  chooseBranchId(selected) {
    log(selected.branchId.toString());
    selectedBranch = selected;
    branchId = selected.branchId.toString();
    emit(ChooseBranch());
  }
  //
  // Future<BranchModel>? branchModel;
  // bool? result;
  //
  // getAllBranch() async {
  //   try {
  //     result = await InternetConnection().hasInternetAccess;
  //     emit(GetBranchLoading());
  //     if (result == true) {
  //       await (branchModel = DoctorDetailsRepo.getBranch());
  //     }
  //     emit(GetBranchSuccess());
  //   } catch (e) {
  //     log("Get Branch Cubit Error: $e");
  //     emit(GetBranchFailure());
  //   }
  // }

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
  var selectedBranch;
  String? branchId;
  String? selectedGender;

  bool picDate = true;
  bool gender = true;
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

    if (selectedGender == null) {
      gender = false;
    } else {
      gender = true;
    }

    log(gender.toString());
    log(picDate.toString());
    log(chooseBranch.toString());

    if (picDate && gender && chooseBranch) {
      log(isValidate.toString());
      isValidate = true;
    } else {
      isValidate = false;
    }

    emit(ValidateForm());
  }
}
