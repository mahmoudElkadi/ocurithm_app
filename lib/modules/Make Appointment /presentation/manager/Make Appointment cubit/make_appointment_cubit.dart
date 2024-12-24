import 'dart:async';
import 'dart:developer';

import 'package:async/async.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';
import 'package:ocurithm/modules/Make%20Appointment%20/data/models/make_appointment_model.dart';

import '../../../../../core/utils/colors.dart';
import '../../../../Appointment/data/models/appointment_model.dart';
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

  Widget? currentWidget;
  int widgetIndex = 0;
  pageTwo(context, index) {
    widgetIndex = index;
    if (!isClosed) emit(ChangeState());
  }

  PageController pageController = PageController();
  int currentPage = 0;

  void togglePage(int pageIndex, context) {
    currentPage = pageIndex;
    pageController.animateToPage(
      currentPage,
      duration: const Duration(milliseconds: 700),
      curve: Curves.easeInOut,
    );
    if (!isClosed) emit(ChangeState());
  }

  bool? connection;
  MakeAppointmentRepo makeAppointmentRepo;

  DoctorModel? doctors;
  Future<void> getDoctors({String? branch}) async {
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
        doctors = await makeAppointmentRepo.getAllDoctors(branch: branch);
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
  TextEditingController patientController = TextEditingController();
  bool loadPatients = false;
  Future<void> getPatients() async {
    patients = null;
    loadPatients = true;
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
        loadPatients = false;
        emit(AdminPatientError());
      } else {
        patients = await makeAppointmentRepo.getAllPatients();
        if (patients!.patients.isNotEmpty) {
          loadPatients = false;
          emit(AdminPatientSuccess());
        } else {
          loadPatients = false;
          emit(AdminPatientError());
        }
      }
    } catch (e) {
      loadPatients = false;
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
        examinationTypes = await makeAppointmentRepo.getAllExaminationTypes();
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

  int currentStep = 0;
  final List<String> steps = ['Details', 'Time', 'Preview'];

  void changeStep(int newStep) {
    if (newStep >= 0 && newStep < steps.length) {
      currentStep = newStep;
      emit(StepChanged());
    }
  }

  void previousStep() {
    if (currentStep > 0) {
      currentStep--;
      emit(StepChanged());
    }
  }

  getAllData() async {
    await Future.wait([
      getBranches(),
      getExaminationTypes(),
      getPaymentMethods(),
    ]);
  }

  Timer? _debounceTimer;

  Timer? _searchDebounceTimer;
  CancelableOperation<void>? _currentOperation;

  void searchPatients() async {
    // Cancel previous timer
    _searchDebounceTimer?.cancel();
    // Cancel previous operation if exists
    await _currentOperation?.cancel();

    _searchDebounceTimer = Timer(const Duration(milliseconds: 500), () {
      // Cancel previous operation
      _currentOperation?.cancel();

      // Create new cancelable operation
      _currentOperation = CancelableOperation.fromFuture(
        getPatients(),
        onCancel: () {
          // Cleanup if needed when cancelled
          print('Search operation cancelled');
        },
      );

      // Execute the operation
      _currentOperation?.value.then((_) {
        print('Search completed');
      }).catchError((error) {
        print('Search error: $error');
      });
    });
  }

  String? appointmentId;
  setData(Appointment appointment) async {
    selectedTime = appointment.datetime;
    selectedExaminationType = appointment.examinationType;
    selectedPaymentMethod = appointment.paymentMethod;
    selectedBranch = appointment.branch;
    selectedDoctor = appointment.doctor;
    selectedPatient = appointment.patient;
    appointmentId = appointment.id;
    log("dsdsdsdsds" + appointment.toJson().toString());
    emit(DataChanged());
  }

  AppointmentModel? appointments;
  getAppointments(DateTime? selectedDate) async {
    appointments = null;
    emit(GetBranchLoading());
    connection = await InternetConnection().hasInternetAccess;
    emit(GetBranchLoading());
    try {
      if (connection == true) {
        appointments = await makeAppointmentRepo.getAllAppointment(date: selectedDate, branch: selectedBranch?.id, doctor: selectedDoctor?.id);
        if (appointments?.error == null && appointments!.appointments.isNotEmpty) {
          // Group appointments by time slot
          emit(GetBranchSuccess());
        } else {
          emit(GetBranchError());
        }
      }
    } catch (e) {
      log(e.toString());
      loading = false;
      emit(GetBranchError());
    }
  }

  makeAppointment({required BuildContext context}) async {
    emit(MakeAppointmentLoading());
    try {
      var result = await makeAppointmentRepo.makeAppointment(
          model: MakeAppointmentModel(
              doctor: selectedDoctor?.id,
              branch: selectedBranch?.id,
              datetime: selectedTime,
              paymentMethod: selectedPaymentMethod?.id,
              examinationType: selectedExaminationType?.id,
              patient: selectedPatient?.id,
              status: "Scheduled",
              clinic: "672b6748c642f2ffd02807ad",
              note: noteController.text));
      if (result != null && result.error == null) {
        Get.snackbar(
          "Success",
          "Appointment created successfully",
          backgroundColor: Colorz.primaryColor,
          colorText: Colorz.white,
          icon: Icon(Icons.check, color: Colorz.white),
        );
        currentStep = 0;
        Navigator.pop(context);
        Navigator.pop(context);
        emit(MakeAppointmentSuccess());
      } else if (result != null && result.error != null) {
        Get.snackbar(
          result.error!,
          "Failed to create appointment",
          backgroundColor: Colorz.errorColor,
          colorText: Colorz.white,
          icon: Icon(Icons.error, color: Colorz.white),
        );
        Navigator.pop(context);

        emit(MakeAppointmentError());
      } else {
        Get.snackbar(
          "Error",
          "Failed to create appointment",
          backgroundColor: Colorz.errorColor,
          colorText: Colorz.white,
          icon: Icon(Icons.error, color: Colorz.white),
        );
        Navigator.pop(context);

        emit(MakeAppointmentError());
      }
    } catch (e) {
      emit(MakeAppointmentError());
    }
  }

  editAppointment({required BuildContext context, required MakeAppointmentModel model}) async {
    emit(MakeAppointmentLoading());
    try {
      var result = await makeAppointmentRepo.editAppointment(model: model, id: model.id.toString());
      if (result != null && result.error == null) {
        Get.snackbar(
          "Success",
          "Appointment Updated successfully",
          backgroundColor: Colorz.primaryColor,
          colorText: Colorz.white,
          icon: Icon(Icons.check, color: Colorz.white),
        );
        Navigator.pop(context);
        Navigator.pop(context, true);
        emit(MakeAppointmentSuccess());
      } else if (result != null && result.error != null) {
        Get.snackbar(
          result.error!,
          "Failed to create appointment",
          backgroundColor: Colorz.errorColor,
          colorText: Colorz.white,
          icon: Icon(Icons.error, color: Colorz.white),
        );
        Navigator.pop(context);

        emit(MakeAppointmentError());
      } else {
        Get.snackbar(
          "Error",
          "Failed to create appointment",
          backgroundColor: Colorz.errorColor,
          colorText: Colorz.white,
          icon: Icon(Icons.error, color: Colorz.white),
        );
        Navigator.pop(context);

        emit(MakeAppointmentError());
      }
    } catch (e) {
      emit(MakeAppointmentError());
    }
  }

  TextEditingController noteController = TextEditingController();
  @override
  Future<void> close() {
    noteController.dispose();
    return super.close();
  }

  Doctor? selectedDoctor;
  Patient? selectedPatient;
  Branch? selectedBranch;
  DateTime? selectedTime;
  PaymentMethod? selectedPaymentMethod;
  ExaminationType? selectedExaminationType;
  final Map<String, bool> validationState = {
    'doctor': true,
    'patient': true,
    'branch': true,
    'examinationType': true,
    'paymentMethod': true,
  };
  bool get areAllFieldsFilled =>
      selectedDoctor != null && selectedPatient != null && selectedBranch != null && selectedExaminationType != null && selectedPaymentMethod != null;
  bool get isFormValid => validationState.values.every((isValid) => isValid) && areAllFieldsFilled;
  void validateField(String field, bool isValid) {
    validationState[field] = isValid;
    emit(ValidateState());
  }

  Map<String, dynamic> appointmentData = {
    "doctor": {
      "name": "Elkady",
    },
    "patient": {"name": "Ahmed"},
    "branch": {"name": "Cairo"},
    "examinationType": {"name": "X-ray", "price": 100, "duration": 10},
    "paymentMethod": {"name": "Cash"},
    "date": {"date": "2022-12-12"}
  };
}
