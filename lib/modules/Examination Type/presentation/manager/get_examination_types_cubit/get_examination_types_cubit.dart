import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';
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
    on<LoadMoreExaminationTypesEvent>(_onLoadMoreExaminationTypes);
    on<SetSearchEvent>(_onSetSearch);
    on<SearchExaminationTypesEvent>(_onSearchExaminationTypes);

    // Setup debounced search
    _searchSubscription = _searchSubject
        .debounceTime(const Duration(milliseconds: 500))
        .distinct()
        .listen((query) {
      add(SearchExaminationTypesEvent(query));
    });
  }

  /// Handle search query changes with debounce
  void onSearchChanged(String query) {
    _searchSubject.add(query);
    add(SetSearchEvent(query));
  }

  /// Fetch all examination types (first page)
  Future<void> _onGetAllExaminationTypes(
    GetAllExaminationTypesEvent event,
    Emitter<GetExaminationTypesState> emit,
  ) async {
    emit(state.copyWith(isLoading: true, errorMessage: null));

    try {
      // Check internet connection
      final hasConnection = await InternetConnection().hasInternetAccess;
      if (!hasConnection) {
        emit(state.copyWith(
          isLoading: false,
          errorMessage: 'No internet connection',
        ));
        return;
      }

      // Fetch examination types
      final result = await examinationTypeRepo.getAllExaminationTypes(
        page: 1,
        search: state.searchQuery,
      );

      if (result.error == null && result.examinationTypes != null) {
        emit(state.copyWith(
          isLoading: false,
          examinationTypes: result,
          currentPage: 1,
          hasReachedMax: result.examinationTypes!.isEmpty,
        ));
      } else {
        emit(state.copyWith(
          isLoading: false,
          errorMessage: result.error ?? 'Failed to load examination types',
        ));
      }
    } catch (e) {
      emit(state.copyWith(
        isLoading: false,
        errorMessage: 'An error occurred: ${e.toString()}',
      ));
    }
  }

  /// Load more examination types (next page)
  Future<void> _onLoadMoreExaminationTypes(
    LoadMoreExaminationTypesEvent event,
    Emitter<GetExaminationTypesState> emit,
  ) async {
    if (state.isLoadingMore || state.hasReachedMax) return;

    emit(state.copyWith(isLoadingMore: true));

    try {
      final nextPage = state.currentPage + 1;
      final result = await examinationTypeRepo.getAllExaminationTypes(
        page: nextPage,
        search: state.searchQuery,
      );

      if (result.error == null && result.examinationTypes != null) {
        // Merge new examination types with existing ones
        final updatedExaminationTypes =
            state.examinationTypes?.examinationTypes ?? [];
        updatedExaminationTypes.addAll(result.examinationTypes!);

        emit(state.copyWith(
          isLoadingMore: false,
          currentPage: nextPage,
          hasReachedMax: result.examinationTypes!.isEmpty,
        ));
      } else {
        emit(state.copyWith(isLoadingMore: false));
      }
    } catch (e) {
      emit(state.copyWith(isLoadingMore: false));
    }
  }

  /// Set search query (doesn't trigger search immediately)
  void _onSetSearch(
    SetSearchEvent event,
    Emitter<GetExaminationTypesState> emit,
  ) {
    emit(state.copyWith(searchQuery: event.query));
  }

  /// Search examination types (triggered after debounce)
  Future<void> _onSearchExaminationTypes(
    SearchExaminationTypesEvent event,
    Emitter<GetExaminationTypesState> emit,
  ) async {
    emit(state.copyWith(isLoading: true, errorMessage: null));

    try {
      final hasConnection = await InternetConnection().hasInternetAccess;
      if (!hasConnection) {
        emit(state.copyWith(
          isLoading: false,
          errorMessage: 'No internet connection',
        ));
        return;
      }

      final result = await examinationTypeRepo.getAllExaminationTypes(
        page: 1,
        search: event.query,
      );

      if (result.error == null && result.examinationTypes != null) {
        emit(state.copyWith(
          isLoading: false,
          examinationTypes: result,
          currentPage: 1,
          hasReachedMax: result.examinationTypes!.isEmpty,
        ));
      } else {
        emit(state.copyWith(
          isLoading: false,
          errorMessage: result.error ?? 'Failed to search examination types',
        ));
      }
    } catch (e) {
      emit(state.copyWith(
        isLoading: false,
        errorMessage: 'An error occurred: ${e.toString()}',
      ));
    }
  }

  @override
  Future<void> close() {
    _searchSubscription?.cancel();
    _searchSubject.close();
    return super.close();
  }
}
