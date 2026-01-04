import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';

import '../../../data/model/examination_type_model.dart';
import '../../../data/repos/examination_type_repo.dart';

part 'examination_type_actions_event.dart';
part 'examination_type_actions_state.dart';

/// Cubit for examination type actions (add, update, delete)
class ExaminationTypeActionsCubit
    extends Bloc<ExaminationTypeActionsEvent, ExaminationTypeActionsState> {
  final ExaminationTypeRepo examinationTypeRepo;

  ExaminationTypeActionsCubit(this.examinationTypeRepo)
      : super(const ExaminationTypeActionsState()) {
    on<AddExaminationTypeEvent>(_onAddExaminationType);
    on<UpdateExaminationTypeEvent>(_onUpdateExaminationType);
    on<DeleteExaminationTypeEvent>(_onDeleteExaminationType);
    on<ResetExaminationTypeActionsEvent>(_onResetActions);
  }

  /// Add a new examination type
  Future<void> _onAddExaminationType(
    AddExaminationTypeEvent event,
    Emitter<ExaminationTypeActionsState> emit,
  ) async {
    emit(state.copyWith(
      status: ExaminationTypeActionStatus.loading,
      actionType: ExaminationTypeActionType.add,
    ));

    try {
      // Check internet connection
      final hasConnection = await InternetConnection().hasInternetAccess;
      if (!hasConnection) {
        emit(state.copyWith(
          status: ExaminationTypeActionStatus.noConnection,
          errorMessage: 'No internet connection',
        ));
        return;
      }

      // Create examination type
      final result = await examinationTypeRepo.createExaminationType(
        examinationType: event.examinationType,
      );

      if (result.error == null && (result.name != null || result.id != null)) {
        emit(state.copyWith(
          status: ExaminationTypeActionStatus.success,
          successMessage: 'Examination type added successfully',
        ));
      } else {
        emit(state.copyWith(
          status: ExaminationTypeActionStatus.error,
          errorMessage: result.error ?? 'Failed to add examination type',
        ));
      }
    } catch (e) {
      emit(state.copyWith(
        status: ExaminationTypeActionStatus.error,
        errorMessage: 'An error occurred: ${e.toString()}',
      ));
    }
  }

  /// Update an existing examination type
  Future<void> _onUpdateExaminationType(
    UpdateExaminationTypeEvent event,
    Emitter<ExaminationTypeActionsState> emit,
  ) async {
    emit(state.copyWith(
      status: ExaminationTypeActionStatus.loading,
      actionType: ExaminationTypeActionType.update,
    ));

    try {
      // Check internet connection
      final hasConnection = await InternetConnection().hasInternetAccess;
      if (!hasConnection) {
        emit(state.copyWith(
          status: ExaminationTypeActionStatus.noConnection,
          errorMessage: 'No internet connection',
        ));
        return;
      }

      // Update examination type
      final result = await examinationTypeRepo.updateExaminationType(
        id: event.examinationTypeId,
        examinationType: event.examinationType,
      );

      if (result.error == null && (result.name != null || result.id != null)) {
        emit(state.copyWith(
          status: ExaminationTypeActionStatus.success,
          successMessage: 'Examination type updated successfully',
        ));
      } else {
        emit(state.copyWith(
          status: ExaminationTypeActionStatus.error,
          errorMessage: result.error ?? 'Failed to update examination type',
        ));
      }
    } catch (e) {
      emit(state.copyWith(
        status: ExaminationTypeActionStatus.error,
        errorMessage: 'An error occurred: ${e.toString()}',
      ));
    }
  }

  /// Delete an examination type
  Future<void> _onDeleteExaminationType(
    DeleteExaminationTypeEvent event,
    Emitter<ExaminationTypeActionsState> emit,
  ) async {
    emit(state.copyWith(
      status: ExaminationTypeActionStatus.loading,
      actionType: ExaminationTypeActionType.delete,
    ));

    try {
      // Check internet connection
      final hasConnection = await InternetConnection().hasInternetAccess;
      if (!hasConnection) {
        emit(state.copyWith(
          status: ExaminationTypeActionStatus.noConnection,
          errorMessage: 'No internet connection',
        ));
        return;
      }

      // Delete examination type
      final result = await examinationTypeRepo.deleteExaminationType(
        id: event.examinationTypeId,
      );

      if (result.error == null && result.message != null) {
        emit(state.copyWith(
          status: ExaminationTypeActionStatus.success,
          successMessage: result.message,
        ));
      } else {
        emit(state.copyWith(
          status: ExaminationTypeActionStatus.error,
          errorMessage: result.error ?? 'Failed to delete examination type',
        ));
      }
    } catch (e) {
      emit(state.copyWith(
        status: ExaminationTypeActionStatus.error,
        errorMessage: 'An error occurred: ${e.toString()}',
      ));
    }
  }

  /// Reset actions state
  void _onResetActions(
    ResetExaminationTypeActionsEvent event,
    Emitter<ExaminationTypeActionsState> emit,
  ) {
    emit(const ExaminationTypeActionsState());
  }
}
