import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ocurithm/modules/Clinics/data/model/clinics_model.dart';
import 'package:ocurithm/modules/Clinics/data/repos/clinic_repo.dart';
import 'package:rxdart/rxdart.dart';

part 'get_clinics_state.dart';
part 'get_clinics_event.dart';

class GetClinicsCubit extends Bloc<GetClinicsEvent, GetClinicsState> {
  final ClinicRepo clinicRepo;
  final _searchSubject = BehaviorSubject<String>();

  GetClinicsCubit(this.clinicRepo) : super(GetClinicsState()) {
    on<GetAllClinicsEvent>(_onGetAllClinics);
    on<SetPageEvent>(_onSetPage);
    on<RemoveClinicsEvent>(_onRemoveClinic);
    on<ResetFiltersEvent>(_onResetFilters);
    on<SetSearchEvent>(_onSetSearch);
    on<AddClinicToListEvent>(_onAddClinicToList);
    on<UpdateClinicInListEvent>(_onUpdateClinicInList);

    // Listen to search subject with debounce
    _searchSubject
        .debounceTime(const Duration(milliseconds: 700))
        .listen((searchText) {
      add(GetAllClinicsEvent());
    });
  }

  static GetClinicsCubit get(BuildContext context) => BlocProvider.of(context);

  // Call this when you want to trigger search with debounce
  void onSearchChanged(String searchText) {
    // Update state immediately for UI feedback
    emit(state.copyWith(search: searchText, page: 1));
    // Trigger debounced search
    _searchSubject.add(searchText);
  }

  // Get GetClinics
  Future<void> _onGetAllClinics(
      GetAllClinicsEvent event, Emitter<GetClinicsState> emit) async {
    log('message');
    try {
      emit(state.copyWith(state: GetClinicsStatus.loading));

      final clinics = await clinicRepo.getAllClinics(
          page: event.noPagination ? null : state.page, 
          search: (state.search?.isNotEmpty ?? false) ? state.search : null);

      emit(state.copyWith(state: GetClinicsStatus.success, clinics: clinics));
    } catch (e) {
      if (e.toString().toLowerCase().contains('no internet connection')) {
        emit(state.copyWith(
            state: GetClinicsStatus.noConnection, errorMessage: e.toString()));
        return;
      }
      if (e.toString().toLowerCase().contains('request cancelled')) {
        return;
      }
      emit(state.copyWith(
          state: GetClinicsStatus.error, errorMessage: e.toString()));
    }
  }

  // Set search (for non-debounced updates if needed)
  Future<void> _onSetSearch(
      SetSearchEvent event, Emitter<GetClinicsState> emit) async {
    emit(state.copyWith(search: event.search, page: 1));
  }

  // Set page
  Future<void> _onSetPage(
      SetPageEvent event, Emitter<GetClinicsState> emit) async {
    emit(state.copyWith(page: event.page));
  }

  // Remove clinic
  Future<void> _onRemoveClinic(
      RemoveClinicsEvent event, Emitter<GetClinicsState> emit) async {
    if (state.clinics == null ||
        state.clinics!.clinics!.isEmpty ||
        event.index < 0 ||
        event.index >= state.clinics!.clinics!.length) {
      return;
    }

    final updatedGetClinics = ClinicsModel(
      clinics: List.from(state.clinics!.clinics)..removeAt(event.index),
      total: state.clinics!.total,
      totalPages: state.clinics!.totalPages,
    );

    emit(state.copyWith(clinics: updatedGetClinics));
  }

  // Reset filters
  Future<void> _onResetFilters(
      ResetFiltersEvent event, Emitter<GetClinicsState> emit) async {
    emit(state.copyWith(page: 1, search: ''));
    add(GetAllClinicsEvent());
  }

  // Add clinic to list manually
  Future<void> _onAddClinicToList(
      AddClinicToListEvent event, Emitter<GetClinicsState> emit) async {
    if (state.clinics == null) {
      return;
    }

    final currentList = state.clinics!.clinics;
    List<Clinic> updatedList = List.from(currentList)..insert(0, event.clinic);

    final updatedGetClinics = ClinicsModel(
      clinics: updatedList,
      total: (state.clinics!.total ?? 0) + 1,
      totalPages: state.clinics!.totalPages,
    );

    emit(state.copyWith(clinics: updatedGetClinics));
  }

  // Update clinic in list manually
  Future<void> _onUpdateClinicInList(
      UpdateClinicInListEvent event, Emitter<GetClinicsState> emit) async {
    if (state.clinics == null || state.clinics!.clinics.isEmpty) {
      return;
    }

    final currentList = state.clinics!.clinics;
    final index =
        currentList.indexWhere((element) => element.id == event.clinic.id);

    if (index != -1) {
      List<Clinic> updatedList = List.from(currentList);
      updatedList[index] = event.clinic;

      final updatedGetClinics = ClinicsModel(
        clinics: updatedList,
        total: state.clinics!.total,
        totalPages: state.clinics!.totalPages,
      );
      emit(state.copyWith(clinics: updatedGetClinics));
    }
  }

  @override
  Future<void> close() {
    _searchSubject.close();
    return super.close();
  }
}
