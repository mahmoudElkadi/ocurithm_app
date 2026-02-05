import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rxdart/rxdart.dart';

import '../../../data/model/examination_type_model.dart';
import '../../../data/repos/examination_type_repo.dart';

part 'get_examination_types_event.dart';
part 'get_examination_types_state.dart';

/// Cubit for fetching examination types with pagination and search
class GetExaminationTypesCubit
    extends Bloc<GetExaminationTypesEvent, GetExaminationTypesState> {
  final ExaminationTypeRepo examinationTypeRepo;

  // Debounce controller for search
  final _searchSubject = BehaviorSubject<String>();
  StreamSubscription? _searchSubscription;

  GetExaminationTypesCubit(this.examinationTypeRepo)
      : super(const GetExaminationTypesState()) {
    // Register event handlers
    on<GetAllExaminationTypesEvent>(_onGetAllExaminationTypes);
    on<SetSearchEvent>(_onSetSearch);

    // Setup debounced search - always resets to page 1
    _searchSubscription = _searchSubject
        .debounceTime(const Duration(milliseconds: 500))
        .distinct()
        .listen((_) {
      add(const GetAllExaminationTypesEvent(page: 1));
    });
  }

  /// Handle search query changes with debounce
  void onSearchChanged(String query) {
    _searchSubject.add(query);
    add(SetSearchEvent(query));
  }

  /// Change page public function
  void changePage(int page) {
    add(GetAllExaminationTypesEvent(page: page));
  }

  /// Fetch examination types (unified for initial load, search, and pagination)
  Future<void> _onGetAllExaminationTypes(
    GetAllExaminationTypesEvent event,
    Emitter<GetExaminationTypesState> emit,
  ) async {
    emit(state.copyWith(
      status: GetExaminationTypesStatus.loading,
      currentPage: event.page,
      errorMessage: null,
    ));

    try {
      final result = await examinationTypeRepo.getAllExaminationTypes(
        page: event.noPagination ? null : (event.page ?? 1),
        search: state.searchQuery.isNotEmpty ? state.searchQuery : null,
      );

      if (result.error == null && result.examinationTypes != null) {
        emit(state.copyWith(
          status: GetExaminationTypesStatus.success,
          examinationTypes: result,
          currentPage: event.page,
          hasReachedMax: result.examinationTypes!.isEmpty,
        ));
      } else {
        emit(state.copyWith(
          status: GetExaminationTypesStatus.error,
          errorMessage: result.error ?? 'Failed to load examination types',
        ));
      }
    } catch (e) {
      if (e.toString().toLowerCase().contains('no internet connection')) {
        emit(state.copyWith(
          status: GetExaminationTypesStatus.noConnection,
          errorMessage: e.toString(),
        ));
        return;
      }
      if (e.toString().toLowerCase().contains('request cancelled')) {
        return;
      }
      emit(state.copyWith(
        status: GetExaminationTypesStatus.error,
        errorMessage: e.toString(),
      ));
    }
  }

  /// Set search query (doesn't trigger search immediately)
  void _onSetSearch(
    SetSearchEvent event,
    Emitter<GetExaminationTypesState> emit,
  ) {
    emit(state.copyWith(searchQuery: event.query));
  }

  @override
  Future<void> close() {
    _searchSubscription?.cancel();
    _searchSubject.close();
    return super.close();
  }
}
