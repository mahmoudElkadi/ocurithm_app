import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class DashboardShimmer extends StatelessWidget {
  const DashboardShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Stats Cards Shimmer
          Row(
            children: [
              Expanded(child: _buildShimmerBox(height: 120)),
              const SizedBox(width: 12),
              Expanded(child: _buildShimmerBox(height: 120)),
              const SizedBox(width: 12),
              Expanded(child: _buildShimmerBox(height: 120)),
            ],
          ),
          const SizedBox(height: 32),
          
          // Today Appointments Shimmer
          _buildSectionHeader(),
          const SizedBox(height: 16),
          _buildShimmerBox(height: 250),
          
          const SizedBox(height: 32),
          
          // Chart Shimmer
          _buildSectionHeader(),
          const SizedBox(height: 16),
          Row(
            children: [
              _buildShimmerBox(height: 200, width: 200, isCircle: true),
              const SizedBox(width: 24),
              Expanded(
                child: Column(
                  children: List.generate(5, (index) => Padding(
                    padding: const EdgeInsets.only(bottom: 8.0),
                    child: _buildShimmerBox(height: 20),
                  )),
                ),
              )
            ],
          ),
          
          const SizedBox(height: 32),
          
          // Comparisons Shimmer
          Row(
            children: [
              Expanded(child: _buildShimmerBox(height: 300)),
              const SizedBox(width: 16),
              Expanded(child: _buildShimmerBox(height: 300)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildShimmerBox(height: 24, width: 150),
        const SizedBox(height: 8),
        _buildShimmerBox(height: 16, width: 200),
      ],
    );
  }

  Widget _buildShimmerBox({double? height, double? width, bool isCircle = false}) {
    return Shimmer.fromColors(
      baseColor: Colors.grey.shade300,
      highlightColor: Colors.grey.shade100,
      child: Container(
        height: height,
        width: width ?? double.infinity,
        decoration: BoxDecoration(
          color: Colors.white,
          shape: isCircle ? BoxShape.circle : BoxShape.rectangle,
          borderRadius: isCircle ? null : BorderRadius.circular(12),
        ),
      ),
    );
  }
}
