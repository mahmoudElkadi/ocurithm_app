part of 'get_active_ingredients_cubit.dart';

abstract class GetActiveIngredientsState {}

class GetActiveIngredientsInitial extends GetActiveIngredientsState {}

class GetActiveIngredientsLoading extends GetActiveIngredientsState {}

class GetActiveIngredientsLoaded extends GetActiveIngredientsState {
  final List<ActiveIngredient> activeIngredients;
  GetActiveIngredientsLoaded({required this.activeIngredients});
}

class GetActiveIngredientsError extends GetActiveIngredientsState {
  final String error;
  GetActiveIngredientsError({required this.error});
}
