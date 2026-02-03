import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../data/model/active_ingredient_model.dart';
import '../../../data/model/medicine_model.dart';
import '../../../data/repos/medicine_repo.dart';

part 'medicine_actions_state.dart';
part 'medicine_actions_event.dart';

class MedicineActionsCubit
    extends Bloc<MedicineActionsEvent, MedicineActionsState> {
  final MedicineRepo medicineRepo;

  MedicineActionsCubit({required this.medicineRepo})
      : super(const MedicineActionsState()) {
    on<CreateMedicineEvent>(_onCreateMedicine);
    on<UpdateMedicineEvent>(_onUpdateMedicine);
    on<DeleteMedicineEvent>(_onDeleteMedicine);
    on<CreateActiveIngredientEvent>(_onCreateActiveIngredient);
    on<UpdateActiveIngredientEvent>(_onUpdateActiveIngredient);
    on<DeleteActiveIngredientEvent>(_onDeleteActiveIngredient);
    on<ResetMedicineActionsEvent>(_onResetActions);
  }

  static MedicineActionsCubit get(BuildContext context) =>
      BlocProvider.of(context);

  Future<void> _onCreateMedicine(
      CreateMedicineEvent event, Emitter<MedicineActionsState> emit) async {
    try {
      emit(state.copyWith(
          status: MedicineActionsStatus.loading,
          actionType: MedicineActionType.createMedicine));
      await medicineRepo.createMedicine(commercialName: event.medicine);
      emit(state.copyWith(
          status: MedicineActionsStatus.success,
          successMessage: "Medicine Added Successfully"));
    } catch (e) {
      _handleError(e, emit, MedicineActionType.createMedicine);
    }
  }

  Future<void> _onUpdateMedicine(
      UpdateMedicineEvent event, Emitter<MedicineActionsState> emit) async {
    try {
      emit(state.copyWith(
          status: MedicineActionsStatus.loading,
          actionType: MedicineActionType.updateMedicine));
      await medicineRepo.updateMedicine(
          id: event.id, commercialName: event.medicine);
      emit(state.copyWith(
          status: MedicineActionsStatus.success,
          successMessage: "Medicine Updated Successfully"));
    } catch (e) {
      _handleError(e, emit, MedicineActionType.updateMedicine);
    }
  }

  Future<void> _onDeleteMedicine(
      DeleteMedicineEvent event, Emitter<MedicineActionsState> emit) async {
    try {
      emit(state.copyWith(
          status: MedicineActionsStatus.loading,
          actionType: MedicineActionType.deleteMedicine));
      await medicineRepo.deleteMedicine(id: event.id);
      emit(state.copyWith(
          status: MedicineActionsStatus.success,
          successMessage: "Medicine Deleted Successfully"));
    } catch (e) {
      _handleError(e, emit, MedicineActionType.deleteMedicine);
    }
  }

  Future<void> _onCreateActiveIngredient(CreateActiveIngredientEvent event,
      Emitter<MedicineActionsState> emit) async {
    try {
      emit(state.copyWith(
          status: MedicineActionsStatus.loading,
          actionType: MedicineActionType.createActiveIngredient));
      await medicineRepo.createActiveIngredient(
          activeIngredient: event.activeIngredient);
      emit(state.copyWith(
          status: MedicineActionsStatus.success,
          successMessage: "Active Ingredient Added Successfully"));
    } catch (e) {
      _handleError(e, emit, MedicineActionType.createActiveIngredient);
    }
  }

  Future<void> _onUpdateActiveIngredient(UpdateActiveIngredientEvent event,
      Emitter<MedicineActionsState> emit) async {
    try {
      emit(state.copyWith(
          status: MedicineActionsStatus.loading,
          actionType: MedicineActionType.updateActiveIngredient));
      await medicineRepo.updateActiveIngredient(
          id: event.id, activeIngredient: event.activeIngredient);
      emit(state.copyWith(
          status: MedicineActionsStatus.success,
          successMessage: "Active Ingredient Updated Successfully"));
    } catch (e) {
      _handleError(e, emit, MedicineActionType.updateActiveIngredient);
    }
  }

  Future<void> _onDeleteActiveIngredient(DeleteActiveIngredientEvent event,
      Emitter<MedicineActionsState> emit) async {
    try {
      emit(state.copyWith(
          status: MedicineActionsStatus.loading,
          actionType: MedicineActionType.deleteActiveIngredient));
      await medicineRepo.deleteActiveIngredient(id: event.id);
      emit(state.copyWith(
          status: MedicineActionsStatus.success,
          successMessage: "Active Ingredient Deleted Successfully"));
    } catch (e) {
      _handleError(e, emit, MedicineActionType.deleteActiveIngredient);
    }
  }

  Future<void> _onResetActions(ResetMedicineActionsEvent event,
      Emitter<MedicineActionsState> emit) async {
    emit(const MedicineActionsState());
  }

  void _handleError(
      Object e, Emitter<MedicineActionsState> emit, MedicineActionType type) {
    if (e.toString().toLowerCase().contains('no internet connection')) {
      emit(state.copyWith(
        status: MedicineActionsStatus.noConnection,
        actionType: type,
        errorMessage: e.toString(),
      ));
      return;
    }
    if (e.toString().toLowerCase().contains('request cancelled')) {
      return;
    }
    emit(state.copyWith(
      status: MedicineActionsStatus.error,
      actionType: type,
      errorMessage: e.toString(),
    ));
  }

  // Backward compatibility helpers
  void createMedicine(CommercialName medicine) =>
      add(CreateMedicineEvent(medicine));
  void updateMedicine(String id, CommercialName medicine) =>
      add(UpdateMedicineEvent(id, medicine));
  void deleteMedicine(String id) => add(DeleteMedicineEvent(id));
  void createActiveIngredient(ActiveIngredient activeIngredient) =>
      add(CreateActiveIngredientEvent(activeIngredient));
  void updateActiveIngredient(String id, ActiveIngredient activeIngredient) =>
      add(UpdateActiveIngredientEvent(id, activeIngredient));
  void deleteActiveIngredient(String id) =>
      add(DeleteActiveIngredientEvent(id));
}
