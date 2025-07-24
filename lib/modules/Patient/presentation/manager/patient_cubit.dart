import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';
import 'package:ocurithm/Services/whatsapp_confirmation.dart';
import 'package:ocurithm/core/utils/colors.dart';
import 'package:ocurithm/modules/Patient/data/model/nationality_model.dart';

import '../../../../Services/services_api.dart';
import '../../../../core/utils/constant.dart';
import '../../../../core/utils/phone_number.dart';
import '../../../Branch/data/model/branches_model.dart';
import '../../../Clinics/data/model/clinics_model.dart';
import '../../../Make_Appointment/presentation/views/make_appointment_view.dart';
import '../../data/model/one_exam.dart';
import '../../data/model/patient_examination.dart';
import '../../data/model/patients_model.dart';
import '../../data/repos/patient_repo.dart';
import '../views/Add Patient/presentation/view/widgets/dialog_add_patient.dart';
import 'patient_state.dart';

class PatientCubit extends Cubit<PatientState> {
  PatientCubit(this.patientRepo) : super(PatientInitial());

  static PatientCubit get(context) => BlocProvider.of(context);
  PatientRepo patientRepo;

  TextEditingController nameController = TextEditingController();
  TextEditingController phoneNumberController = TextEditingController();
  String phoneNumber = "";
  TextEditingController passwordController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController addressController = TextEditingController();
  TextEditingController nationalIdController = TextEditingController();
  bool readOnly = true;

  checkConnection() async {
    connection = await InternetConnection().hasInternetAccess;
    emit(CheckConnection());
  }

  @override
  Future<void> close() {
    nameController.dispose();
    phoneNumberController.dispose();
    passwordController.dispose();
    emailController.dispose();
    addressController.dispose();
    nationalIdController.dispose();
    return super.close();
  }

  bool isConfirm = false;
  Branch? selectedBranch;
  var selectedGender;

  chooseBranchId(selected) {
    selectedBranch = selected;
    emit(ChooseBranch());
  }

  PatientModel? patients;
  int page = 1;
  TextEditingController searchController = TextEditingController();

  getPatients() async {
    patients = null;
    emit(AdminBranchLoading());

    connection = await InternetConnection().hasInternetAccess;
    emit(AdminBranchLoading());
    try {
      if (connection == false) {
        emit(AdminBranchError());
      } else {
        patients = await patientRepo.getAllPatients(page: page, search: searchController.text);
        if (patients!.patients.isNotEmpty) {
          emit(AdminBranchSuccess());
        } else {
          emit(AdminBranchError());
        }
      }
    } catch (e) {
      emit(AdminBranchError());
    }
  }

  bool _obscureText = true;

  bool get obscureText => _obscureText;

  Nationality? selectedNationality;

  set obscureText(bool newState) {
    _obscureText = newState;
    emit(ObscureText());
  }

  DateTime? date;

  bool picDate = true;
  bool chooseBranch = true;
  bool chooseClinic = true;
  bool gender = true;
  bool nationality = true;
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

    if (selectedGender == null) {
      gender = false;
    } else {
      gender = true;
    }

    if (selectedNationality == null) {
      nationality = false;
    } else {
      nationality = true;
    }

    if (picDate && chooseBranch && gender) {
      isValidate = true;
    } else {
      isValidate = false;
    }

    return isValidate;
  }

  List<String> capabilitiesList = [];
  String? imageUrl;

  addPatient({context}) async {
    emit(AddPatientLoading());
    try {
      var result = await patientRepo.createPatient(
        patient: Patient(
          name: nameController.text,
          password: passwordController.text,
          phone: phoneNumber,
          address: addressController.text,
          birthDate: date,
          branch: selectedBranch,
          gender: selectedGender,
          clinic: selectedClinic,
          nationalId: nationalIdController.text,
          nationality: selectedNationality?.value,
          email: emailController.text,
          username: nameController.text,
        ),
      );

      if (result.error == null && (result.name != null || result.id != null)) {
        // Show modern success popup instead of snackbar
        Navigator.pop(context);
        Navigator.pop(context);
        patients?.patients.add(Patient(
          id: result.id,
          name: result.name,
          phone: result.phone,
          birthDate: result.birthDate,
          email: result.email,
          username: result.username,
        ));
        await showDialog(
          context: context,
          barrierDismissible: false,
          builder: (BuildContext context) {
            return SuccessPopupDialog(
              patientName: nameController.text,
              password: passwordController.text,
              onSendMessage: () async {
                // Send WhatsApp message
                log(phoneNumber.toString());
                await WhatsAppConfirmation().sendWhatsAppMessage(phoneNumber,
                    "Welcome to our clinics ❤️ .\n You can now check your appointments, by downloading Ocurithm application. \n Your credentials: \n username: ${result.phone} \n password: ${passwordController.text} \n Thank you.");
              },
              onNavigateToPage: () async {
                await Get.to(() => MakeAppointmentView(patient: result));
              },
            );
          },
        );

        // Update patients list

        clearData();
        emit(AddPatientSuccess());
      } else {
        Get.snackbar(
          "Error",
          result.error!,
          backgroundColor: Colorz.errorColor,
          colorText: Colorz.white,
          icon: Icon(Icons.error, color: Colorz.white),
        );
        Navigator.pop(context);
        emit(AddPatientError());
      }
    } catch (e) {
      Navigator.pop(context);
      emit(AddPatientError());
    }
  }

  Clinic? selectedClinic;

  ClinicsModel? clinics;

  getClinics() async {
    clinics = null;
    emit(AdminClinicLoading());

    connection = await InternetConnection().hasInternetAccess;
    emit(AdminClinicLoading());
    try {
      if (connection == false) {
        emit(AdminClinicError());
      } else {
        clinics = await ServicesApi().getAllClinics();
        if (clinics?.error == null && clinics!.clinics.isNotEmpty) {
          emit(AdminClinicSuccess());
        } else {
          emit(AdminClinicError());
        }
      }
    } catch (e) {
      emit(AdminClinicError());
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
      loading = false;
      emit(AdminBranchError());
    }
  }

  deletePatient({required String id, context}) async {
    emit(AdminBranchLoading());
    try {
      final result = await patientRepo.deletePatient(
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

        patients?.patients.removeWhere((patient) => patient.id == id);

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
      Navigator.pop(context);

      emit(AdminBranchError());
    }
  }

  Nationality? findNationalityByValue(String? value) {
    if (value == null) return null;
    try {
      return nationalities.firstWhere((nationality) => nationality.value == value);
    } catch (e) {
      return null; // Return null if not found
    }
  }

  Patient? patient;

  Future getPatient({required String id}) async {
    patient = null;
    emit(AdminBranchLoading());
    connection = await InternetConnection().hasInternetAccess;
    emit(AdminBranchLoading());
    try {
      if (connection == false) {
        emit(AdminBranchError());
      } else {
        patient = await patientRepo.getPatient(id: id);
        nameController.text = patient?.name ?? '';
        phoneNumberController.text = patient?.phone ?? "";
        date = patient?.birthDate;
        selectedBranch = patient?.branch;
        selectedGender = patient?.gender;
        emailController.text = patient?.email ?? "";
        addressController.text = patient?.address ?? "";
        selectedNationality = findNationalityByValue(patient?.nationality);
        nationalIdController.text = patient?.nationalId ?? "";
        selectedClinic = patient?.clinic;
        phoneData = PhoneNumberService.parsePhone(patient?.phone);
        if (phoneData?['code'] != null && phoneData?['phoneNumber'] != null) {
          phoneNumber = phoneData?['code'] + phoneData?['phoneNumber'];
        }
        if (patient?.error == null) {
          emit(AdminBranchSuccess());
        } else {
          emit(AdminBranchError());
        }
      }
    } catch (e) {
      emit(AdminBranchError());
    }
  }

  PatientExaminationModel? patientExamination;

  Future getPatientExamination({required String id}) async {
    patientExamination = null;
    emit(GetPatientExaminationsLoading());
    connection = await InternetConnection().hasInternetAccess;
    emit(AdminBranchLoading());
    try {
      if (connection == false) {
        emit(GetPatientExaminationsError());
      } else {
        patientExamination = await patientRepo.getPatientExaminations(id: id);
        if (patientExamination?.error == null) {
          emit(GetPatientExaminationsSuccess());
        } else {
          emit(GetPatientExaminationsError());
        }
      }
    } catch (e) {
      emit(AdminBranchError());
    }
  }

  ExaminationModel? oneExamination;

  Future getOneExamination({required String id}) async {
    oneExamination = null;
    emit(GetOneExaminationsLoading());
    connection = await InternetConnection().hasInternetAccess;
    emit(GetOneExaminationsLoading());
    try {
      if (connection == false) {
        Get.snackbar(
          "Error",
          "No Internet Connection",
          backgroundColor: Colorz.errorColor,
          colorText: Colorz.white,
          icon: Icon(Icons.error, color: Colorz.white),
        );
        emit(GetOneExaminationsError());
      } else {
        oneExamination = await patientRepo.getOneExamination(id: id);
        if (oneExamination?.error == null) {
          emit(GetOneExaminationsSuccess());
        } else {
          emit(GetOneExaminationsError());
        }
      }
    } catch (e) {
      emit(GetOneExaminationsError());
    }
  }

  Patient? updatedPatient;

  updatePatient({required String id, context}) async {
    emit(UpdatePatientLoading());
    try {
      updatedPatient = await patientRepo.updatePatient(
        patient: Patient(
          name: nameController.text,
          phone: phoneNumber,
          address: addressController.text,
          birthDate: date,
          branch: selectedBranch,
          clinic: selectedClinic,
          gender: selectedGender,
          nationalId: nationalIdController.text,
          nationality: selectedNationality?.value,
          email: emailController.text,
          username: nameController.text,
        ),
        id: id,
      );
      if (updatedPatient?.error == null && (updatedPatient?.name != null || updatedPatient?.id != null)) {
        Get.snackbar(
          "Success",
          "Patient Updated Successfully",
          backgroundColor: Colorz.primaryColor,
          colorText: Colorz.white,
          icon: Icon(Icons.check, color: Colorz.white),
        );
        Navigator.pop(context, true);
        readOnly = true;

        emit(UpdatePatientSuccess());
      } else {
        Get.snackbar(
          "Error",
          updatedPatient?.error ?? "Failed to Update Patient",
          backgroundColor: Colorz.errorColor,
          colorText: Colorz.white,
          icon: Icon(Icons.error, color: Colorz.white),
        );
        Navigator.pop(context);

        emit(UpdatePatientError());
      }
    } catch (e) {
      Get.snackbar(
        "Error",
        e.toString(),
        backgroundColor: Colorz.errorColor,
        colorText: Colorz.white,
        icon: Icon(Icons.error, color: Colorz.white),
      );
      Navigator.pop(context);

      emit(UpdatePatientError());
    }
  }

  clearData() {
    nameController.clear();
    imageUrl = null;
    passwordController.clear();
    phoneNumberController.clear();
    nationalIdController.clear();
    emailController.clear();
    addressController.clear();
    selectedGender = null;
    selectedClinic = null;
    selectedNationality = null;
    date = null;
    selectedBranch = null;
    picDate = true;
    chooseBranch = true;
    isValidate = false;
    gender = true;
  }

  Map<String, dynamic>? phoneData;

  Future getData({required String id}) async {
    Future.wait([getPatient(id: id), getPatientExamination(id: id)]);
  }
}
