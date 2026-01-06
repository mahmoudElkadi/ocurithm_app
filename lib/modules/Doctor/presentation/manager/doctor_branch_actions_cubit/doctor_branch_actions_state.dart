part of 'doctor_branch_actions_cubit.dart';

/// State for Doctor Branch Actions
class DoctorBranchActionsState {
  final bool isLoading;
  final bool isSuccess;
  final bool isError;
  final String? errorMessage;
  final String? successMessage;
  final BranchActionType? actionType;

  const DoctorBranchActionsState({
    this.isLoading = false,
    this.isSuccess = false,
    this.isError = false,
    this.errorMessage,
    this.successMessage,
    this.actionType,
  });

  DoctorBranchActionsState copyWith({
    bool? isLoading,
    bool? isSuccess,
    bool? isError,
    String? errorMessage,
    String? successMessage,
    BranchActionType? actionType,
  }) {
    return DoctorBranchActionsState(
      isLoading: isLoading ?? this.isLoading,
      isSuccess: isSuccess ?? this.isSuccess,
      isError: isError ?? this.isError,
      errorMessage: errorMessage ?? this.errorMessage,
      successMessage: successMessage ?? this.successMessage,
      actionType: actionType ?? this.actionType,
    );
  }
}

/// Types of branch actions
enum BranchActionType {
  add,
  edit,
  delete,
}
