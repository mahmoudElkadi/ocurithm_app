part of 'get_single_branch_cubit.dart';

enum GetSingleBranchStatus { initial, loading, success, error, noConnection }

extension GetSingleBranchStatusX on GetSingleBranchState {
  bool get isInitial => state == GetSingleBranchStatus.initial;

  bool get isLoading => state == GetSingleBranchStatus.loading;

  bool get isSuccess => state == GetSingleBranchStatus.success;

  bool get isError => state == GetSingleBranchStatus.error;

  bool get noConnection => state == GetSingleBranchStatus.noConnection;
}

@immutable
class GetSingleBranchState {
  final GetSingleBranchStatus state;
  final String? errorMessage;
  final AddBranchModel? branch;

  const GetSingleBranchState({
    this.state = GetSingleBranchStatus.initial,
    this.errorMessage,
    this.branch,
  });

  GetSingleBranchState copyWith({
    GetSingleBranchStatus? state,
    String? errorMessage,
    AddBranchModel? branch,
  }) {
    return GetSingleBranchState(
      state: state ?? this.state,
      errorMessage: errorMessage ?? this.errorMessage,
      branch: branch ?? this.branch,
    );
  }
}
