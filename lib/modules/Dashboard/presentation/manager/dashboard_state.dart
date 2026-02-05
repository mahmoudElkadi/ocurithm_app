part of 'dashboard_cubit.dart';

enum DashboardStatus { initial, loading, success, error, noConnection }

extension DashboardStatusX on DashboardState {
  bool get isInitial => status == DashboardStatus.initial;
  bool get isLoading => status == DashboardStatus.loading;
  bool get isSuccess => status == DashboardStatus.success;
  bool get isError => status == DashboardStatus.error;
  bool get isNoConnection => status == DashboardStatus.noConnection;
}

@immutable
class DashboardState {
  final DashboardStatus status;
  final DashboardModel? dashboardData;
  final String? errorMessage;
  final DateTime? startDate;
  final DateTime? endDate;

  const DashboardState({
    this.status = DashboardStatus.initial,
    this.dashboardData,
    this.errorMessage,
    this.startDate,
    this.endDate,
  });

  DashboardState copyWith({
    DashboardStatus? status,
    DashboardModel? dashboardData,
    String? errorMessage,
    DateTime? startDate,
    DateTime? endDate,
  }) {
    return DashboardState(
      status: status ?? this.status,
      dashboardData: dashboardData ?? this.dashboardData,
      errorMessage: errorMessage ?? this.errorMessage,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
    );
  }
}
