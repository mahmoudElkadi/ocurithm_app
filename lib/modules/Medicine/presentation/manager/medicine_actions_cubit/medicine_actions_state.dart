part of 'medicine_actions_cubit.dart';

abstract class MedicineActionsState {}

class MedicineActionsInitial extends MedicineActionsState {}

class MedicineActionsLoading extends MedicineActionsState {}

class MedicineActionsSuccess extends MedicineActionsState {
  final String message;
  MedicineActionsSuccess({required this.message});
}

class MedicineActionsError extends MedicineActionsState {
  final String error;
  MedicineActionsError({required this.error});
}
