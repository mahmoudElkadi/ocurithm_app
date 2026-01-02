import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ocurithm/modules/Branch/data/model/branches_model.dart';
import 'package:ocurithm/modules/Branch/data/repos/branch_repo.dart';
import 'package:rxdart/rxdart.dart';

part 'get_branches_state.dart';
part 'get_branches_event.dart';

class GetBranchesCubit extends Bloc<GetBranchesEvent, GetBranchesState> {
  final BranchRepo branchRepo;
  final _searchSubject = BehaviorSubject<String>();

  GetBranchesCubit(this.branchRepo) : super(GetBranchesState()) {
    on<GetAllBranchesEvent>(_onGetAllBranches);
    on<SetPageEvent>(_onSetPage);
    on<RemoveBranchesEvent>(_onRemoveBranch);
    on<ResetBranchFilters>(_onResetFilters);
    on<SetSearchEvent>(_onSetSearch);
    on<SetClinicFilterEvent>(_onSetClinicFilter);

    // Listen to search subject with debounce
    _searchSubject
        .debounceTime(const Duration(milliseconds: 700))
        .listen((searchText) {
      add(GetAllBranchesEvent());
    });
  }

  static GetBranchesCubit get(BuildContext context) => BlocProvider.of(context);

  // Call this when you want to trigger search with debounce
  void onSearchChanged(String searchText) {
    // Update state immediately for UI feedback by dispatching event
    add(SetSearchEvent(searchText));
    // Trigger debounced search
    _searchSubject.add(searchText);
  }

  // Get GetBranches
  Future<void> _onGetAllBranches(
      GetBranchesEvent event, Emitter<GetBranchesState> emit) async {
    try {
      emit(state.copyWith(state: GetBranchesStatus.loading));

      final branches = await branchRepo.getAllBranches(
        page: state.page,
        search: state.search,
        clinic: state.clinicFilter,
      );

      emit(
          state.copyWith(state: GetBranchesStatus.success, branches: branches));
    } catch (e) {
      if (e.toString().toLowerCase().contains('no internet connection')) {
        emit(state.copyWith(
            state: GetBranchesStatus.noConnection, errorMessage: e.toString()));
        return;
      }
      if (e.toString().toLowerCase().contains('request cancelled')) {
        return;
      }
      emit(state.copyWith(
          state: GetBranchesStatus.error, errorMessage: e.toString()));
    }
  }

  // Set search (for non-debounced updates if needed)
  Future<void> _onSetSearch(
      SetSearchEvent event, Emitter<GetBranchesState> emit) async {
    emit(state.copyWith(search: event.search, page: 1));
  }

  // Set page
  Future<void> _onSetPage(
      SetPageEvent event, Emitter<GetBranchesState> emit) async {
    emit(state.copyWith(page: event.page));
  }

  // Set clinic filter
  Future<void> _onSetClinicFilter(
      SetClinicFilterEvent event, Emitter<GetBranchesState> emit) async {
    emit(state.copyWith(clinicFilter: event.clinicId, page: 1));
    add(GetAllBranchesEvent());
  }

  // Remove branch
  Future<void> _onRemoveBranch(
      RemoveBranchesEvent event, Emitter<GetBranchesState> emit) async {
    if (state.branches == null ||
        state.branches!.branches.isEmpty ||
        event.index < 0 ||
        event.index >= state.branches!.branches.length) {
      return;
    }

    final updatedGetBranches = BranchesModel(
      branches: List.from(state.branches!.branches)..removeAt(event.index),
      total: state.branches!.total,
      totalPages: state.branches!.totalPages,
    );

    emit(state.copyWith(branches: updatedGetBranches));
  }

  // Reset filters
  Future<void> _onResetFilters(
      ResetBranchFilters event, Emitter<GetBranchesState> emit) async {
    emit(state.copyWith(page: 1, search: '', clinicFilter: null));
    add(GetAllBranchesEvent());
  }

  @override
  Future<void> close() {
    _searchSubject.close();
    return super.close();
  }
}
