import 'package:ocurithm/modules/Dashboard/data/models/dashboard_model.dart';

abstract class DashboardRepo {
  Future<DashboardModel> getDashboard({
    DateTime? start,
    DateTime? end,
  });
}
