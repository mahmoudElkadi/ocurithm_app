import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ocurithm/modules/Receptionist/data/models/add_reception_model.dart';
import 'package:ocurithm/modules/Receptionist/data/repos/receptionist_repo.dart';

import '../../../data/models/receptionists_model.dart';

part 'receptionist_actions_state.dart';
part 'receptionist_actions_event.dart';

/// Cubit for handling receptionist actions (add, update, delete)
/// Follows the clean architecture pattern used in Branch and Clinic modules
class ReceptionistActionsCubit
    extends Bloc<ReceptionistActionsEvent, ReceptionistActionsState> {
  final ReceptionistRepo receptionistRepo;

  ReceptionistActionsCubit(this.receptionistRepo)
      : super(const ReceptionistActionsState()) {
    on<AddReceptionistEvent>(_onAddReceptionist);
    on<UpdateReceptionistEvent>(_onUpdateReceptionist);
    on<DeleteReceptionistEvent>(_onDeleteReceptionist);
    on<ResetReceptionistActionsEvent>(_onResetReceptionistActions);
  }

  static ReceptionistActionsCubit get(BuildContext context) =>
      BlocProvider.of(context);

  // Add Receptionist
  Future<void> _onAddReceptionist(AddReceptionistEvent event,
      Emitter<ReceptionistActionsState> emit) async {
    try {
      emit(state.copyWith(
        state: ReceptionistActionsStatus.loading,
        actionType: ReceptionistActionType.add,
      ));

      final result = await receptionistRepo.createReceptionist(
          receptionist: event.receptionist);

      if (result.error == null && (result.name != null || result.id != null)) {
        emit(state.copyWith(
          state: ReceptionistActionsStatus.success,
          actionType: ReceptionistActionType.add,
          successMessage: 'Receptionist Added Successfully',
          receptionist: result,
        ));
      } else {
        emit(state.copyWith(
          state: ReceptionistActionsStatus.error,
          actionType: ReceptionistActionType.add,
          errorMessage: result.error ?? 'Failed to add receptionist',
        ));
      }
    } catch (e) {
      if (e.toString().toLowerCase().contains('no internet connection')) {
        emit(state.copyWith(
          state: ReceptionistActionsStatus.noConnection,
          actionType: ReceptionistActionType.add,
          errorMessage: e.toString(),
        ));
        return;
      }
      if (e.toString().toLowerCase().contains('request cancelled')) {
        return;
      }
      emit(state.copyWith(
        state: ReceptionistActionsStatus.error,
        actionType: ReceptionistActionType.add,
        errorMessage: e.toString(),
      ));
    }
  }

  // Update Receptionist
  Future<void> _onUpdateReceptionist(UpdateReceptionistEvent event,
      Emitter<ReceptionistActionsState> emit) async {
    try {
      emit(state.copyWith(
        state: ReceptionistActionsStatus.loading,
        actionType: ReceptionistActionType.update,
      ));

      final result = await receptionistRepo.updateReceptionist(
        id: event.receptionistId,
        receptionist: event.receptionist,
      );

      if (result.error == null && (result.name != null || result.id != null)) {
        // Convert Receptionist to AddReceptionistsModel for consistency
        final updatedReceptionist = AddReceptionistsModel(
          id: result.id,
          name: result.name,
          phone: result.phone,
          branch: result.branch,
          birthDate: result.birthDate,
          image: result.image,
          isActive: result.isActive ?? false,
          capabilities: result.capabilities ?? [],
          createdAt: result.createdAt,
          updatedAt: result.updatedAt,
          error: result.error,
        );

        emit(state.copyWith(
          state: ReceptionistActionsStatus.success,
          actionType: ReceptionistActionType.update,
          successMessage: 'Receptionist Updated Successfully',
          receptionist: updatedReceptionist,
        ));
      } else {
        emit(state.copyWith(
          state: ReceptionistActionsStatus.error,
          actionType: ReceptionistActionType.update,
          errorMessage: result.error ?? 'Failed to update receptionist',
        ));
      }
    } catch (e) {
      if (e.toString().toLowerCase().contains('no internet connection')) {
        emit(state.copyWith(
          state: ReceptionistActionsStatus.noConnection,
          actionType: ReceptionistActionType.update,
          errorMessage: e.toString(),
        ));
        return;
      }
      if (e.toString().toLowerCase().contains('request cancelled')) {
        return;
      }
      emit(state.copyWith(
        state: ReceptionistActionsStatus.error,
        actionType: ReceptionistActionType.update,
        errorMessage: e.toString(),
      ));
    }
  }

  // Delete Receptionist
  Future<void> _onDeleteReceptionist(DeleteReceptionistEvent event,
      Emitter<ReceptionistActionsState> emit) async {
    try {
      emit(state.copyWith(
        state: ReceptionistActionsStatus.loading,
        actionType: ReceptionistActionType.delete,
      ));

      final result =
          await receptionistRepo.deleteReceptionist(id: event.receptionistId);

      if (result.error == null && result.message != null) {
        emit(state.copyWith(
          state: ReceptionistActionsStatus.success,
          actionType: ReceptionistActionType.delete,
          successMessage: result.message,
        ));
      } else {
        emit(state.copyWith(
          state: ReceptionistActionsStatus.error,
          actionType: ReceptionistActionType.delete,
          errorMessage: result.error ?? 'Failed to delete receptionist',
        ));
      }
    } catch (e) {
      if (e.toString().toLowerCase().contains('no internet connection')) {
        emit(state.copyWith(
          state: ReceptionistActionsStatus.noConnection,
          actionType: ReceptionistActionType.delete,
          errorMessage: e.toString(),
        ));
        return;
      }
      if (e.toString().toLowerCase().contains('request cancelled')) {
        return;
      }
      emit(state.copyWith(
        state: ReceptionistActionsStatus.error,
        actionType: ReceptionistActionType.delete,
        errorMessage: e.toString(),
      ));
    }
  }

  // Reset Receptionist Actions
  Future<void> _onResetReceptionistActions(ResetReceptionistActionsEvent event,
      Emitter<ReceptionistActionsState> emit) async {
    emit(const ReceptionistActionsState());
  }
}
