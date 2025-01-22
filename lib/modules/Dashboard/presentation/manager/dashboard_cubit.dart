import 'dart:developer';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';
import 'package:ocurithm/modules/Dashboard/data/models/dashboard_model.dart';
import 'package:ocurithm/modules/Dashboard/data/repos/dashboard_repo.dart';

import 'dashboard_state.dart';

class DashboardCubit extends Cubit<DashboardState> {
  DashboardCubit(this.dashboardRepo) : super(DashboardInitial());

  static DashboardCubit get(context) => BlocProvider.of(context);

  DashboardRepo dashboardRepo;

  bool? connection;
  bool isDateRangeSelected = false;
  DashboardModel? dashboard;
  Future<void> getDashboard({
    DateTime? start,
    DateTime? end,
  }) async {
    dashboard = null;
    emit(DashboardLoading());

    connection = await InternetConnection().hasInternetAccess;
    emit(DashboardLoading());
    try {
      if (connection == false) {
        emit(DashboardError());
      } else {
        dashboard = await dashboardRepo.getDashboard(start: start, end: end);
        isDateRangeSelected = start != null && end != null;
        if (dashboard?.error == null && dashboard != null) {
          emit(DashboardSuccess());
        } else {
          emit(DashboardError());
        }
      }
    } catch (e) {
      log(e.toString());
      emit(DashboardError());
    }
  }
}
