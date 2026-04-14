import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ocurithm/modules/SubCategory/data/models/sub_category_model.dart';
import 'package:ocurithm/modules/SubCategory/data/repos/sub_category_repo.dart';

part 'sub_category_actions_state.dart';
part 'sub_category_actions_event.dart';

class SubCategoryActionsCubit extends Bloc<SubCategoryActionsEvent, SubCategoryActionsState> {
  final SubCategoryRepo subCategoryRepo;

  SubCategoryActionsCubit(this.subCategoryRepo) : super(const SubCategoryActionsState()) {
    on<AddSubCategoryEvent>(_onAddSubCategory);
    on<UpdateSubCategoryEvent>(_onUpdateSubCategory);
    on<DeleteSubCategoryEvent>(_onDeleteSubCategory);
    on<ResetSubCategoryActionsEvent>(_onResetSubCategoryActions);
  }

  static SubCategoryActionsCubit get(BuildContext context) => BlocProvider.of(context);

  Future<void> _onAddSubCategory(AddSubCategoryEvent event, Emitter<SubCategoryActionsState> emit) async {
    try {
      emit(state.copyWith(
        status: SubCategoryActionsStatus.loading,
        actionType: SubCategoryActionType.add,
      ));

      final result = await subCategoryRepo.createSubCategory(
        name: event.name,
        clinicId: event.clinicId,
        categoryId: event.categoryId,
        description: event.description,
        image: event.image,
        isActive: event.isActive,
      );

      emit(state.copyWith(
        status: SubCategoryActionsStatus.success,
        actionType: SubCategoryActionType.add,
        successMessage: 'Sub-Category Created Successfully',
        subCategory: result,
      ));
    } catch (e) {
      if (e.toString().toLowerCase().contains('request cancelled')) return;
      emit(state.copyWith(
        status: SubCategoryActionsStatus.error,
        actionType: SubCategoryActionType.add,
        errorMessage: e.toString(),
      ));
    }
  }

  Future<void> _onUpdateSubCategory(UpdateSubCategoryEvent event, Emitter<SubCategoryActionsState> emit) async {
    try {
      emit(state.copyWith(
        status: SubCategoryActionsStatus.loading,
        actionType: SubCategoryActionType.update,
      ));

      final result = await subCategoryRepo.updateSubCategory(
        event.id,
        name: event.name,
        clinicId: event.clinicId,
        categoryId: event.categoryId,
        description: event.description,
        image: event.image,
        isActive: event.isActive,
      );

      emit(state.copyWith(
        status: SubCategoryActionsStatus.success,
        actionType: SubCategoryActionType.update,
        successMessage: 'Sub-Category Updated Successfully',
        subCategory: result,
      ));
    } catch (e) {
      if (e.toString().toLowerCase().contains('request cancelled')) return;
      emit(state.copyWith(
        status: SubCategoryActionsStatus.error,
        actionType: SubCategoryActionType.update,
        errorMessage: e.toString(),
      ));
    }
  }

  Future<void> _onDeleteSubCategory(DeleteSubCategoryEvent event, Emitter<SubCategoryActionsState> emit) async {
    try {
      emit(state.copyWith(
        status: SubCategoryActionsStatus.loading,
        actionType: SubCategoryActionType.delete,
      ));

      await subCategoryRepo.deleteSubCategory(event.id);

      emit(state.copyWith(
        status: SubCategoryActionsStatus.success,
        actionType: SubCategoryActionType.delete,
        successMessage: 'Sub-Category Deleted Successfully',
      ));
    } catch (e) {
      if (e.toString().toLowerCase().contains('request cancelled')) return;
      emit(state.copyWith(
        status: SubCategoryActionsStatus.error,
        actionType: SubCategoryActionType.delete,
        errorMessage: e.toString(),
      ));
    }
  }

  void _onResetSubCategoryActions(ResetSubCategoryActionsEvent event, Emitter<SubCategoryActionsState> emit) {
    emit(const SubCategoryActionsState());
  }
}
