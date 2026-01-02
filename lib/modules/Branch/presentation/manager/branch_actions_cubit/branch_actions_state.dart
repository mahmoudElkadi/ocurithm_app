part of 'branch_actions_cubit.dart';

enum BranchActionType { add, update, delete, none }

enum BranchActionsStatus { initial, loading, success, error, noConnection }

extension BranchActionsStatusX on BranchActionsState {
  bool get isInitial => state == BranchActionsStatus.initial;

  bool get isLoading => state == BranchActionsStatus.loading;

  bool get isSuccess => state == BranchActionsStatus.success;

  bool get isError => state == BranchActionsStatus.error;

  bool get noConnection => state == BranchActionsStatus.noConnection;

  // Add action states
  bool get isAddLoading =>
      state == BranchActionsStatus.loading &&
      actionType == BranchActionType.add;

  bool get isAddSuccess =>
      state == BranchActionsStatus.success &&
      actionType == BranchActionType.add;

  bool get isAddError =>
      state == BranchActionsStatus.error && actionType == BranchActionType.add;

  // Update action states
  bool get isUpdateLoading =>
      state == BranchActionsStatus.loading &&
      actionType == BranchActionType.update;

  bool get isUpdateSuccess =>
      state == BranchActionsStatus.success &&
      actionType == BranchActionType.update;

  bool get isUpdateError =>
      state == BranchActionsStatus.error &&
      actionType == BranchActionType.update;

  // Delete action states
  bool get isDeleteLoading =>
      state == BranchActionsStatus.loading &&
      actionType == BranchActionType.delete;

  bool get isDeleteSuccess =>
      state == BranchActionsStatus.success &&
      actionType == BranchActionType.delete;

  bool get isDeleteError =>
      state == BranchActionsStatus.error &&
      actionType == BranchActionType.delete;
}

@immutable
class BranchActionsState {
  final BranchActionsStatus state;
  final BranchActionType actionType;
  final String? errorMessage;
  final String? successMessage;
  final AddBranchModel? branch;

  const BranchActionsState({
    this.state = BranchActionsStatus.initial,
    this.actionType = BranchActionType.none,
    this.errorMessage,
    this.successMessage,
    this.branch,
  });

  BranchActionsState copyWith({
    BranchActionsStatus? state,
    BranchActionType? actionType,
    String? errorMessage,
    String? successMessage,
    AddBranchModel? branch,
  }) {
    return BranchActionsState(
      state: state ?? this.state,
      actionType: actionType ?? this.actionType,
      errorMessage: errorMessage ?? this.errorMessage,
      successMessage: successMessage ?? this.successMessage,
      branch: branch ?? this.branch,
    );
  }
}
