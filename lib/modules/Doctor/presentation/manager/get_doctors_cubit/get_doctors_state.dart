part of 'get_doctors_cubit.dart';

enum GetDoctorsStatus {
  initial,
  loading,
  success,
  error,
  noConnection,
  loadingMore
}

extension GetDoctorsStatusX on GetDoctorsState {
  bool get isInitial => state == GetDoctorsStatus.initial;

  bool get isLoading => state == GetDoctorsStatus.loading;

  bool get isLoadingMore => state == GetDoctorsStatus.loadingMore;

  bool get isSuccess => state == GetDoctorsStatus.success;

  bool get isError => state == GetDoctorsStatus.error;

  bool get noConnection => state == GetDoctorsStatus.noConnection;
}

@immutable
class GetDoctorsState {
  final GetDoctorsStatus state;
  final String? errorMessage;
  final String? search;
  final int page;
  final String? clinicFilter;
  final String? branchFilter;
  final DoctorModel? doctors;

  const GetDoctorsState({
    this.state = GetDoctorsStatus.initial,
    this.errorMessage,
    this.search,
    this.page = 1,
    this.clinicFilter,
    this.branchFilter,
    this.doctors,
  });

  GetDoctorsState copyWith({
    GetDoctorsStatus? state,
    String? errorMessage,
    String? search,
    int? page,
    String? clinicFilter,
    String? branchFilter,
    DoctorModel? doctors,
  }) {
    return GetDoctorsState(
      state: state ?? this.state,
      search: search ?? this.search,
      errorMessage: errorMessage ?? this.errorMessage,
      page: page ?? this.page,
      clinicFilter: clinicFilter ?? this.clinicFilter,
      branchFilter: branchFilter ?? this.branchFilter,
      doctors: doctors ?? this.doctors,
    );
  }
}
