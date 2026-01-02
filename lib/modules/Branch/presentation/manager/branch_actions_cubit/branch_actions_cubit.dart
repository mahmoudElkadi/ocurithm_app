import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ocurithm/modules/Branch/data/model/add_branch_model.dart';
import 'package:ocurithm/modules/Branch/data/repos/branch_repo.dart';

part 'branch_actions_state.dart';
part 'branch_actions_event.dart';

class BranchActionsCubit extends Bloc<BranchActionsEvent, BranchActionsState> {
  final BranchRepo branchRepo;

  BranchActionsCubit(this.branchRepo) : super(BranchActionsState()) {
    on<AddBranchEvent>(_onAddBranch);
    on<UpdateBranchEvent>(_onUpdateBranch);
    on<DeleteBranchEvent>(_onDeleteBranch);
    on<ResetBranchActionsEvent>(_onResetBranchActions);
  }

  static BranchActionsCubit get(BuildContext context) =>
      BlocProvider.of(context);

  // Add Branch
  Future<void> _onAddBranch(
      AddBranchEvent event, Emitter<BranchActionsState> emit) async {
    try {
      emit(state.copyWith(
        state: BranchActionsStatus.loading,
        actionType: BranchActionType.add,
      ));

      final result =
          await branchRepo.createBranch(addBranchModel: event.addBranchModel);

      if (result.error == null && (result.name != null || result.id != null)) {
        emit(state.copyWith(
          state: BranchActionsStatus.success,
          actionType: BranchActionType.add,
          successMessage: 'Branch Added Successfully',
          branch: result,
        ));
      } else {
        emit(state.copyWith(
          state: BranchActionsStatus.error,
          actionType: BranchActionType.add,
          errorMessage: result.error ?? 'Failed to add branch',
        ));
      }
    } catch (e) {
      if (e.toString().toLowerCase().contains('no internet connection')) {
        emit(state.copyWith(
          state: BranchActionsStatus.noConnection,
          actionType: BranchActionType.add,
          errorMessage: e.toString(),
        ));
        return;
      }
      if (e.toString().toLowerCase().contains('request cancelled')) {
        return;
      }
      emit(state.copyWith(
        state: BranchActionsStatus.error,
        actionType: BranchActionType.add,
        errorMessage: e.toString(),
      ));
    }
  }

  // Update Branch
  Future<void> _onUpdateBranch(
      UpdateBranchEvent event, Emitter<BranchActionsState> emit) async {
    try {
      emit(state.copyWith(
        state: BranchActionsStatus.loading,
        actionType: BranchActionType.update,
      ));

      final result = await branchRepo.updateBranch(
        id: event.branchId,
        addBranchModel: event.addBranchModel,
      );

      if (result.error == null && (result.name != null || result.id != null)) {
        emit(state.copyWith(
          state: BranchActionsStatus.success,
          actionType: BranchActionType.update,
          successMessage: 'Branch Updated Successfully',
          branch: result,
        ));
      } else {
        emit(state.copyWith(
          state: BranchActionsStatus.error,
          actionType: BranchActionType.update,
          errorMessage: result.error ?? 'Failed to update branch',
        ));
      }
    } catch (e) {
      if (e.toString().toLowerCase().contains('no internet connection')) {
        emit(state.copyWith(
          state: BranchActionsStatus.noConnection,
          actionType: BranchActionType.update,
          errorMessage: e.toString(),
        ));
        return;
      }
      if (e.toString().toLowerCase().contains('request cancelled')) {
        return;
      }
      emit(state.copyWith(
        state: BranchActionsStatus.error,
        actionType: BranchActionType.update,
        errorMessage: e.toString(),
      ));
    }
  }

  // Delete Branch
  Future<void> _onDeleteBranch(
      DeleteBranchEvent event, Emitter<BranchActionsState> emit) async {
    try {
      emit(state.copyWith(
        state: BranchActionsStatus.loading,
        actionType: BranchActionType.delete,
      ));

      final result = await branchRepo.deleteBranch(id: event.branchId);

      if (result.error == null && result.message != null) {
        emit(state.copyWith(
          state: BranchActionsStatus.success,
          actionType: BranchActionType.delete,
          successMessage: result.message,
        ));
      } else {
        emit(state.copyWith(
          state: BranchActionsStatus.error,
          actionType: BranchActionType.delete,
          errorMessage: result.error ?? 'Failed to delete branch',
        ));
      }
    } catch (e) {
      if (e.toString().toLowerCase().contains('no internet connection')) {
        emit(state.copyWith(
          state: BranchActionsStatus.noConnection,
          actionType: BranchActionType.delete,
          errorMessage: e.toString(),
        ));
        return;
      }
      if (e.toString().toLowerCase().contains('request cancelled')) {
        return;
      }
      emit(state.copyWith(
        state: BranchActionsStatus.error,
        actionType: BranchActionType.delete,
        errorMessage: e.toString(),
      ));
    }
  }

  // Reset Branch Actions
  Future<void> _onResetBranchActions(
      ResetBranchActionsEvent event, Emitter<BranchActionsState> emit) async {
    emit(BranchActionsState());
  }
}
