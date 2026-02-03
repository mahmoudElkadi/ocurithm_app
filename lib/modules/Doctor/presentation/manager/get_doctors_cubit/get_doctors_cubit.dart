import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ocurithm/modules/Doctor/data/model/doctor_model.dart';
import 'package:ocurithm/modules/Doctor/data/repos/doctor_repo.dart';
import 'package:rxdart/rxdart.dart';

part 'get_doctors_state.dart';
part 'get_doctors_event.dart';

/// Cubit for fetching and managing doctors list
/// Includes debounced search, pagination, and filters
class GetDoctorsCubit extends Bloc<GetDoctorsEvent, GetDoctorsState> {
  final DoctorRepo doctorRepo;
  final _searchSubject = BehaviorSubject<String>();

  GetDoctorsCubit(this.doctorRepo) : super(const GetDoctorsState()) {
    on<GetAllDoctorsEvent>(_onGetAllDoctors);
    on<SetPageEvent>(_onSetPage);
    on<RemoveDoctorEvent>(_onRemoveDoctor);
    on<ResetDoctorFilters>(_onResetFilters);
    on<SetSearchEvent>(_onSetSearch);
    on<SetClinicFilterEvent>(_onSetClinicFilter);
    on<SetBranchFilterEvent>(_onSetBranchFilter);

    // Listen to search subject with debounce
    _searchSubject
        .debounceTime(const Duration(milliseconds: 700))
        .listen((searchText) {
      add(GetAllDoctorsEvent());
    });
  }

  static GetDoctorsCubit get(BuildContext context) => BlocProvider.of(context);

  // Call this when you want to trigger search with debounce
  void onSearchChanged(String searchText) {
    // Update state immediately for UI feedback by dispatching event
    add(SetSearchEvent(searchText));
    // Trigger debounced search
    _searchSubject.add(searchText);
  }

  // Get All Doctors
  Future<void> _onGetAllDoctors(
      GetAllDoctorsEvent event, Emitter<GetDoctorsState> emit) async {
    try {
      emit(state.copyWith(state: GetDoctorsStatus.loading));

      final doctors = await doctorRepo.getAllDoctors(
        page: state.page,
        search: state.search,
        clinic: state.clinicFilter,
        branch: state.branchFilter,
      );

      emit(state.copyWith(
        state: GetDoctorsStatus.success,
        doctors: doctors,
      ));
    } catch (e) {
      if (e.toString().toLowerCase().contains('no internet connection')) {
        emit(state.copyWith(
          state: GetDoctorsStatus.noConnection,
          errorMessage: e.toString(),
        ));
        return;
      }
      if (e.toString().toLowerCase().contains('request cancelled')) {
        return;
      }
      emit(state.copyWith(
        state: GetDoctorsStatus.error,
        errorMessage: e.toString(),
      ));
    }
  }

  // Set search (for non-debounced updates if needed)
  Future<void> _onSetSearch(
      SetSearchEvent event, Emitter<GetDoctorsState> emit) async {
    emit(state.copyWith(search: event.search, page: 1));
  }

  // Set page
  Future<void> _onSetPage(
      SetPageEvent event, Emitter<GetDoctorsState> emit) async {
    emit(state.copyWith(page: event.page));
  }

  // Set clinic filter
  Future<void> _onSetClinicFilter(
      SetClinicFilterEvent event, Emitter<GetDoctorsState> emit) async {
    emit(state.copyWith(clinicFilter: event.clinicId, branchFilter: null, page: 1));
  }

  // Set branch filter
  Future<void> _onSetBranchFilter(
      SetBranchFilterEvent event, Emitter<GetDoctorsState> emit) async {
    emit(state.copyWith(branchFilter: event.branchId, page: 1));
  }

  // Remove doctor
  Future<void> _onRemoveDoctor(
      RemoveDoctorEvent event, Emitter<GetDoctorsState> emit) async {
    if (state.doctors == null ||
        state.doctors!.doctors.isEmpty ||
        event.index < 0 ||
        event.index >= state.doctors!.doctors.length) {
      return;
    }

    final updatedDoctors = DoctorModel(
      doctors: List.from(state.doctors!.doctors)..removeAt(event.index),
      total: state.doctors!.total,
      totalPages: state.doctors!.totalPages,
    );

    emit(state.copyWith(doctors: updatedDoctors));
  }

  // Reset filters
  Future<void> _onResetFilters(
      ResetDoctorFilters event, Emitter<GetDoctorsState> emit) async {
    emit(state.copyWith(
      page: 1,
      search: '',
      clinicFilter: null,
      branchFilter: null,
    ));
    add(GetAllDoctorsEvent());
  }

  @override
  Future<void> close() {
    _searchSubject.close();
    return super.close();
  }
}
