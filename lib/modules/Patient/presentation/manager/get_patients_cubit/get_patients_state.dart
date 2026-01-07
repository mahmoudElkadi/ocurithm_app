part of 'get_patients_cubit.dart';

enum GetPatientsStatus {
  initial,
  loading,
  success,
  error,
  noConnection,
  loadingMore
}

extension GetPatientsStatusX on GetPatientsState {
  bool get isInitial => state == GetPatientsStatus.initial;

  bool get isLoading => state == GetPatientsStatus.loading;

  bool get isLoadingMore => state == GetPatientsStatus.loadingMore;

  bool get isSuccess => state == GetPatientsStatus.success;

  bool get isError => state == GetPatientsStatus.error;

  bool get noConnection => state == GetPatientsStatus.noConnection;
}

@immutable
class GetPatientsState {
  final GetPatientsStatus state;
  final String? errorMessage;
  final String? search;
  final int page;
  final String? clinicFilter;
  final String? branchFilter;
  final PatientModel? patients;

  const GetPatientsState({
    this.state = GetPatientsStatus.initial,
    this.errorMessage,
    this.search,
    this.page = 1,
    this.clinicFilter,
    this.branchFilter,
    this.patients,
  });

  GetPatientsState copyWith({
    GetPatientsStatus? state,
    String? errorMessage,
    String? search,
    int? page,
    String? clinicFilter,
    String? branchFilter,
    PatientModel? patients,
  }) {
    return GetPatientsState(
      state: state ?? this.state,
      search: search ?? this.search,
      errorMessage: errorMessage ?? this.errorMessage,
      page: page ?? this.page,
      clinicFilter: clinicFilter ?? this.clinicFilter,
      branchFilter: branchFilter ?? this.branchFilter,
      patients: patients ?? this.patients,
    );
  }
}
