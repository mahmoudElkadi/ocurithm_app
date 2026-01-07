import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ocurithm/modules/Patient/data/model/patients_model.dart';
import 'package:ocurithm/modules/Patient/data/repos/patient_repo.dart';
import 'package:rxdart/rxdart.dart';

part 'get_patients_state.dart';
part 'get_patients_event.dart';

/// Cubit for fetching and managing patients list
/// Includes debounced search, pagination, and filters
class GetPatientsCubit extends Bloc<GetPatientsEvent, GetPatientsState> {
  final PatientRepo patientRepo;
  final _searchSubject = BehaviorSubject<String>();

  GetPatientsCubit(this.patientRepo) : super(const GetPatientsState()) {
    on<GetAllPatientsEvent>(_onGetAllPatients);
    on<SetPageEvent>(_onSetPage);
    on<RemovePatientEvent>(_onRemovePatient);
    on<ResetPatientFilters>(_onResetFilters);
    on<SetSearchEvent>(_onSetSearch);
    on<SetClinicFilterEvent>(_onSetClinicFilter);
    on<SetBranchFilterEvent>(_onSetBranchFilter);

    // Listen to search subject with debounce
    _searchSubject
        .debounceTime(const Duration(milliseconds: 700))
        .listen((searchText) {
      add(GetAllPatientsEvent());
    });
  }

  static GetPatientsCubit get(BuildContext context) => BlocProvider.of(context);

  // Call this when you want to trigger search with debounce
  void onSearchChanged(String searchText) {
    // Update state immediately for UI feedback by dispatching event
    add(SetSearchEvent(searchText));
    // Trigger debounced search
    _searchSubject.add(searchText);
  }

  // Get All Patients
  Future<void> _onGetAllPatients(
      GetAllPatientsEvent event, Emitter<GetPatientsState> emit) async {
    try {
      emit(state.copyWith(state: GetPatientsStatus.loading));

      final patients = await patientRepo.getAllPatients(
        page: state.page,
        search: state.search,
        branch: state.branchFilter,
        // clinic: state.clinicFilter, // API doesn't support clinic filter yet
      );

      emit(state.copyWith(
        state: GetPatientsStatus.success,
        patients: patients,
      ));
    } catch (e) {
      if (e.toString().toLowerCase().contains('no internet connection')) {
        emit(state.copyWith(
          state: GetPatientsStatus.noConnection,
          errorMessage: e.toString(),
        ));
        return;
      }
      if (e.toString().toLowerCase().contains('request cancelled')) {
        return;
      }
      emit(state.copyWith(
        state: GetPatientsStatus.error,
        errorMessage: e.toString(),
      ));
    }
  }

  // Set search (for non-debounced updates if needed)
  Future<void> _onSetSearch(
      SetSearchEvent event, Emitter<GetPatientsState> emit) async {
    emit(state.copyWith(search: event.search, page: 1));
  }

  // Set page
  Future<void> _onSetPage(
      SetPageEvent event, Emitter<GetPatientsState> emit) async {
    emit(state.copyWith(page: event.page));
  }

  // Set clinic filter
  Future<void> _onSetClinicFilter(
      SetClinicFilterEvent event, Emitter<GetPatientsState> emit) async {
    emit(state.copyWith(clinicFilter: event.clinicId, page: 1));
    add(GetAllPatientsEvent());
  }

  // Set branch filter
  Future<void> _onSetBranchFilter(
      SetBranchFilterEvent event, Emitter<GetPatientsState> emit) async {
    emit(state.copyWith(branchFilter: event.branchId, page: 1));
    add(GetAllPatientsEvent());
  }

  // Remove patient
  Future<void> _onRemovePatient(
      RemovePatientEvent event, Emitter<GetPatientsState> emit) async {
    if (state.patients == null ||
        state.patients!.patients.isEmpty ||
        event.index < 0 ||
        event.index >= state.patients!.patients.length) {
      return;
    }

    // Creating updated model locally for optimistic update feel or state consistency
    final updatedPatients = PatientModel(
      patients: List.from(state.patients!.patients)..removeAt(event.index),
      total: state.patients!.total,
      totalPages: state.patients!.totalPages,
    );

    emit(state.copyWith(patients: updatedPatients));
  }

  // Reset filters
  Future<void> _onResetFilters(
      ResetPatientFilters event, Emitter<GetPatientsState> emit) async {
    emit(state.copyWith(
      page: 1,
      search: '',
      clinicFilter: null,
      branchFilter: null,
    ));
    add(GetAllPatientsEvent());
  }

  @override
  Future<void> close() {
    _searchSubject.close();
    return super.close();
  }
}
