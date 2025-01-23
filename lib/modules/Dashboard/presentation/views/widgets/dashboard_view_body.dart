import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:shimmer/shimmer.dart';

import '../../../../../core/utils/colors.dart';
import '../../../data/models/dashboard_model.dart';
import '../../manager/dashboard_cubit.dart';

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
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          spacing: 16,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDailyStats(),
            if (isLoading || dashboardData?.examinationTypes != null)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionTitle("Examination Types"),
                  _buildExaminationTypes(),
                ],
              ),
            if (isLoading || dashboardData?.branches != null)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionTitle("Branches"),
                  _buildBranches(),
                ],
              ),
            if (isLoading || dashboardData?.doctors != null)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionTitle("Doctors"),
                  _buildDoctors(),
                ],
              ),
            if (isLoading || dashboardData?.patients != null)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionTitle("Patients"),
                  _buildPatients(),
                ],
              ),
            if (isLoading || dashboardData?.statuses != null)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionTitle("Statuses"),
                  _buildStatuses(),
                ],
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildDailyStats() {
    if (isLoading) {
      return Shimmer.fromColors(
        baseColor: Colors.grey.shade300,
        highlightColor: Colors.grey.shade100,
        child: Row(
          children: [
            _buildDailyStatShimmer(),
            const SizedBox(width: 10),
            _buildDailyStatShimmer(),
            const SizedBox(width: 10),
            _buildDailyStatShimmer(),
          ],
        ),
      );
    }

    final isDateRangeSelected = cubit.isDateRangeSelected;

    return Row(
      children: [
        if (!isDateRangeSelected) ...[
          _buildDailyStat("Yesterday", dashboardData?.yesterday?.toString() ?? "0", Colors.orange),
          const SizedBox(width: 10),
          _buildDailyStat("Today", dashboardData?.count?.toString() ?? "0", Colors.green),
          const SizedBox(width: 10),
          _buildDailyStat("Tomorrow", dashboardData?.tomorrow?.toString() ?? "0", Colorz.primaryColor),
        ],
        if (isDateRangeSelected) ...[
          _buildDailyStat("Total", dashboardData?.count?.toString() ?? "0", Colorz.primaryColor),
        ],
      ],
    );
  }

  Widget _buildDailyStat(String title, String value, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDailyStatShimmer() {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Container(
              width: 60,
              height: 16,
              color: Colors.white,
            ),
            const SizedBox(height: 8),
            Container(
              width: 40,
              height: 20,
              color: Colors.white,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: Colorz.primaryColor,
        ),
      ),
    );
  }

  Widget _buildExaminationTypes() {
    if (isLoading) {
      return _buildShimmerList();
    }

    return dashboardData!.examinationTypes.isNotEmpty
        ? Column(
            children: dashboardData?.examinationTypes.map((type) => _buildListItem(type.name ?? "N/A", type.count?.toString() ?? "0")).toList() ?? [],
          )
        : Center(
            child: Column(
              children: [
                const SizedBox(height: 16),
                SvgPicture.asset(
                  "assets/icons/exam_type.svg",
                  width: 40,
                  height: 40,
                  color: Colors.grey,
                ),
                const SizedBox(height: 8),
                Text(
                  "No Examination Types Found",
                  style: TextStyle(color: Colorz.grey, fontSize: 16, fontWeight: FontWeight.w600),
                ),
              ],
            ),
          );
  }

  Widget _buildBranches() {
    if (isLoading) {
      return _buildShimmerList();
    }

    return dashboardData?.branches.isNotEmpty == true
        ? Column(
            children: dashboardData?.branches.map((branch) => _buildListItem(branch.name ?? "N/A", branch.count?.toString() ?? "0")).toList() ?? [],
          )
        : Center(
            child: Column(
              children: [
                const SizedBox(height: 16),
                SvgPicture.asset(
                  "assets/icons/branch.svg",
                  width: 40,
                  height: 40,
                  color: Colors.grey,
                ),
                const SizedBox(height: 8),
                Text(
                  "No Branches Found",
                  style: TextStyle(color: Colorz.grey, fontSize: 16, fontWeight: FontWeight.w600),
                ),
              ],
            ),
          );
  }

  Widget _buildDoctors() {
    if (isLoading) {
      return _buildShimmerList();
    }

    return dashboardData?.doctors.isNotEmpty == true
        ? Column(
            children: dashboardData?.doctors.map((doctor) => _buildListItem(doctor.name ?? "N/A", doctor.count?.toString() ?? "0")).toList() ?? [],
          )
        : Center(
            child: Column(
            children: [
              const SizedBox(height: 16),
              SvgPicture.asset(
                "assets/icons/doctor.svg",
                width: 40,
                height: 40,
                color: Colors.grey,
              ),
              const SizedBox(height: 8),
              Text(
                "No Doctors Found",
                style: TextStyle(color: Colorz.grey, fontSize: 16, fontWeight: FontWeight.w600),
              ),
            ],
          ));
  }

  Widget _buildPatients() {
    if (isLoading) {
      return _buildShimmerList();
    }

    return dashboardData?.patients.isNotEmpty == true
        ? Column(
            children: dashboardData?.patients
                    .map((patient) => _buildPatientCard(
                          patient.name ?? "N/A",
                          patient.examinationType ?? "N/A",
                          patient.count?.toString() ?? "0",
                        ))
                    .toList() ??
                [],
          )
        : Center(
            child: Column(
            children: [
              const SizedBox(height: 16),
              SvgPicture.asset(
                "assets/icons/patient.svg",
                width: 40,
                height: 40,
                color: Colors.grey,
              ),
              const SizedBox(height: 8),
              Text(
                "No Patients Found",
                style: TextStyle(color: Colorz.grey, fontSize: 16, fontWeight: FontWeight.w600),
              ),
            ],
          ));
  }

  Widget _buildStatuses() {
    if (isLoading) {
      return _buildShimmerList();
    }

    return dashboardData?.statuses.isNotEmpty == true
        ? Column(
            children: dashboardData?.statuses.map((status) => _buildListItem(status.name ?? "N/A", status.count?.toString() ?? "0")).toList() ?? [],
          )
        : Center(
            child: Column(
            children: [
              const SizedBox(height: 16),
              SvgPicture.asset(
                "assets/icons/status.svg",
                width: 40,
                height: 40,
                color: Colors.grey,
              ),
              const SizedBox(height: 8),
              Text(
                "No Status Found",
                style: TextStyle(color: Colorz.grey, fontSize: 16, fontWeight: FontWeight.w600),
              ),
            ],
          ));
  }

  Widget _buildListItem(String title, String value) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 5,
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colorz.primaryColor.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: Text(
              value,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colorz.primaryColor,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPatientCard(String name, String examinationType, String count) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 5,
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                name,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                "Examination: $examinationType",
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey.shade600,
                ),
              ),
              const SizedBox(height: 8),
            ],
          ),
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colorz.primaryColor.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: Text(
              count,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colorz.primaryColor,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildShimmerList() {
    return Shimmer.fromColors(
      baseColor: Colors.grey.shade300,
      highlightColor: Colors.grey.shade100,
      child: Column(
        children: List.generate(
          3,
          (index) => Container(
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  width: 100,
                  height: 16,
                  color: Colors.white,
                ),
                Container(
                  width: 40,
                  height: 40,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
