import '../../../../../core/api/api_constants.dart';
import '../../../../../core/api/api_handler.dart';
import '../models/analysis_model.dart';
import 'analysis_repo.dart';


class AnalysisRepoImpl implements AnalysisRepo {
  final ApiHandler _apiHandler = ApiHandler();



  @override
  Future<AnalysisModel> getPatientAnalysis({String? patientId}) async {
    try {
      final response = await _apiHandler.get<AnalysisModel>(
       '${ApiConstants.patients}/$patientId/${ApiConstants.analysis}',
        cancelKey: 'getPatientAnalysis',
        fromJson: (json) => AnalysisModel.fromJson(json),
      );

      // Check if the response was successful
      if (response.success && response.data != null) {
        return response.data!;
      } else {
        // Handle error case
        throw Exception(response.message ?? 'Failed to fetch doctors');
      }
    } catch (e) {
      rethrow;
    }
  }


}
