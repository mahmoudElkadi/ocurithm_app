
import '../models/analysis_model.dart';

abstract class AnalysisRepo {
  Future<AnalysisModel> getPatientAnalysis({String? patientId});

}
