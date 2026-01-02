import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ocurithm/modules/Branch/data/model/add_branch_model.dart';
import 'package:ocurithm/modules/Branch/data/repos/branch_repo.dart';

part 'get_single_branch_state.dart';
part 'get_single_branch_event.dart';

class GetSingleBranchCubit
    extends Bloc<GetSingleBranchEvent, GetSingleBranchState> {
  final BranchRepo branchRepo;

  GetSingleBranchCubit(this.branchRepo) : super(GetSingleBranchState()) {
    on<GetBranchByIdEvent>(_onGetBranchById);
    on<ResetSingleBranchEvent>(_onResetSingleBranch);
  }

  static GetSingleBranchCubit get(BuildContext context) =>
      BlocProvider.of(context);

  // Get Branch by ID
  Future<void> _onGetBranchById(
      GetBranchByIdEvent event, Emitter<GetSingleBranchState> emit) async {
    try {
      emit(state.copyWith(state: GetSingleBranchStatus.loading));

      final branch = await branchRepo.getBranch(id: event.branchId);

      if (branch.error == null) {
        emit(state.copyWith(
            state: GetSingleBranchStatus.success, branch: branch));
      } else {
        emit(state.copyWith(
          state: GetSingleBranchStatus.error,
          errorMessage: branch.error ?? 'Failed to load branch',
        ));
      }
    } catch (e) {
      if (e.toString().toLowerCase().contains('no internet connection')) {
        emit(state.copyWith(
            state: GetSingleBranchStatus.noConnection,
            errorMessage: e.toString()));
        return;
      }
      if (e.toString().toLowerCase().contains('request cancelled')) {
        return;
      }
      emit(state.copyWith(
          state: GetSingleBranchStatus.error, errorMessage: e.toString()));
    }
  }

  // Reset Single Branch
  Future<void> _onResetSingleBranch(
      ResetSingleBranchEvent event, Emitter<GetSingleBranchState> emit) async {
    emit(GetSingleBranchState());
  }
}
