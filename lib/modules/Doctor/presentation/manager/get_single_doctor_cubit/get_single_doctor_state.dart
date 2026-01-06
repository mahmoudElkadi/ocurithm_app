part of 'get_single_doctor_cubit.dart';

enum GetSingleDoctorStatus {
  initial,
  loading,
  success,
  error,
  noConnection,
}

extension GetSingleDoctorStatusX on GetSingleDoctorState {
  bool get isInitial => state == GetSingleDoctorStatus.initial;

  bool get isLoading => state == GetSingleDoctorStatus.loading;

  bool get isSuccess => state == GetSingleDoctorStatus.success;

  bool get isError => state == GetSingleDoctorStatus.error;

  bool get noConnection => state == GetSingleDoctorStatus.noConnection;
}

@immutable
class GetSingleDoctorState {
  final GetSingleDoctorStatus state;
  final String? errorMessage;
  final Doctor? doctor;

  const GetSingleDoctorState({
    this.state = GetSingleDoctorStatus.initial,
    this.errorMessage,
    this.doctor,
  });

  GetSingleDoctorState copyWith({
    GetSingleDoctorStatus? state,
    String? errorMessage,
    Doctor? doctor,
  }) {
    return GetSingleDoctorState(
      state: state ?? this.state,
      errorMessage: errorMessage ?? this.errorMessage,
      doctor: doctor ?? this.doctor,
    );
  }
}
