part of 'get_active_ingredients_cubit.dart';

abstract class GetActiveIngredientsEvent {}

class FetchActiveIngredientsEvent extends GetActiveIngredientsEvent {
  final String? search;
  final bool? pagination;
  final String? clinic;
  final int? page;
  FetchActiveIngredientsEvent(
      {this.search, this.pagination, this.clinic, this.page});
}

class ResetActiveIngredientFilters extends GetActiveIngredientsEvent {}
