import 'dart:async';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rxdart/rxdart.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';
import 'package:ocurithm/core/utils/snackbar_service.dart';
import 'package:ocurithm/modules/Make_Appointment/data/models/make_appointment_model.dart';

import '../../../../../core/Network/shared.dart';
import '../../../../Appointment/data/models/appointment_model.dart';
import '../../../../Branch/data/model/branches_model.dart';
import '../../../../Clinics/data/model/clinics_model.dart';
import '../../../../Doctor/data/model/doctor_model.dart';
import '../../../../Examination Type/data/model/examination_type_model.dart';
import '../../../../Patient/data/model/patients_model.dart';
import '../../../../Payment Methods/data/model/payment_method_model.dart';
import '../../../data/repos/make_appointment_repo.dart';

part 'make_appointment_state.dart';
part 'make_appointment_event.dart';

class MakeAppointmentCubit extends Bloc<MakeAppointmentEvent, MakeAppointmentState> {
  final MakeAppointmentRepo makeAppointmentRepo;
  
  // Controllers to be disposed
  final TextEditingController noteController = TextEditingController();
  final TextEditingController patientController = TextEditingController();
  final TextEditingController searchController = TextEditingController();

  final _searchSubject = BehaviorSubject<String>();

  MakeAppointmentCubit(this.makeAppointmentRepo) : super(const MakeAppointmentState()) {
    on<InitialDataEvent>(_onInitialData);
    // Removed Get... handlers as they are now handled by separate Cubits
    on<GetAppointmentsEvent>(_onGetAppointments);
    on<CreateAppointmentEvent>(_onCreateAppointment);
    on<EditAppointmentEvent>(_onEditAppointment);
    on<SetDataEvent>(_onSetData);
    on<SetPatientEvent>(_onSetPatient);
    on<ChangeStepEvent>(_onChangeStep);
    on<PreviousStepEvent>(_onPreviousStep);
    on<ChangePageEvent>(_onChangePage);
    on<SetWidgetIndexEvent>(_onSetWidgetIndex);
    on<ValidateFieldEvent>(_onValidateField);
    
    // Selection Events
    on<SelectDoctorEvent>((event, emit) {
      emit(state.copyWith(selectedDoctor: event.doctor));
      add(ValidateFieldEvent('doctor', true));
    });
    on<SelectClinicEvent>((event, emit) {
      emit(state.copyWith(selectedClinic: event.clinic));
      add(ValidateFieldEvent('clinic', true));
    });
    on<SelectBranchEvent>((event, emit) {
      emit(state.copyWith(selectedBranch: event.branch));
       add(ValidateFieldEvent('branch', true));
    });
    on<SelectTimeEvent>((event, emit) => emit(state.copyWith(selectedTime: event.time)));
    on<SelectPaymentMethodEvent>((event, emit) {
      emit(state.copyWith(selectedPaymentMethod: event.paymentMethod));
      add(ValidateFieldEvent('paymentMethod', true));
    });
    on<SelectExaminationTypeEvent>((event, emit) {
      emit(state.copyWith(selectedExaminationType: event.examinationType));
      add(ValidateFieldEvent('examinationType', true));
    });

     // Search Debounce
    _searchSubject
        .debounceTime(const Duration(milliseconds: 500))
        .listen((searchText) {
      // Forward search to patient cubit if needed, or handle locally if strictly selection
      // add(GetPatientsEvent(search: searchText)); // Removed
    });
  }

  static MakeAppointmentCubit get(BuildContext context) => BlocProvider.of<MakeAppointmentCubit>(context);

  Future<void> _onInitialData(InitialDataEvent event, Emitter<MakeAppointmentState> emit) async {
    if (!CacheHelper.getStringList(key: "capabilities").contains("manageCapability")) {
      final user = CacheHelper.getUser("user");
      emit(state.copyWith(selectedClinic: user?.clinic));
    }
  }

  // Removed _onGetClinics, _onGetDoctors, _onGetBranches, _onGetPatients, _onGetPaymentMethods, _onGetExaminationTypes

  Future<void> _onGetAppointments(GetAppointmentsEvent event, Emitter<MakeAppointmentState> emit) async {
    emit(state.copyWith(appointmentStatus: DataStatus.loading));
    if (await _hasNoInternet()) {
      emit(state.copyWith(appointmentStatus: DataStatus.error, errorMessage: "No Internet Connection"));
      return;
    }
    try {
      final appointments = await makeAppointmentRepo.getAllAppointment(
        date: event.date,
        branch: event.branch ?? state.selectedBranch?.id,
        doctor: event.doctor ?? state.selectedDoctor?.id,
      );
      if (appointments.error == null && appointments.appointments.isNotEmpty) {
        emit(state.copyWith(appointmentStatus: DataStatus.success, appointments: appointments));
      } else {
        emit(state.copyWith(appointmentStatus: DataStatus.error)); // Or success with empty list?
      }
    } catch (e) {
      emit(state.copyWith(appointmentStatus: DataStatus.error));
    }
  }

  Future<void> _onCreateAppointment(CreateAppointmentEvent event, Emitter<MakeAppointmentState> emit) async {
    emit(state.copyWith(status: MakeAppointmentStatus.loading));
    try {
      var result = await makeAppointmentRepo.makeAppointment(
        model: MakeAppointmentModel(
          doctor: state.selectedDoctor?.id,
          branch: state.selectedBranch?.id,
          datetime: state.selectedTime?.toUtc(),
          paymentMethod: state.selectedPaymentMethod?.id,
          examinationType: state.selectedExaminationType?.id,
          patient: state.selectedPatient?.id,
          status: "Scheduled",
          clinic: state.selectedClinic?.id,
          note: noteController.text.isNotEmpty ? noteController.text : event.note,
        ),
      );
      
      if (result.error == null) {
        emit(state.copyWith(status: MakeAppointmentStatus.success, currentStep: 0, errorMessage: null));
      } else {
        emit(state.copyWith(status: MakeAppointmentStatus.error, errorMessage: result.error));
      }
    } catch (e) {
      emit(state.copyWith(status: MakeAppointmentStatus.error, errorMessage: e.toString()));
    }
  }

  Future<void> _onEditAppointment(EditAppointmentEvent event, Emitter<MakeAppointmentState> emit) async {
    emit(state.copyWith(status: MakeAppointmentStatus.loading));
    try {
      var result = await makeAppointmentRepo.editAppointment(model: event.model, id: event.model.id.toString());
      if (result.error == null) {
        emit(state.copyWith(status: MakeAppointmentStatus.success, errorMessage: null));
      } else {
        emit(state.copyWith(status: MakeAppointmentStatus.error, errorMessage: result.error));
      }
    } catch (e) {
       emit(state.copyWith(status: MakeAppointmentStatus.error, errorMessage: e.toString()));
    }
  }

  Future<void> _onSetData(SetDataEvent event, Emitter<MakeAppointmentState> emit) async {
    final appointment = event.appointment;
    emit(state.copyWith(
      selectedClinic: appointment.clinic,
      selectedTime: appointment.datetime,
      selectedExaminationType: appointment.examinationType,
      selectedPaymentMethod: appointment.paymentMethod,
      selectedBranch: appointment.branch,
      selectedDoctor: appointment.doctor,
      selectedPatient: appointment.patient,
    ));
    // Trigger side fetches
    // Removed side fetches as they are now handled by separate Cubits. 
    // The UI should ensure necessary data is loaded via other Cubits if needed for editing context.
  }

  Future<void> _onSetPatient(SetPatientEvent event, Emitter<MakeAppointmentState> emit) async {
    emit(state.copyWith(
      selectedPatient: event.patient,
      selectedClinic: event.patient?.clinic ?? state.selectedClinic,
      selectedBranch: event.patient?.branch ?? state.selectedBranch,
    ));
    add( ValidateFieldEvent('patient', true));
    if (event.patient?.clinic != null) {
      add( ValidateFieldEvent('clinic', true));
    }
    if (event.patient?.branch != null) {
      add( ValidateFieldEvent('branch', true));
    }
  }

  Future<void> _onChangeStep(ChangeStepEvent event, Emitter<MakeAppointmentState> emit) async {
    if (event.step >= 0 && event.step < 3) { // Assuming 3 steps as per original code
      emit(state.copyWith(currentStep: event.step));
    }
  }

  Future<void> _onPreviousStep(PreviousStepEvent event, Emitter<MakeAppointmentState> emit) async {
    if (state.currentStep > 0) {
      emit(state.copyWith(currentStep: state.currentStep - 1));
    }
  }

  Future<void> _onChangePage(ChangePageEvent event, Emitter<MakeAppointmentState> emit) async {
    // Assuming PageController logic needs to be handled in UI listening to state change
    // or we pass the controller to the bloc (bad practice).
    // The original code had PageController in Cubit.
    // For now, I'll update the state, and the UI should listen to 'currentPage' and animate.
    emit(state.copyWith(currentPage: event.index));
  }

  Future<void> _onSetWidgetIndex(SetWidgetIndexEvent event, Emitter<MakeAppointmentState> emit) async {
    emit(state.copyWith(widgetIndex: event.index));
  }

  Future<void> _onValidateField(ValidateFieldEvent event, Emitter<MakeAppointmentState> emit) async {
    final newValidationState = Map<String, bool>.from(state.validationState);
    newValidationState[event.field] = event.isValid;
    
    final allFilled = state.selectedDoctor != null &&
        state.selectedPatient != null &&
        state.selectedBranch != null &&
        state.selectedExaminationType != null &&
        state.selectedPaymentMethod != null;
        
    emit(state.copyWith(validationState: newValidationState, areAllFieldsFilled: allFilled));
  }

  Future<bool> _hasNoInternet() async {
    final hasInternet = await InternetConnection().hasInternetAccess;
    return !hasInternet;
  }
  
  // PageController needs to be accessible if UI uses it from Cubit (legacy support)
  // But preferably UI instantiates it. I will keep a reference if strictly needed but try to avoid it.
  // Original: PageController pageController = PageController();
  // I will add it back to minimize UI breakage if the UI accesses cubit.pageController
  final PageController pageController = PageController();

  @override
  Future<void> close() {
    _searchSubject.close();
    noteController.dispose();
    patientController.dispose();
    searchController.dispose();
    pageController.dispose();
    return super.close();
  }
}

