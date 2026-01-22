import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ocurithm/modules/Analysis/data/models/analysis_model.dart';
import 'package:rxdart/rxdart.dart';
import '../../../data/repos/analysis_repo.dart';

part 'get_analysis_state.dart';
part 'get_analysis_event.dart';

/// Cubit for fetching and managing Analysis list
/// Includes debounced search, pagination, and filters
class GetAnalysisCubit extends Bloc<GetAnalysisEvent, GetAnalysisState> {
  final AnalysisRepo analysisRepo;
  final _searchSubject = BehaviorSubject<String>();

  GetAnalysisCubit(this.analysisRepo) : super(const GetAnalysisState()) {
    on<GetPatientAnalysisEvent>(_onGetAllAnalysis);
    // Listen to search subject with debounce
    _searchSubject
        .debounceTime(const Duration(milliseconds: 700))
        .listen((searchText) {
      add(GetPatientAnalysisEvent());
    });
  }

  static GetAnalysisCubit get(BuildContext context) => BlocProvider.of(context);

  // Call this when you want to trigger search with debounce


  // Get All Analysis
  Future<void> _onGetAllAnalysis(
      GetPatientAnalysisEvent event, Emitter<GetAnalysisState> emit) async {
    try {
      emit(state.copyWith(state: GetAnalysisStatus.loading));

      final analysis = await analysisRepo.getPatientAnalysis(
        patientId: event.patientId

      );

      emit(state.copyWith(
        state: GetAnalysisStatus.success,
        analysis: analysis,
      ));
    } catch (e) {
      if (e.toString().toLowerCase().contains('no internet connection')) {
        emit(state.copyWith(
          state: GetAnalysisStatus.noConnection,
          errorMessage: e.toString(),
        ));
        return;
      }
      if (e.toString().toLowerCase().contains('request cancelled')) {
        return;
      }
      emit(state.copyWith(
        state: GetAnalysisStatus.error,
        errorMessage: e.toString(),
      ));
    }
  }

  @override
  Future<void> close() {
    _searchSubject.close();
    return super.close();
  }
}
