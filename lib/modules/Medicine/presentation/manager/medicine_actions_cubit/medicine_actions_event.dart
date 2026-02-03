part of 'medicine_actions_cubit.dart';

abstract class MedicineActionsEvent {}

class CreateMedicineEvent extends MedicineActionsEvent {
  final CommercialName medicine;
  CreateMedicineEvent(this.medicine);
}

class UpdateMedicineEvent extends MedicineActionsEvent {
  final String id;
  final CommercialName medicine;
  UpdateMedicineEvent(this.id, this.medicine);
}

class DeleteMedicineEvent extends MedicineActionsEvent {
  final String id;
  DeleteMedicineEvent(this.id);
}

class CreateActiveIngredientEvent extends MedicineActionsEvent {
  final ActiveIngredient activeIngredient;
  CreateActiveIngredientEvent(this.activeIngredient);
}

class UpdateActiveIngredientEvent extends MedicineActionsEvent {
  final String id;
  final ActiveIngredient activeIngredient;
  UpdateActiveIngredientEvent(this.id, this.activeIngredient);
}

class DeleteActiveIngredientEvent extends MedicineActionsEvent {
  final String id;
  DeleteActiveIngredientEvent(this.id);
}

class ResetMedicineActionsEvent extends MedicineActionsEvent {}
