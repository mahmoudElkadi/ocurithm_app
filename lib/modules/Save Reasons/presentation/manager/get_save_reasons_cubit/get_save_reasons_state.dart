part of 'get_save_reasons_cubit.dart';

enum GetSaveReasonsStatus {
  initial,
  loading,
  success,
  error,
  noConnection,
  loadingMore,
}

/// State for GetSaveReasonsCubit
class GetSaveReasonsState {
  final GetSaveReasonsStatus state;
  final SaveReasonsModel? saveReasons;
  final String? errorMessage;
  final int currentPage;
  final String searchQuery;
  final bool hasReachedMax;

  const GetSaveReasonsState({
    this.state = GetSaveReasonsStatus.initial,
    this.saveReasons,
    this.errorMessage,
    this.currentPage = 1,
    this.searchQuery = '',
    this.hasReachedMax = false,
  });

  bool get isInitial => state == GetSaveReasonsStatus.initial;
  bool get isLoading => state == GetSaveReasonsStatus.loading;
  bool get isLoadingMore => state == GetSaveReasonsStatus.loadingMore;
  bool get isSuccess => state == GetSaveReasonsStatus.success;
  bool get isError => state == GetSaveReasonsStatus.error;
  bool get noConnection => state == GetSaveReasonsStatus.noConnection;

  GetSaveReasonsState copyWith({
    GetSaveReasonsStatus? state,
    SaveReasonsModel? saveReasons,
    String? errorMessage,
    int? currentPage,
    String? searchQuery,
    bool? hasReachedMax,
  }) {
    return GetSaveReasonsState(
      state: state ?? this.state,
      saveReasons: saveReasons ?? this.saveReasons,
      errorMessage: errorMessage,
      currentPage: currentPage ?? this.currentPage,
      searchQuery: searchQuery ?? this.searchQuery,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
    );
  }
}
