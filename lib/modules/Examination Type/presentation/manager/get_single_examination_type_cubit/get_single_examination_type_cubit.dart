import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';

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
      // Check internet connection
      final hasConnection = await InternetConnection().hasInternetAccess;
      if (!hasConnection) {
        emit(state.copyWith(
          status: SingleExaminationTypeStatus.noConnection,
          errorMessage: 'No internet connection',
        ));
        return;
      }

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
      emit(state.copyWith(
        status: SingleExaminationTypeStatus.error,
        errorMessage: 'An error occurred: ${e.toString()}',
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
