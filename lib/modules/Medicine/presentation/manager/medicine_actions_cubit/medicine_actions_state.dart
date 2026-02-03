part of 'medicine_actions_cubit.dart';

enum MedicineActionsStatus { initial, loading, success, error, noConnection }

enum MedicineActionType {
  createMedicine,
  updateMedicine,
  deleteMedicine,
  createActiveIngredient,
  updateActiveIngredient,
  deleteActiveIngredient,
  none
}

class MedicineActionsState {
  final MedicineActionsStatus status;
  final MedicineActionType actionType;
  final String? successMessage;
  final String? errorMessage;

  const MedicineActionsState({
    this.status = MedicineActionsStatus.initial,
    this.actionType = MedicineActionType.none,
    this.successMessage,
    this.errorMessage,
  });

  MedicineActionsState copyWith({
    MedicineActionsStatus? status,
    MedicineActionType? actionType,
    String? successMessage,
    String? errorMessage,
  }) {
    return MedicineActionsState(
      status: status ?? this.status,
      actionType: actionType ?? this.actionType,
      successMessage: successMessage ?? this.successMessage,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}
