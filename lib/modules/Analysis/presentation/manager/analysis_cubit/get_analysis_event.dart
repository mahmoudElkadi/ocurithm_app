part of 'get_analysis_cubit.dart';

@immutable
abstract class GetAnalysisEvent {}

class GetPatientAnalysisEvent extends GetAnalysisEvent {
  final String? patientId;

  GetPatientAnalysisEvent({this.patientId});
}


