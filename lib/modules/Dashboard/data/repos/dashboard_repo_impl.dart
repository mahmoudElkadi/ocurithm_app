import 'package:ocurithm/core/api/api_handler.dart';
import 'package:ocurithm/modules/Dashboard/data/models/dashboard_model.dart';
import 'dashboard_repo.dart';

class DashboardRepoImpl implements DashboardRepo {
  final ApiHandler _apiHandler = ApiHandler();

  @override
  Future<DashboardModel> getDashboard({
    DateTime? start,
    DateTime? end,
  }) async {
    try {
      Map<String, dynamic> query = {
        if (start != null) "startDate": start.toUtc(),
        if (end != null) "endDate": end.toUtc(),
      };

      final response = await _apiHandler.get<DashboardModel>(
        'dashboard',
        queryParameters: query,
        cancelKey: 'getDashboard',
        fromJson: (json) => DashboardModel.fromJson(json),
      );

      if (response.success && response.data != null) {
        return response.data!;
      } else {
        throw Exception(response.message ?? 'Failed to fetch dashboard data');
      }
    } catch (e) {
      rethrow;
    }
  }
}
