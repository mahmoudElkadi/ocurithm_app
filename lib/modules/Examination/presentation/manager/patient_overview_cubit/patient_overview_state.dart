part of 'patient_overview_cubit.dart';

abstract class PatientOverviewState {}

class PatientOverviewInitial extends PatientOverviewState {}

class PatientOverviewLoading extends PatientOverviewState {}

class PatientOverviewSuccess extends PatientOverviewState {
  final PatientOverviewModel overview;
  PatientOverviewSuccess(this.overview);
}

class PatientOverviewError extends PatientOverviewState {
  final String error;
  PatientOverviewError(this.error);
}
