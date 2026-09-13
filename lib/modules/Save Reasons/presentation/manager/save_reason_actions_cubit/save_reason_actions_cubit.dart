import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../data/model/save_reason_model.dart';
import '../../../data/repos/save_reason_repo.dart';

part 'save_reason_actions_event.dart';
part 'save_reason_actions_state.dart';

/// Add, update and delete for the save-reason catalog.
class SaveReasonActionsCubit
    extends Bloc<SaveReasonActionsEvent, SaveReasonActionsState> {
  final SaveReasonRepo saveReasonRepo;

  SaveReasonActionsCubit(this.saveReasonRepo)
      : super(const SaveReasonActionsState()) {
    on<AddSaveReasonEvent>(_onAddSaveReason);
    on<UpdateSaveReasonEvent>(_onUpdateSaveReason);
    on<DeleteSaveReasonEvent>(_onDeleteSaveReason);
    on<ResetSaveReasonActionsEvent>(_onResetActions);
  }

  SaveReasonActionsState _failure(Object error, SaveReasonActionType type) {
    final isOffline =
        error.toString().toLowerCase().contains('no internet connection');

    return state.copyWith(
      status: isOffline
          ? SaveReasonActionStatus.noConnection
          : SaveReasonActionStatus.error,
      actionType: type,
      errorMessage: error.toString(),
    );
  }

  Future<void> _onAddSaveReason(
    AddSaveReasonEvent event,
    Emitter<SaveReasonActionsState> emit,
  ) async {
    emit(state.copyWith(
      status: SaveReasonActionStatus.loading,
      actionType: SaveReasonActionType.add,
    ));

    try {
      await saveReasonRepo.createSaveReason(saveReason: event.saveReason);
      emit(state.copyWith(
        status: SaveReasonActionStatus.success,
        successMessage: 'Save reason added successfully',
      ));
    } catch (e) {
      emit(_failure(e, SaveReasonActionType.add));
    }
  }

  Future<void> _onUpdateSaveReason(
    UpdateSaveReasonEvent event,
    Emitter<SaveReasonActionsState> emit,
  ) async {
    emit(state.copyWith(
      status: SaveReasonActionStatus.loading,
      actionType: SaveReasonActionType.update,
    ));

    try {
      await saveReasonRepo.updateSaveReason(
        id: event.saveReasonId,
        saveReason: event.saveReason,
      );
      emit(state.copyWith(
        status: SaveReasonActionStatus.success,
        successMessage: 'Save reason updated successfully',
      ));
    } catch (e) {
      emit(_failure(e, SaveReasonActionType.update));
    }
  }

  Future<void> _onDeleteSaveReason(
    DeleteSaveReasonEvent event,
    Emitter<SaveReasonActionsState> emit,
  ) async {
    emit(state.copyWith(
      status: SaveReasonActionStatus.loading,
      actionType: SaveReasonActionType.delete,
    ));

    try {
      await saveReasonRepo.deleteSaveReason(id: event.saveReasonId);
      emit(state.copyWith(
        status: SaveReasonActionStatus.success,
        successMessage: 'Save reason deleted successfully',
      ));
    } catch (e) {
      emit(_failure(e, SaveReasonActionType.delete));
    }
  }

  void _onResetActions(
    ResetSaveReasonActionsEvent event,
    Emitter<SaveReasonActionsState> emit,
  ) {
    emit(const SaveReasonActionsState());
  }
}
