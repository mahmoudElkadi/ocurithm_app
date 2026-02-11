part of 'make_appointment_cubit.dart';

enum MakeAppointmentStatus {
  initial,
  loading,
  success,
  error,
  noConnection,
}

enum DataStatus {
  initial,
  loading,
  success,
  error,
}

@immutable
class MakeAppointmentState {
  final MakeAppointmentStatus status;
  final DataStatus clinicStatus;
  final DataStatus doctorStatus;
  final DataStatus branchStatus;
  final DataStatus patientStatus;
  final DataStatus paymentMethodStatus;
  final DataStatus examinationTypeStatus;
  final DataStatus appointmentStatus;
  
  final String? errorMessage;
  
  final ClinicsModel? clinics;
  final DoctorModel? doctors;
  final BranchesModel? branches;
  final PatientModel? patients;
  final PaymentMethodsModel? paymentMethods;
  final ExaminationTypesModel? examinationTypes;
  final AppointmentModel? appointments;
  
  final int currentStep;
  final int currentPage;
  final int widgetIndex; // For pageTwo logic
  
  // Selection Data
  final Clinic? selectedClinic;
   Doctor? selectedDoctor;
   Branch? selectedBranch;
   Patient? selectedPatient;
  final DateTime? selectedTime;
   PaymentMethod? selectedPaymentMethod;
   ExaminationType? selectedExaminationType;
  
  final Map<String, bool> validationState;
  final bool areAllFieldsFilled;
  
   MakeAppointmentState({
    this.status = MakeAppointmentStatus.initial,
    this.clinicStatus = DataStatus.initial,
    this.doctorStatus = DataStatus.initial,
    this.branchStatus = DataStatus.initial,
    this.patientStatus = DataStatus.initial,
    this.paymentMethodStatus = DataStatus.initial,
    this.examinationTypeStatus = DataStatus.initial,
    this.appointmentStatus = DataStatus.initial,
    this.errorMessage,
    this.clinics,
    this.doctors,
    this.branches,
    this.patients,
    this.paymentMethods,
    this.examinationTypes,
    this.appointments,
    this.currentStep = 0,
    this.currentPage = 0,
    this.widgetIndex = 0,
    this.selectedClinic,
    this.selectedDoctor,
    this.selectedBranch,
    this.selectedPatient,
    this.selectedTime,
    this.selectedPaymentMethod,
    this.selectedExaminationType,
    this.validationState = const {
      'doctor': true,
      'patient': true,
      'branch': true,
      'clinic': true,
      'examinationType': true,
      'paymentMethod': true,
    },
    this.areAllFieldsFilled = false,
  });

  MakeAppointmentState copyWith({
    MakeAppointmentStatus? status,
    DataStatus? clinicStatus,
    DataStatus? doctorStatus,
    DataStatus? branchStatus,
    DataStatus? patientStatus,
    DataStatus? paymentMethodStatus,
    DataStatus? examinationTypeStatus,
    DataStatus? appointmentStatus,
    String? errorMessage,
    ClinicsModel? clinics,
    DoctorModel? doctors,
    BranchesModel? branches,
    PatientModel? patients,
    PaymentMethodsModel? paymentMethods,
    ExaminationTypesModel? examinationTypes,
    AppointmentModel? appointments,
    int? currentStep,
    int? currentPage,
    int? widgetIndex,
    Clinic? selectedClinic,
    Doctor? selectedDoctor,
    Branch? selectedBranch,
    Patient? selectedPatient,
    DateTime? selectedTime,
    PaymentMethod? selectedPaymentMethod,
    ExaminationType? selectedExaminationType,
    Map<String, bool>? validationState,
    bool? areAllFieldsFilled,
    // Special flag to allow setting selected fields to null
    bool clearSelectedClinic = false,
    bool clearSelectedDoctor = false,
    bool clearSelectedBranch = false,
    bool clearSelectedPatient = false,
    bool clearSelectedTime = false,
    bool clearSelectedPaymentMethod = false,
    bool clearSelectedExaminationType = false,
  }) {
    return MakeAppointmentState(
      status: status ?? this.status,
      clinicStatus: clinicStatus ?? this.clinicStatus,
      doctorStatus: doctorStatus ?? this.doctorStatus,
      branchStatus: branchStatus ?? this.branchStatus,
      patientStatus: patientStatus ?? this.patientStatus,
      paymentMethodStatus: paymentMethodStatus ?? this.paymentMethodStatus,
      examinationTypeStatus: examinationTypeStatus ?? this.examinationTypeStatus,
      appointmentStatus: appointmentStatus ?? this.appointmentStatus,
      errorMessage: errorMessage ?? this.errorMessage,
      clinics: clinics ?? this.clinics,
      doctors: doctors ?? this.doctors,
      branches: branches ?? this.branches,
      patients: patients ?? this.patients,
      paymentMethods: paymentMethods ?? this.paymentMethods,
      examinationTypes: examinationTypes ?? this.examinationTypes,
      appointments: appointments ?? this.appointments,
      currentStep: currentStep ?? this.currentStep,
      currentPage: currentPage ?? this.currentPage,
      widgetIndex: widgetIndex ?? this.widgetIndex,
      selectedClinic: clearSelectedClinic ? null : (selectedClinic ?? this.selectedClinic),
      selectedDoctor: clearSelectedDoctor ? null : (selectedDoctor ?? this.selectedDoctor),
      selectedBranch: clearSelectedBranch ? null : (selectedBranch ?? this.selectedBranch),
      selectedPatient: clearSelectedPatient ? null : (selectedPatient ?? this.selectedPatient),
      selectedTime: clearSelectedTime ? null : (selectedTime ?? this.selectedTime),
      selectedPaymentMethod: clearSelectedPaymentMethod ? null : (selectedPaymentMethod ?? this.selectedPaymentMethod),
      selectedExaminationType: clearSelectedExaminationType ? null : (selectedExaminationType ?? this.selectedExaminationType),
      validationState: validationState ?? this.validationState,
      areAllFieldsFilled: areAllFieldsFilled ?? this.areAllFieldsFilled,
    );
  }
}

