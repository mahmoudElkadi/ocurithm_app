import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ocurithm/modules/Receptionist/data/models/receptionists_model.dart';
import 'package:ocurithm/modules/Receptionist/data/repos/receptionist_repo.dart';
import 'package:rxdart/rxdart.dart';

part 'get_receptionists_state.dart';
part 'get_receptionists_event.dart';

/// Cubit for fetching and managing receptionists list
/// Includes debounced search, pagination, and filters
class GetReceptionistsCubit
    extends Bloc<GetReceptionistsEvent, GetReceptionistsState> {
  final ReceptionistRepo receptionistRepo;
  final _searchSubject = BehaviorSubject<String>();

  GetReceptionistsCubit(this.receptionistRepo)
      : super(const GetReceptionistsState()) {
    on<GetAllReceptionistsEvent>(_onGetAllReceptionists);
    on<SetPageEvent>(_onSetPage);
    on<RemoveReceptionistEvent>(_onRemoveReceptionist);
    on<ResetReceptionistFilters>(_onResetFilters);
    on<SetSearchEvent>(_onSetSearch);
    on<SetClinicFilterEvent>(_onSetClinicFilter);
    on<SetBranchFilterEvent>(_onSetBranchFilter);

    // Listen to search subject with debounce
    _searchSubject
        .debounceTime(const Duration(milliseconds: 700))
        .listen((searchText) {
      add(GetAllReceptionistsEvent());
    });
  }

  static GetReceptionistsCubit get(BuildContext context) =>
      BlocProvider.of(context);

  // Call this when you want to trigger search with debounce
  void onSearchChanged(String searchText) {
    // Update state immediately for UI feedback by dispatching event
    add(SetSearchEvent(searchText));
    // Trigger debounced search
    _searchSubject.add(searchText);
  }

  // Get All Receptionists
  Future<void> _onGetAllReceptionists(GetAllReceptionistsEvent event,
      Emitter<GetReceptionistsState> emit) async {
    try {
      emit(state.copyWith(state: GetReceptionistsStatus.loading));

      final receptionists = await receptionistRepo.getAllReceptionists(
        page: state.page,
        search: state.search,
        clinic: state.clinicFilter,
        branch: state.branchFilter,
      );

      emit(state.copyWith(
        state: GetReceptionistsStatus.success,
        receptionists: receptionists,
      ));
    } catch (e) {
      if (e.toString().toLowerCase().contains('no internet connection')) {
        emit(state.copyWith(
          state: GetReceptionistsStatus.noConnection,
          errorMessage: e.toString(),
        ));
        return;
      }
      if (e.toString().toLowerCase().contains('request cancelled')) {
        return;
      }
      emit(state.copyWith(
        state: GetReceptionistsStatus.error,
        errorMessage: e.toString(),
      ));
    }
  }

  // Set search (for non-debounced updates if needed)
  Future<void> _onSetSearch(
      SetSearchEvent event, Emitter<GetReceptionistsState> emit) async {
    emit(state.copyWith(search: event.search, page: 1));
  }

  // Set page
  Future<void> _onSetPage(
      SetPageEvent event, Emitter<GetReceptionistsState> emit) async {
    emit(state.copyWith(page: event.page));
  }

  // Set clinic filter
  Future<void> _onSetClinicFilter(
      SetClinicFilterEvent event, Emitter<GetReceptionistsState> emit) async {
    emit(state.copyWith(clinicFilter: event.clinicId, page: 1));
    add(GetAllReceptionistsEvent());
  }

  // Set branch filter
  Future<void> _onSetBranchFilter(
      SetBranchFilterEvent event, Emitter<GetReceptionistsState> emit) async {
    emit(state.copyWith(branchFilter: event.branchId, page: 1));
    add(GetAllReceptionistsEvent());
  }

  // Remove receptionist
  Future<void> _onRemoveReceptionist(RemoveReceptionistEvent event,
      Emitter<GetReceptionistsState> emit) async {
    if (state.receptionists == null ||
        state.receptionists!.receptionists.isEmpty ||
        event.index < 0 ||
        event.index >= state.receptionists!.receptionists.length) {
      return;
    }

    final updatedReceptionists = ReceptionistsModel(
      receptionists: List.from(state.receptionists!.receptionists)
        ..removeAt(event.index),
      total: state.receptionists!.total,
      totalPages: state.receptionists!.totalPages,
    );

    emit(state.copyWith(receptionists: updatedReceptionists));
  }

  // Reset filters
  Future<void> _onResetFilters(ResetReceptionistFilters event,
      Emitter<GetReceptionistsState> emit) async {
    emit(state.copyWith(
      page: 1,
      search: '',
      clinicFilter: null,
      branchFilter: null,
    ));
    add(GetAllReceptionistsEvent());
  }

  @override
  Future<void> close() {
    _searchSubject.close();
    return super.close();
  }
}
