import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../data/model/active_ingredient_model.dart';
import '../../../data/model/medicine_model.dart';
import '../../../data/repos/medicine_repo.dart';

part 'medicine_actions_state.dart';

class MedicineActionsCubit extends Cubit<MedicineActionsState> {
  final MedicineRepo medicineRepo;

  MedicineActionsCubit({required this.medicineRepo})
      : super(MedicineActionsInitial());

  static MedicineActionsCubit get(context) => BlocProvider.of(context);

  Future<void> createMedicine(CommercialName commercialName) async {
    emit(MedicineActionsLoading());
    try {
      await medicineRepo.createMedicine(commercialName: commercialName);
      emit(MedicineActionsSuccess(message: "Medicine Added Successfully"));
    } catch (e) {
      emit(MedicineActionsError(error: e.toString()));
    }
  }

  Future<void> updateMedicine(String id, CommercialName commercialName) async {
    emit(MedicineActionsLoading());
    try {
      await medicineRepo.updateMedicine(id: id, commercialName: commercialName);
      emit(MedicineActionsSuccess(message: "Medicine Updated Successfully"));
    } catch (e) {
      emit(MedicineActionsError(error: e.toString()));
    }
  }

  Future<void> deleteMedicine(String id) async {
    emit(MedicineActionsLoading());
    try {
      await medicineRepo.deleteMedicine(id: id);
      emit(MedicineActionsSuccess(message: "Medicine Deleted Successfully"));
    } catch (e) {
      emit(MedicineActionsError(error: e.toString()));
    }
  }

  Future<void> createActiveIngredient(ActiveIngredient activeIngredient) async {
    emit(MedicineActionsLoading());
    try {
      await medicineRepo.createActiveIngredient(
          activeIngredient: activeIngredient);
      emit(MedicineActionsSuccess(
          message: "Active Ingredient Added Successfully"));
    } catch (e) {
      emit(MedicineActionsError(error: e.toString()));
    }
  }

  Future<void> updateActiveIngredient(
      String id, ActiveIngredient activeIngredient) async {
    emit(MedicineActionsLoading());
    try {
      await medicineRepo.updateActiveIngredient(
          id: id, activeIngredient: activeIngredient);
      emit(MedicineActionsSuccess(
          message: "Active Ingredient Updated Successfully"));
    } catch (e) {
      emit(MedicineActionsError(error: e.toString()));
    }
  }

  Future<void> deleteActiveIngredient(String id) async {
    emit(MedicineActionsLoading());
    try {
      await medicineRepo.deleteActiveIngredient(id: id);
      emit(MedicineActionsSuccess(
          message: "Active Ingredient Deleted Successfully"));
    } catch (e) {
      emit(MedicineActionsError(error: e.toString()));
    }
  }
}
