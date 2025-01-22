import 'package:ocurithm/modules/Dashboard/data/models/dashboard_model.dart';

import '../../../../../core/Network/dio_handler.dart';
import '../../../../../core/Network/shared.dart';
import '../../../../../core/utils/config.dart';
import 'dashboard_repo.dart';

class DashboardRepoImpl implements DashboardRepo {
  @override
  Future<DashboardModel> getDashboard({
    DateTime? start,
    DateTime? end,
  }) async {
    final url = Config.baseUrl;
    final String? token = CacheHelper.getData(key: "token");
    Map<String, dynamic> query = {if (start != null) "start": start, if (end != null) "end": end};
    final result = await ApiService.request<DashboardModel>(
      url: url,
      method: 'GET',
      queryParameters: query,
      headers: {
        "Content-Type": "application/json",
        if (token != null) 'Cookie': 'ocurithmToken=$token',
      },
      showError: true,
      fromJson: (json) => DashboardModel.fromJson(json),
    );

    if (result != null) {
      return result;
    } else {
      throw Exception("Failed to make examination");
    }
  }
}
