import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:ocurithm/core/utils/colors.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../data/repos/add_receptionist_repo.dart';
import 'add_recptionist_state.dart';

class CreateReceptionistCubit extends Cubit<CreateReceptionistState> {
  CreateReceptionistCubit(this.createReceptionistRepo) : super(CreateReceptionistInitial());

  static CreateReceptionistCubit get(context) => BlocProvider.of(context);
  CreateReceptionistRepo createReceptionistRepo;

  bool isConfirm = false;

  Future<void> createReceptionist({
    required BuildContext context,
    required String fullName,
    required String password,
    required String phone,
    required String gender,
    required String dateOfBirth,
    required String branchId,
  }) async {
    bool isConfirm = false;

    emit(CreateReceptionistLoading());
    var response = await createReceptionistRepo.createReceptionist(
      fullName: fullName,
      password: password,
      phone: phone,
      gender: gender,
      dateOfBirth: dateOfBirth,
      branchId: branchId,
    );

    if (response.data != null) {
      Get.snackbar(
        "Creation Successful",
        " Password sent to Receptionist phone",
        colorText: Colorz.white,
        backgroundColor: Colors.blue,
        icon: const Icon(
          Icons.check,
          color: Colors.white,
        ),
      );
      isConfirm = true;

      // Send WhatsApp message
      await sendWhatsAppMessage(phone,
          "Welcome to our clinics ❤️ .\n You can now check your appointments, by downloading Ocurithm application. \n Your credentials: \n username: ${response.data} \n password: $password \n Thank you.");

      Navigator.pop(context, isConfirm);

      emit(CreateReceptionistSuccess());
    } else if (response.error != null) {
      Get.snackbar(
        response.error.toString(),
        "",
        padding: EdgeInsets.only(top: 30.h),
        colorText: Colorz.white,
        backgroundColor: Colors.red,
        icon: const Icon(Icons.error),
      );
      Navigator.pop(context, isConfirm);
      Navigator.pop(context, isConfirm);

      emit(CreateReceptionistFailed());
    } else {
      Get.snackbar(
        "Creation Failed",
        "please try again",
        colorText: Colorz.white,
        backgroundColor: Colors.red,
        icon: const Icon(Icons.error),
      );
      Navigator.pop(context, isConfirm);

      emit(CreateReceptionistFailed());
    }
  }

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
  //       await (branchModel = createReceptionistRepo.getBranch());
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
