part of 'get_branches_cubit.dart';

enum GetBranchesStatus {
  initial,
  loading,
  success,
  error,
  noConnection,
  loadingMore
}

extension GetBranchesStatusX on GetBranchesState {
  bool get isInitial => state == GetBranchesStatus.initial;

  bool get isLoading => state == GetBranchesStatus.loading;

  bool get isLoadingMore => state == GetBranchesStatus.loadingMore;

  bool get isSuccess => state == GetBranchesStatus.success;

  bool get isError => state == GetBranchesStatus.error;

  bool get noConnection => state == GetBranchesStatus.noConnection;
}

@immutable
class GetBranchesState {
  final GetBranchesStatus state;
  final String? errorMessage;
  final String? search;
  final int page;
   String? clinicFilter;
  final BranchesModel? branches;

   GetBranchesState(
      {this.state = GetBranchesStatus.initial,
      this.errorMessage,
      this.search,
      this.page = 1,
      this.clinicFilter,
      this.branches});

  GetBranchesState copyWith(
      {GetBranchesStatus? state,
      String? errorMessage,
      String? search,
      int? page,
      String? clinicFilter,
      BranchesModel? branches}) {
    return GetBranchesState(
      state: state ?? this.state,
      search: search ?? this.search,
      errorMessage: errorMessage ?? this.errorMessage,
      page: page ?? this.page,
      clinicFilter: clinicFilter ?? this.clinicFilter,
      branches: branches ?? this.branches,
    );
  }
}
