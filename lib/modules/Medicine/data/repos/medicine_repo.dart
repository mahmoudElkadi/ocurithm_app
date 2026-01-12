import '../../../Branch/data/model/data.dart';
import '../model/active_ingredient_model.dart';
import '../model/medicine_model.dart';

abstract class MedicineRepo {
  // Medicine
  Future<MedicinesModel> getAllMedicines({int? page, String? search});
  Future<Medicine> createMedicine({required Medicine medicine});
  Future<Medicine> getMedicine({required String id});
  Future<Medicine> updateMedicine(
      {required String id, required Medicine medicine});
  Future<DataModel> deleteMedicine({required String id});

  // Active Ingredient
  Future<ActiveIngredientsModel> getAllActiveIngredients(
      {int? page, String? search});
  Future<ActiveIngredient> createActiveIngredient(
      {required ActiveIngredient activeIngredient});
  Future<ActiveIngredient> updateActiveIngredient(
      {required String id, required ActiveIngredient activeIngredient});
  Future<DataModel> deleteActiveIngredient({required String id});
}
