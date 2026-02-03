import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../data/model/active_ingredient_model.dart';
import '../../../data/repos/medicine_repo.dart';

part 'get_active_ingredients_state.dart';
part 'get_active_ingredients_event.dart';

class GetActiveIngredientsCubit
    extends Bloc<GetActiveIngredientsEvent, GetActiveIngredientsState> {
  final MedicineRepo medicineRepo;

  GetActiveIngredientsCubit({required this.medicineRepo})
      : super(const GetActiveIngredientsState()) {
    on<FetchActiveIngredientsEvent>(_onFetchActiveIngredients);
    on<ResetActiveIngredientFilters>(_onResetFilters);
  }

  static GetActiveIngredientsCubit get(BuildContext context) =>
      BlocProvider.of(context);

  Future<void> _onFetchActiveIngredients(FetchActiveIngredientsEvent event,
      Emitter<GetActiveIngredientsState> emit) async {
    try {
      emit(state.copyWith(
        status: GetActiveIngredientsStatus.loading,
        search: event.search,
        clinic: event.clinic,
        page: event.page ?? state.page,
      ));

      final result = await medicineRepo.getAllActiveIngredients(
        page: event.page ?? state.page,
        search: event.search ?? state.search,
        pagination: event.pagination,
        clinic: event.clinic ?? state.clinic,
      );

      emit(state.copyWith(
        status: GetActiveIngredientsStatus.success,
        activeIngredients: result.activeIngredients,
        totalPages: result.totalPages?.toInt() ?? state.totalPages,
      ));
    } catch (e) {
      if (e.toString().toLowerCase().contains('no internet connection')) {
        emit(state.copyWith(
          status: GetActiveIngredientsStatus.noConnection,
          errorMessage: e.toString(),
        ));
        return;
      }
      if (e.toString().toLowerCase().contains('request cancelled')) {
        return;
      }
      emit(state.copyWith(
        status: GetActiveIngredientsStatus.error,
        errorMessage: e.toString(),
      ));
    }
  }

  Future<void> _onResetFilters(ResetActiveIngredientFilters event,
      Emitter<GetActiveIngredientsState> emit) async {
    emit(const GetActiveIngredientsState());
    add(FetchActiveIngredientsEvent());
  }

  // Helper method for backward compatibility
  void getActiveIngredients(
      {String? search, bool? pagination, String? clinic, int? page}) {
    add(FetchActiveIngredientsEvent(
      search: search,
      pagination: pagination,
      clinic: clinic,
      page: page,
    ));
  }
}
