import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../data/model/active_ingredient_model.dart';
import '../../../data/repos/medicine_repo.dart';

part 'get_active_ingredients_state.dart';

class GetActiveIngredientsCubit extends Cubit<GetActiveIngredientsState> {
  final MedicineRepo medicineRepo;

  GetActiveIngredientsCubit({required this.medicineRepo})
      : super(GetActiveIngredientsInitial());

  static GetActiveIngredientsCubit get(context) => BlocProvider.of(context);

  List<ActiveIngredient> activeIngredients = [];

  Future<void> getActiveIngredients(
      {String? search, bool? pagination, String? clinic}) async {
    emit(GetActiveIngredientsLoading());
    try {
      final result = await medicineRepo.getAllActiveIngredients(
          page: 1, search: search, pagination: pagination, clinic: clinic);
      activeIngredients = result.activeIngredients;
      emit(GetActiveIngredientsLoaded(activeIngredients: activeIngredients));
    } catch (e) {
      emit(GetActiveIngredientsError(error: e.toString()));
    }
  }
}
