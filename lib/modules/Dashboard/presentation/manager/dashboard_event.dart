part of 'dashboard_cubit.dart';

@immutable
abstract class DashboardEvent {}

class GetDashboardEvent extends DashboardEvent {
  final DateTime? start;
  final DateTime? end;

  GetDashboardEvent({this.start, this.end});
}
