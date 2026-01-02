part of 'get_single_clinic_cubit.dart';

enum GetSingleClinicStatus { initial, loading, success, error, noConnection }

extension GetSingleClinicStatusX on GetSingleClinicState {
  bool get isInitial => state == GetSingleClinicStatus.initial;

  bool get isLoading => state == GetSingleClinicStatus.loading;

  bool get isSuccess => state == GetSingleClinicStatus.success;

  bool get isError => state == GetSingleClinicStatus.error;

  bool get noConnection => state == GetSingleClinicStatus.noConnection;
}

@immutable
class GetSingleClinicState {
  final GetSingleClinicStatus state;
  final String? errorMessage;
  final Clinic? clinic;

  const GetSingleClinicState({
    this.state = GetSingleClinicStatus.initial,
    this.errorMessage,
    this.clinic,
  });

  GetSingleClinicState copyWith({
    GetSingleClinicStatus? state,
    String? errorMessage,
    Clinic? clinic,
  }) {
    return GetSingleClinicState(
      state: state ?? this.state,
      errorMessage: errorMessage ?? this.errorMessage,
      clinic: clinic ?? this.clinic,
    );
  }
}
