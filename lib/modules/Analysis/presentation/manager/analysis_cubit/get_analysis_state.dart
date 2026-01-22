part of 'get_analysis_cubit.dart';

enum GetAnalysisStatus {
  initial,
  loading,
  success,
  error,
  noConnection,
  loadingMore
}

extension GetAnalysisStatusX on GetAnalysisState {
  bool get isInitial => state == GetAnalysisStatus.initial;

  bool get isLoading => state == GetAnalysisStatus.loading;

  bool get isLoadingMore => state == GetAnalysisStatus.loadingMore;

  bool get isSuccess => state == GetAnalysisStatus.success;

  bool get isError => state == GetAnalysisStatus.error;

  bool get noConnection => state == GetAnalysisStatus.noConnection;
}

@immutable
class GetAnalysisState {
  final GetAnalysisStatus state;
  final String? errorMessage;
  final AnalysisModel? analysis;

  const GetAnalysisState({
    this.state = GetAnalysisStatus.initial,
    this.errorMessage,
    this.analysis,
  });

  GetAnalysisState copyWith({
    GetAnalysisStatus? state,
    String? errorMessage,

    AnalysisModel? analysis,
  }) {
    return GetAnalysisState(
      state: state ?? this.state,
      errorMessage: errorMessage ?? this.errorMessage,

      analysis: analysis ?? this.analysis,
    );
  }
}
