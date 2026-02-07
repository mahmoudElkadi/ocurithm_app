import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class ExaminationFormShimmer extends StatelessWidget {
  const ExaminationFormShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    bool isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Scaffold( // Wrapped in Scaffold to ensure full screen coverage
      resizeToAvoidBottomInset: false,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Shimmer (Step indicator)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildShimmerBox(context, height: 40, width: 150),
                  _buildShimmerBox(context, height: 40, width: 40, isCircle: true),
                ],
              ),
              const SizedBox(height: 32),
              
              // Title Shimmer
              _buildShimmerBox(context, height: 24, width: 200),
              const SizedBox(height: 16),
              
              // Input Box Shimmer (Large)
              _buildShimmerBox(context, height: 180), 
              
              const SizedBox(height: 32),
              
              // Another Title Shimmer
              _buildShimmerBox(context, height: 24, width: 150),
              const SizedBox(height: 16),
              
              // Input Box Shimmer (Medium)
              _buildShimmerBox(context, height: 120),
              
               const SizedBox(height: 32),
               
               // Navigation Buttons Shimmer
               Row(
                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
                 children: [
                    _buildShimmerBox(context, height: 50, width: 120),
                    _buildShimmerBox(context, height: 50, width: 120),
                 ],
               )
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildShimmerBox(BuildContext context, {double? height, double? width, bool isCircle = false}) {
     bool isDark = Theme.of(context).brightness == Brightness.dark;
     
    return Shimmer.fromColors(
      baseColor: isDark ? Colors.grey.shade800 : Colors.grey.shade300,
      highlightColor: isDark ? Colors.grey.shade700 : Colors.grey.shade100,
      child: Container(
        height: height,
        width: width ?? double.infinity,
        decoration: BoxDecoration(
          color: isDark ? Colors.black : Colors.white,
          shape: isCircle ? BoxShape.circle : BoxShape.rectangle,
          borderRadius: isCircle ? null : BorderRadius.circular(16),
        ),
      ),
    );
  }
}
