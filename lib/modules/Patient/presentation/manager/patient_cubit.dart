import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';
import 'package:ocurithm/core/utils/colors.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../Services/services_api.dart';
import '../../../Branch/data/model/branches_model.dart';
import '../../../Clinics/data/model/clinics_model.dart';
import '../../data/model/one_exam.dart';
import '../../data/model/patient_examination.dart';
import '../../data/model/patients_model.dart';
import '../../data/repos/patient_repo.dart';
import 'patient_state.dart';

class PatientCubit extends Cubit<PatientState> {
  PatientCubit(this.patientRepo) : super(PatientInitial());

  static PatientCubit get(context) => BlocProvider.of(context);
  PatientRepo patientRepo;

  TextEditingController nameController = TextEditingController();
  TextEditingController phoneNumberController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController addressController = TextEditingController();
  TextEditingController nationalityController = TextEditingController();
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
        if (patients!.patients!.isNotEmpty) {
          emit(AdminBranchSuccess());
        } else {
          emit(AdminBranchError());
        }
      }
    } catch (e) {
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

  bool picDate = true;
  bool chooseBranch = true;
  bool chooseClinic = true;
  bool gender = true;
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
          phone: phoneNumberController.text,
          address: addressController.text,
          birthDate: date,
          branch: selectedBranch,
          gender: selectedGender,
          clinic: selectedClinic,
          nationalId: nationalIdController.text,
          nationality: nationalityController.text,
          email: emailController.text,
          username: nameController.text,
        ),
      );
      if (result.error == null && (result.name != null || result.id != null)) {
        Get.snackbar(
          "Success",
          "Patient Added Successfully",
          backgroundColor: Colorz.primaryColor,
          colorText: Colorz.white,
          icon: Icon(Icons.check, color: Colorz.white),
        );
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

        patients?.patients?.removeWhere((Patient) => Patient.id == id);

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
        nationalityController.text = patient?.nationality ?? "";
        nationalIdController.text = patient?.nationalId ?? "";
        selectedClinic = patient?.clinic;
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

  updatePatient({required String id, context}) async {
    emit(AdminBranchLoading());
    try {
      final result = await patientRepo.updatePatient(
        patient: Patient(
          name: nameController.text,
          phone: phoneNumberController.text,
          address: addressController.text,
          birthDate: date,
          branch: selectedBranch,
          clinic: selectedClinic,
          gender: selectedGender,
          nationalId: nationalIdController.text,
          nationality: nationalityController.text,
          email: emailController.text,
          username: nameController.text,
        ),
        id: id,
      );
      if (result.error == null && (result.name != null || result.id != null)) {
        Get.snackbar(
          "Success",
          "Patient Updated Successfully",
          backgroundColor: Colorz.primaryColor,
          colorText: Colorz.white,
          icon: Icon(Icons.check, color: Colorz.white),
        );
        Navigator.pop(context);
        Navigator.pop(context);
        readOnly = true;

        final index = patients?.patients.indexWhere((patient) => patient.id == id);
        if (index != -1) {
          patients?.patients[index!].name = result.name;
          patients?.patients[index!].password = result.password;
          patients?.patients[index!].phone = result.phone;
          patients?.patients[index!].birthDate = result.birthDate;
          patients?.patients[index!].nationalId = result.nationalId;
          patients?.patients[index!].nationality = result.nationality;
          patients?.patients[index!].email = result.email;
          patients?.patients[index!].address = result.address;
          patients?.patients[index!].gender = result.gender;
          patients?.patients[index!].username = result.username;
          patients?.patients[index!].branch = result.branch;
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
      Navigator.pop(context);

      emit(AdminBranchError());
    }
  }

  clearData() {
    nameController.clear();
    imageUrl = null;
    passwordController.clear();
    phoneNumberController.clear();
    nationalIdController.clear();
    nationalityController.clear();
    emailController.clear();
    addressController.clear();
    selectedGender = null;
    selectedClinic = null;
    date = null;
    selectedBranch = null;
    picDate = true;
    chooseBranch = true;
    isValidate = false;
    gender = true;
  }

  Future getData({required String id}) async {
    Future.wait([getPatient(id: id), getPatientExamination(id: id)]);
  }
}
