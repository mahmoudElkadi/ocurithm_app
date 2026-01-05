part of 'get_receptionists_cubit.dart';

enum GetReceptionistsStatus {
  initial,
  loading,
  success,
  error,
  noConnection,
  loadingMore
}

extension GetReceptionistsStatusX on GetReceptionistsState {
  bool get isInitial => state == GetReceptionistsStatus.initial;

  bool get isLoading => state == GetReceptionistsStatus.loading;

  bool get isLoadingMore => state == GetReceptionistsStatus.loadingMore;

  bool get isSuccess => state == GetReceptionistsStatus.success;

  bool get isError => state == GetReceptionistsStatus.error;

  bool get noConnection => state == GetReceptionistsStatus.noConnection;
}

@immutable
class GetReceptionistsState {
  final GetReceptionistsStatus state;
  final String? errorMessage;
  final String? search;
  final int page;
  final String? clinicFilter;
  final String? branchFilter;
  final ReceptionistsModel? receptionists;

  const GetReceptionistsState({
    this.state = GetReceptionistsStatus.initial,
    this.errorMessage,
    this.search,
    this.page = 1,
    this.clinicFilter,
    this.branchFilter,
    this.receptionists,
  });

  GetReceptionistsState copyWith({
    GetReceptionistsStatus? state,
    String? errorMessage,
    String? search,
    int? page,
    String? clinicFilter,
    String? branchFilter,
    ReceptionistsModel? receptionists,
  }) {
    return GetReceptionistsState(
      state: state ?? this.state,
      search: search ?? this.search,
      errorMessage: errorMessage ?? this.errorMessage,
      page: page ?? this.page,
      clinicFilter: clinicFilter ?? this.clinicFilter,
      branchFilter: branchFilter ?? this.branchFilter,
      receptionists: receptionists ?? this.receptionists,
    );
  }
}
