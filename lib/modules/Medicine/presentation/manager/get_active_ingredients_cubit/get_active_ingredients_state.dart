part of 'get_active_ingredients_cubit.dart';

enum GetActiveIngredientsStatus {
  initial,
  loading,
  success,
  error,
  noConnection
}

class GetActiveIngredientsState {
  final GetActiveIngredientsStatus status;
  final List<ActiveIngredient> activeIngredients;
  final String? errorMessage;
  final String? search;
  final String? clinic;
  final int page;
  final int totalPages;

  const GetActiveIngredientsState({
    this.status = GetActiveIngredientsStatus.initial,
    this.activeIngredients = const [],
    this.errorMessage,
    this.search,
    this.clinic,
    this.page = 1,
    this.totalPages = 1,
  });

  GetActiveIngredientsState copyWith({
    GetActiveIngredientsStatus? status,
    List<ActiveIngredient>? activeIngredients,
    String? errorMessage,
    String? search,
    String? clinic,
    int? page,
    int? totalPages,
  }) {
    return GetActiveIngredientsState(
      status: status ?? this.status,
      activeIngredients: activeIngredients ?? this.activeIngredients,
      errorMessage: errorMessage ?? this.errorMessage,
      search: search ?? this.search,
      clinic: clinic ?? this.clinic,
      page: page ?? this.page,
      totalPages: totalPages ?? this.totalPages,
    );
  }
}
