part of 'get_clinics_cubit.dart';

enum GetClinicsStatus { initial, loading, success, error, noConnection, loadingMore }

extension GetClinicsStatusX on GetClinicsState {
  bool get isInitial => state == GetClinicsStatus.initial;

  bool get isLoading => state == GetClinicsStatus.loading;

  bool get isLoadingMore => state == GetClinicsStatus.loadingMore;

  bool get isSuccess => state == GetClinicsStatus.success;

  bool get isError => state == GetClinicsStatus.error;

  bool get noConnection => state == GetClinicsStatus.noConnection;
}

@immutable
class GetClinicsState {
  final GetClinicsStatus state;
  final String? errorMessage;
  final String? search  ;
  final int page;
  final ClinicsModel? clinics;

  const GetClinicsState({this.state = GetClinicsStatus.initial, this.errorMessage, this.search, this.page = 1, this.clinics});

  GetClinicsState copyWith({GetClinicsStatus? state, String? errorMessage, String? search, int? page, ClinicsModel? clinics}) {
    return GetClinicsState(
      state: state ?? this.state,
      search: search ?? this.search,
      errorMessage: errorMessage ?? this.errorMessage,
      page: page ?? this.page,
      clinics: clinics ?? this.clinics,
    );
  }
}
