import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rxdart/rxdart.dart';

import '../../../data/model/save_reason_model.dart';
import '../../../data/repos/save_reason_repo.dart';

part 'get_save_reasons_event.dart';
part 'get_save_reasons_state.dart';

/// Fetches save reasons with pagination and debounced search.
///
/// Also used unpaginated by the examination flow, which needs the clinic's whole
/// catalog at once to decide whether to prompt for a reason at all.
class GetSaveReasonsCubit
    extends Bloc<GetSaveReasonsEvent, GetSaveReasonsState> {
  final SaveReasonRepo saveReasonRepo;

  final _searchSubject = BehaviorSubject<String>();
  StreamSubscription? _searchSubscription;

  GetSaveReasonsCubit(this.saveReasonRepo)
      : super(const GetSaveReasonsState()) {
    on<GetAllSaveReasonsEvent>(_onGetAllSaveReasons);
    on<LoadMoreSaveReasonsEvent>(_onLoadMoreSaveReasons);
    on<SetSaveReasonSearchEvent>(_onSetSearch);
    on<SearchSaveReasonsEvent>(_onSearchSaveReasons);

    _searchSubscription = _searchSubject
        .debounceTime(const Duration(milliseconds: 500))
        .distinct()
        .listen((query) {
      add(SearchSaveReasonsEvent(query));
    });
  }

  void onSearchChanged(String query) {
    _searchSubject.add(query);
    add(SetSaveReasonSearchEvent(query));
  }

  Future<void> _onGetAllSaveReasons(
    GetAllSaveReasonsEvent event,
    Emitter<GetSaveReasonsState> emit,
  ) async {
    emit(state.copyWith(
      state: GetSaveReasonsStatus.loading,
      errorMessage: null,
    ));

    try {
      final result = await saveReasonRepo.getAllSaveReasons(
        page: event.noPagination ? null : 1,
        search: state.searchQuery.isNotEmpty ? state.searchQuery : null,
      );

      emit(state.copyWith(
        state: GetSaveReasonsStatus.success,
        saveReasons: result,
        currentPage: 1,
        hasReachedMax: result.saveReasons?.isEmpty ?? true,
      ));
    } catch (e) {
      emit(state.copyWith(
        state: e.toString().toLowerCase().contains('no internet connection')
            ? GetSaveReasonsStatus.noConnection
            : GetSaveReasonsStatus.error,
        errorMessage: e.toString(),
      ));
    }
  }

  Future<void> _onLoadMoreSaveReasons(
    LoadMoreSaveReasonsEvent event,
    Emitter<GetSaveReasonsState> emit,
  ) async {
    if (state.isLoadingMore || state.hasReachedMax) return;

    emit(state.copyWith(state: GetSaveReasonsStatus.loadingMore));

    try {
      final nextPage = state.currentPage + 1;
      final result = await saveReasonRepo.getAllSaveReasons(
        page: nextPage,
        search: state.searchQuery,
      );

      final merged =
          List<SaveReason>.from(state.saveReasons?.saveReasons ?? [])
            ..addAll(result.saveReasons ?? []);

      emit(state.copyWith(
        state: GetSaveReasonsStatus.success,
        saveReasons: state.saveReasons?.copyWith(saveReasons: merged),
        currentPage: nextPage,
        hasReachedMax: result.saveReasons?.isEmpty ?? true,
      ));
    } catch (e) {
      emit(state.copyWith(
        state: GetSaveReasonsStatus.error,
        errorMessage: e.toString(),
      ));
    }
  }

  void _onSetSearch(
    SetSaveReasonSearchEvent event,
    Emitter<GetSaveReasonsState> emit,
  ) {
    emit(state.copyWith(searchQuery: event.query));
  }

  Future<void> _onSearchSaveReasons(
    SearchSaveReasonsEvent event,
    Emitter<GetSaveReasonsState> emit,
  ) async {
    emit(state.copyWith(
      state: GetSaveReasonsStatus.loading,
      errorMessage: null,
    ));

    try {
      final result = await saveReasonRepo.getAllSaveReasons(
        page: 1,
        search: event.query,
      );

      emit(state.copyWith(
        state: GetSaveReasonsStatus.success,
        saveReasons: result,
        currentPage: 1,
        hasReachedMax: result.saveReasons?.isEmpty ?? true,
      ));
    } catch (e) {
      emit(state.copyWith(
        state: e.toString().toLowerCase().contains('no internet connection')
            ? GetSaveReasonsStatus.noConnection
            : GetSaveReasonsStatus.error,
        errorMessage: e.toString(),
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
