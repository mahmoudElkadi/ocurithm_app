part of 'get_single_patient_cubit.dart';

enum GetSinglePatientStatus { initial, loading, success, error, noConnection }

extension GetSinglePatientStatusX on GetSinglePatientState {
  bool get isInitial => state == GetSinglePatientStatus.initial;
  bool get isLoading => state == GetSinglePatientStatus.loading;
  bool get isSuccess => state == GetSinglePatientStatus.success;
  bool get isError => state == GetSinglePatientStatus.error;
}

@immutable
class GetSinglePatientState {
  final GetSinglePatientStatus state;
  final String? errorMessage;
  final Patient? patient;

  const GetSinglePatientState({
    this.state = GetSinglePatientStatus.initial,
    this.errorMessage,
    this.patient,
  });

  GetSinglePatientState copyWith({
    GetSinglePatientStatus? state,
    String? errorMessage,
    Patient? patient,
  }) {
    return GetSinglePatientState(
      state: state ?? this.state,
      errorMessage: errorMessage ?? this.errorMessage,
      patient: patient ?? this.patient,
    );
  }
}
