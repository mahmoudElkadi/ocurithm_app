import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../data/model/examination_type_model.dart';
import '../../../data/repos/examination_type_repo.dart';

part 'get_single_examination_type_event.dart';
part 'get_single_examination_type_state.dart';

/// Cubit for fetching a single examination type by ID
class GetSingleExaminationTypeCubit
    extends Bloc<GetSingleExaminationTypeEvent, GetSingleExaminationTypeState> {
  final ExaminationTypeRepo examinationTypeRepo;

  GetSingleExaminationTypeCubit(this.examinationTypeRepo)
      : super(const GetSingleExaminationTypeState()) {
    on<GetExaminationTypeByIdEvent>(_onGetExaminationTypeById);
    on<ResetSingleExaminationTypeEvent>(_onResetSingleExaminationType);
  }

  /// Fetch a single examination type by ID
  Future<void> _onGetExaminationTypeById(
    GetExaminationTypeByIdEvent event,
    Emitter<GetSingleExaminationTypeState> emit,
  ) async {
    emit(state.copyWith(
      status: SingleExaminationTypeStatus.loading,
      errorMessage: null,
    ));

    try {
      // Fetch examination type
      final result = await examinationTypeRepo.getExaminationType(
        id: event.examinationTypeId,
      );

      if (result.error == null) {
        emit(state.copyWith(
          status: SingleExaminationTypeStatus.success,
          examinationType: result,
        ));
      } else {
        emit(state.copyWith(
          status: SingleExaminationTypeStatus.error,
          errorMessage: result.error ?? 'Failed to load examination type',
        ));
      }
    } catch (e) {
      if (e.toString().toLowerCase().contains('no internet connection')) {
        emit(state.copyWith(
          status: SingleExaminationTypeStatus.noConnection,
          errorMessage: e.toString(),
        ));
        return;
      }
      if (e.toString().toLowerCase().contains('request cancelled')) {
        return;
      }
      emit(state.copyWith(
        status: SingleExaminationTypeStatus.error,
        errorMessage: e.toString(),
      ));
    }
  }

  /// Reset the state
  void _onResetSingleExaminationType(
    ResetSingleExaminationTypeEvent event,
    Emitter<GetSingleExaminationTypeState> emit,
  ) {
    emit(const GetSingleExaminationTypeState());
  }
}
