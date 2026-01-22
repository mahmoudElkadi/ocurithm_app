import '../../../Branch/data/model/data.dart';
import '../model/active_ingredient_model.dart';
import '../model/medicine_model.dart';

abstract class MedicineRepo {
  // Medicine
  Future<MedicinesModel> getAllMedicines({int? page, String? search});
  Future<CommercialName> createMedicine(
      {required CommercialName commercialName});
  Future<CommercialName> getMedicine({required String id});
  Future<CommercialName> updateMedicine(
      {required String id, required CommercialName commercialName});
  Future<DataModel> deleteMedicine({required String id});

  // Active Ingredient
  Future<ActiveIngredientModel> getAllActiveIngredients(
      {int? page, String? search, bool? pagination, String? clinic});
  Future<ActiveIngredient> createActiveIngredient(
      {required ActiveIngredient activeIngredient});
  Future<ActiveIngredient> updateActiveIngredient(
      {required String id, required ActiveIngredient activeIngredient});
  Future<DataModel> deleteActiveIngredient({required String id});
}
