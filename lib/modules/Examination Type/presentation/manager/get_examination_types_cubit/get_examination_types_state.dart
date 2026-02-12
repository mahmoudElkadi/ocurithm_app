part of 'get_examination_types_cubit.dart';

/// Status enum for fetching examination types
enum GetExaminationTypesStatus {
  initial,
  loading,
  success,
  error,
  noConnection,
}

/// State for GetExaminationTypesCubit
class GetExaminationTypesState {
  final GetExaminationTypesStatus status;
  final ExaminationTypesModel? examinationTypes;
  final String? errorMessage;
  final int currentPage;
  final String searchQuery;
  final bool hasReachedMax;
  final String? clinicFilter;

  const GetExaminationTypesState({
    this.status = GetExaminationTypesStatus.initial,
    this.examinationTypes,
    this.errorMessage,
    this.currentPage = 1,
    this.searchQuery = '',
    this.hasReachedMax = false,
    this.clinicFilter,
  });

  GetExaminationTypesState copyWith({
    GetExaminationTypesStatus? status,
    ExaminationTypesModel? examinationTypes,
    String? errorMessage,
    int? currentPage,
    String? searchQuery,
    bool? hasReachedMax,
    String? clinicFilter,
  }) {
    return GetExaminationTypesState(
      status: status ?? this.status,
      examinationTypes: examinationTypes ?? this.examinationTypes,
      errorMessage: errorMessage,
      currentPage: currentPage ?? this.currentPage,
      searchQuery: searchQuery ?? this.searchQuery,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
      clinicFilter: clinicFilter ?? this.clinicFilter,
    );
  }

  bool get isInitial => status == GetExaminationTypesStatus.initial;
  bool get isLoading => status == GetExaminationTypesStatus.loading;
  bool get isSuccess => status == GetExaminationTypesStatus.success;
  bool get isError => status == GetExaminationTypesStatus.error;
  bool get noConnection => status == GetExaminationTypesStatus.noConnection;
}
