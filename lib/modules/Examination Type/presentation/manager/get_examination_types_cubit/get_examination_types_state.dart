part of 'get_examination_types_cubit.dart';

/// State for GetExaminationTypesCubit
class GetExaminationTypesState {
  final ExaminationTypesModel? examinationTypes;
  final bool isLoading;
  final bool isLoadingMore;
  final String? errorMessage;
  final int currentPage;
  final String searchQuery;
  final bool hasReachedMax;

  const GetExaminationTypesState({
    this.examinationTypes,
    this.isLoading = false,
    this.isLoadingMore = false,
    this.errorMessage,
    this.currentPage = 1,
    this.searchQuery = '',
    this.hasReachedMax = false,
  });

  GetExaminationTypesState copyWith({
    ExaminationTypesModel? examinationTypes,
    bool? isLoading,
    bool? isLoadingMore,
    String? errorMessage,
    int? currentPage,
    String? searchQuery,
    bool? hasReachedMax,
  }) {
    return GetExaminationTypesState(
      examinationTypes: examinationTypes ?? this.examinationTypes,
      isLoading: isLoading ?? this.isLoading,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      errorMessage: errorMessage,
      currentPage: currentPage ?? this.currentPage,
      searchQuery: searchQuery ?? this.searchQuery,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
    );
  }
}
