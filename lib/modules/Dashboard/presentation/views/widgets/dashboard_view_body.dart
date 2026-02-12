import 'package:flutter/material.dart';
import '../../../data/models/dashboard_model.dart';
import '../../manager/dashboard_cubit.dart';
import 'dashboard_stats_cards.dart';
import 'today_appointments_widget.dart';
import 'examination_types_chart.dart';
import 'examinations_trend_chart.dart';
import 'dashboard_comparisons.dart';
import 'dashboard_bottom_widgets.dart';

import 'dashboard_shimmer.dart';

class DashboardViewBody extends StatelessWidget {
  final DashboardModel? dashboardData;
  final bool isLoading;
  final DashboardCubit cubit;

  const DashboardViewBody({
    super.key,
    this.dashboardData,
    this.isLoading = false,
    required this.cubit,
  });

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const DashboardShimmer();
    }

    if (dashboardData == null) {
      return RefreshIndicator(
        onRefresh: () async {
          cubit.add(GetDashboardEvent());
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: SizedBox(
            height: MediaQuery.of(context).size.height * 0.7,
            child: const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.analytics_outlined, size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  Text("No Data Available", style: TextStyle(color: Colors.grey, fontSize: 18)),
                ],
              ),
            ),
          ),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () async {
        cubit.add(GetDashboardEvent());
      },
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.symmetric(vertical: 24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            DashboardStatsCards(operational: dashboardData!.operational),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 32),
                  TodayAppointmentsWidget(
                      today: dashboardData!.operational?.today),
                  const SizedBox(height: 32),
                  ExaminationTypesChart(
                      distribution: dashboardData!
                          .analytics?.examinationTypeDistribution),
                  const SizedBox(height: 32),
                  ExaminationsTrendChart(
                      trends: dashboardData!.analytics?.examinationsTrend),
                  const SizedBox(height: 32),
                  DashboardComparisons(comparisons: dashboardData!.comparisons),
                  const SizedBox(height: 32),
                  DashboardBottomWidgets(analytics: dashboardData!.analytics),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
