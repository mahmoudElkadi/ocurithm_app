import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ocurithm/modules/Category/data/models/category_model.dart';
import 'package:ocurithm/modules/Category/data/repos/category_repo.dart';

part 'category_actions_state.dart';
part 'category_actions_event.dart';

class CategoryActionsCubit extends Bloc<CategoryActionsEvent, CategoryActionsState> {
  final CategoryRepo categoryRepo;

  CategoryActionsCubit(this.categoryRepo) : super(const CategoryActionsState()) {
    on<AddCategoryEvent>(_onAddCategory);
    on<UpdateCategoryEvent>(_onUpdateCategory);
    on<DeleteCategoryEvent>(_onDeleteCategory);
    on<ResetCategoryActionsEvent>(_onResetCategoryActions);
  }

  static CategoryActionsCubit get(BuildContext context) => BlocProvider.of(context);

  Future<void> _onAddCategory(AddCategoryEvent event, Emitter<CategoryActionsState> emit) async {
    try {
      emit(state.copyWith(
        status: CategoryActionsStatus.loading,
        actionType: CategoryActionType.add,
      ));

      final result = await categoryRepo.createCategory(
        name: event.name,
        clinic: event.clinicId,
        description: event.description,
        image: event.image,
        isActive: event.isActive,
      );

      emit(state.copyWith(
        status: CategoryActionsStatus.success,
        actionType: CategoryActionType.add,
        successMessage: 'Category Created Successfully',
        category: result,
      ));
    } catch (e) {
      if (e.toString().toLowerCase().contains('request cancelled')) return;
      emit(state.copyWith(
        status: CategoryActionsStatus.error,
        actionType: CategoryActionType.add,
        errorMessage: e.toString(),
      ));
    }
  }

  Future<void> _onUpdateCategory(UpdateCategoryEvent event, Emitter<CategoryActionsState> emit) async {
    try {
      emit(state.copyWith(
        status: CategoryActionsStatus.loading,
        actionType: CategoryActionType.update,
      ));

      final result = await categoryRepo.updateCategory(
        event.id,
        name: event.name,
        clinic: event.clinicId,
        description: event.description,
        image: event.image,
        isActive: event.isActive,
      );

      emit(state.copyWith(
        status: CategoryActionsStatus.success,
        actionType: CategoryActionType.update,
        successMessage: 'Category Updated Successfully',
        category: result,
      ));
    } catch (e) {
      if (e.toString().toLowerCase().contains('request cancelled')) return;
      emit(state.copyWith(
        status: CategoryActionsStatus.error,
        actionType: CategoryActionType.update,
        errorMessage: e.toString(),
      ));
    }
  }

  Future<void> _onDeleteCategory(DeleteCategoryEvent event, Emitter<CategoryActionsState> emit) async {
    try {
      emit(state.copyWith(
        status: CategoryActionsStatus.loading,
        actionType: CategoryActionType.delete,
      ));

      await categoryRepo.deleteCategory(event.id);

      emit(state.copyWith(
        status: CategoryActionsStatus.success,
        actionType: CategoryActionType.delete,
        successMessage: 'Category Deleted Successfully',
      ));
    } catch (e) {
      if (e.toString().toLowerCase().contains('request cancelled')) return;
      emit(state.copyWith(
        status: CategoryActionsStatus.error,
        actionType: CategoryActionType.delete,
        errorMessage: e.toString(),
      ));
    }
  }

  void _onResetCategoryActions(ResetCategoryActionsEvent event, Emitter<CategoryActionsState> emit) {
    emit(const CategoryActionsState());
  }
}
