import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ocurithm/modules/Patient/data/repos/patient_repo.dart';

part 'scan_actions_state.dart';
part 'scan_actions_event.dart';

class ScanActionsCubit extends Bloc<ScanActionsEvent, ScanActionsState> {
  final PatientRepo patientRepo;

  ScanActionsCubit(this.patientRepo) : super(const ScanActionsState()) {
    on<CreateScanRecordEvent>(_onCreateScanRecord);
    on<DeleteScanEvent>(_onDeleteScan);
    on<EditScanFileEvent>(_onEditScanFile);
    on<RestoreScanFileEvent>(_onRestoreScanFile);
  }

  Future<void> _onCreateScanRecord(
      CreateScanRecordEvent event, Emitter<ScanActionsState> emit) async {
    try {
      emit(state.copyWith(state: ScanActionsStatus.loading));

      await patientRepo.createScanRecord(
        patientId: event.patientId,
        doctorId: event.doctorId,
        comment: event.comment,
        scanDate: event.scanDate,
        files: event.files,
        eye: event.eye,
        investigations: event.investigations,
      );

      emit(state.copyWith(
        state: ScanActionsStatus.success,
        successMessage: 'Scan record created successfully',
      ));
    } catch (e) {
      if (e.toString().toLowerCase().contains('no internet connection')) {
        emit(state.copyWith(
          state: ScanActionsStatus.noConnection,
          errorMessage: e.toString(),
        ));
        return;
      }
      emit(state.copyWith(
        state: ScanActionsStatus.error,
        errorMessage: e.toString(),
      ));
    }
  }

  Future<void> _onDeleteScan(
      DeleteScanEvent event, Emitter<ScanActionsState> emit) async {
    try {
      emit(state.copyWith(state: ScanActionsStatus.loading));

      await patientRepo.deleteScan(
        patientId: event.patientId,
        scanId: event.scanId,
      );

      emit(state.copyWith(
        state: ScanActionsStatus.success,
        successMessage: 'Scan record deleted successfully',
      ));
    } catch (e) {
      if (e.toString().toLowerCase().contains('no internet connection')) {
        emit(state.copyWith(
          state: ScanActionsStatus.noConnection,
          errorMessage: e.toString(),
        ));
        return;
      }
      emit(state.copyWith(
        state: ScanActionsStatus.error,
        errorMessage: e.toString(),
      ));
    }
  }

  Future<void> _onEditScanFile(
      EditScanFileEvent event, Emitter<ScanActionsState> emit) async {
    try {
      emit(state.copyWith(state: ScanActionsStatus.loading));

      await patientRepo.editScanFile(
        patientId: event.patientId,
        scanId: event.scanId,
        fileId: event.fileId,
        newKey: event.newKey,
      );

      emit(state.copyWith(
        state: ScanActionsStatus.success,
        successMessage: 'File updated successfully',
      ));
    } catch (e) {
      if (e.toString().toLowerCase().contains('no internet connection')) {
        emit(state.copyWith(
          state: ScanActionsStatus.noConnection,
          errorMessage: e.toString(),
        ));
        return;
      }
      emit(state.copyWith(
        state: ScanActionsStatus.error,
        errorMessage: e.toString(),
      ));
    }
  }

  Future<void> _onRestoreScanFile(
      RestoreScanFileEvent event, Emitter<ScanActionsState> emit) async {
    try {
      emit(state.copyWith(state: ScanActionsStatus.loading));

      await patientRepo.restoreScanFile(
        patientId: event.patientId,
        scanId: event.scanId,
        fileId: event.fileId,
      );

      emit(state.copyWith(
        state: ScanActionsStatus.success,
        successMessage: 'File restored successfully',
      ));
    } catch (e) {
      if (e.toString().toLowerCase().contains('no internet connection')) {
        emit(state.copyWith(
          state: ScanActionsStatus.noConnection,
          errorMessage: e.toString(),
        ));
        return;
      }
      emit(state.copyWith(
        state: ScanActionsStatus.error,
        errorMessage: e.toString(),
      ));
    }
  }
}
