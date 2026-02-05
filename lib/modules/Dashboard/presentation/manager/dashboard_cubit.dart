import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ocurithm/modules/Dashboard/data/models/dashboard_model.dart';
import 'package:ocurithm/modules/Dashboard/data/repos/dashboard_repo.dart';

part 'dashboard_state.dart';
part 'dashboard_event.dart';

class DashboardCubit extends Bloc<DashboardEvent, DashboardState> {
  final DashboardRepo dashboardRepo;

  DashboardCubit(this.dashboardRepo) : super(const DashboardState()) {
    on<GetDashboardEvent>(_onGetDashboard);
  }

  static DashboardCubit get(BuildContext context) => BlocProvider.of(context);

  Future<void> _onGetDashboard(
      GetDashboardEvent event, Emitter<DashboardState> emit) async {
    emit(state.copyWith(
      status: DashboardStatus.loading,
      startDate: event.start ?? state.startDate,
      endDate: event.end ?? state.endDate,
    ));

    try {
      final data = await dashboardRepo.getDashboard(
        start: event.start ?? state.startDate,
        end: event.end ?? state.endDate,
      );
      emit(state.copyWith(
        status: DashboardStatus.success,
        dashboardData: data,
      ));
    } catch (e) {
      if (e.toString().toLowerCase().contains('no internet connection')) {
         emit(state.copyWith(
          status: DashboardStatus.noConnection,
          errorMessage: e.toString(),
        ));
      } else {
        emit(state.copyWith(
          status: DashboardStatus.error,
          errorMessage: e.toString(),
        ));
      }
    }
  }
}
