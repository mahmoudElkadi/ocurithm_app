import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';
import 'package:ocurithm/core/utils/colors.dart';
import 'package:ocurithm/modules/Doctor/data/model/capability_model.dart';

import '../../../../Services/services_api.dart';
import '../../../../Services/whatsapp_confirmation.dart';
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
        emit(AdminDoctorError());
      } else {
        doctors = await doctorRepo.getAllDoctors(page: page, search: searchController.text, clinic: filterByClinic?.id, branch: filterByBranch?.id);
        if (doctors!.doctors.isNotEmpty) {
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
        emit(AdminClinicError());
      } else {
        clinics = await ServicesApi().getAllClinics(page: page, search: searchController.text);
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
        await WhatsAppConfirmation().sendWhatsAppMessage(phoneNumberController.text,
            "Welcome to our clinics ❤️ .\n You can now sign in, by downloading Ocurithm application. \n Your credentials: \n username: ${phoneNumberController.text} \n password: ${passwordController.text} \n Thank you.");

        Navigator.pop(context);
        Navigator.pop(context);

        doctors?.doctors.add(Doctor(
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

  editBranch({context, required String doctorId, required String branchId}) async {
    emit(UpdateBranchLoading());
    try {
      var result = await doctorRepo.editBranch(
          doctorId: doctorId, branchId: branchId, availableFrom: availableFrom, availableTo: availableTo, availableDays: availableDays);
      if (result.error == null && (result.name != null || result.id != null)) {
        Get.snackbar(
          "Success",
          "Branch updated Successfully",
          backgroundColor: Colorz.primaryColor,
          colorText: Colorz.white,
          icon: Icon(Icons.check, color: Colorz.white),
        );
        Navigator.pop(context);
        Navigator.pop(context);

        doctor = result;
        emit(UpdateBranchSuccess());
      } else {
        Get.snackbar(
          "Error",
          result.error!,
          backgroundColor: Colorz.errorColor,
          colorText: Colorz.white,
          icon: Icon(Icons.error, color: Colorz.white),
        );
        Navigator.pop(context);

        emit(UpdateBranchError());
      }
    } catch (e) {
      log(e.toString());
      Navigator.pop(context);

      emit(UpdateBranchError());
    }
  }

  deleteBranch({context, required String doctorId, required String branchId}) async {
    emit(DeleteBranchLoading());
    // try {
    var result = await doctorRepo.deleteBranch(doctorId: doctorId, branchId: branchId);
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

        doctors?.doctors.removeWhere((Doctor) => Doctor.id == id);

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
        emit(AdminBranchError());
      } else {
        doctor = await doctorRepo.getDoctor(id: id);
        if (doctor != null) {
          imageUrl = doctor?.image;
          nameController.text = doctor?.name ?? '';
          phoneNumberController.text = doctor?.phone ?? "";
          passwordController.text = doctor?.password ?? "";
          date = doctor?.birthDate;
          selectedClinic = doctor?.clinic;
          qualificationController.text = doctor?.qualifications ?? "";
        }
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

        final index = doctors?.doctors.indexWhere((Doctor) => Doctor.id == id);
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
      return true;
    } else {
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
