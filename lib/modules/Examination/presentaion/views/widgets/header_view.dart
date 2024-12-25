// lib/features/examination/presentation/widgets/step_header.dart
import 'package:flutter/material.dart';

import '../../../../../core/utils/colors.dart';

class CustomHeaderClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    var path = Path();
    path.lineTo(0, size.height - 20); // Reduced wave height

    // Smaller, more subtle wave
    var firstControlPoint = Offset(size.width / 4, size.height);
    var firstEndPoint = Offset(size.width / 2, size.height - 10);
    path.quadraticBezierTo(
      firstControlPoint.dx,
      firstControlPoint.dy,
      firstEndPoint.dx,
      firstEndPoint.dy,
    );

    var secondControlPoint = Offset(size.width - (size.width / 4), size.height - 15);
    var secondEndPoint = Offset(size.width, size.height - 5);
    path.quadraticBezierTo(
      secondControlPoint.dx,
      secondControlPoint.dy,
      secondEndPoint.dx,
      secondEndPoint.dy,
    );

    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}

// lib/features/examination/presentation/widgets/step_header.dart

class StepHeader extends StatelessWidget {
  final int currentStep;
  final int totalSteps;
  final VoidCallback onMenuPressed;

  const StepHeader({
    Key? key,
    required this.currentStep,
    required this.totalSteps,
    required this.onMenuPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final singleStepWidth = (screenWidth - 40 - (8 * (totalSteps - 1))) / totalSteps;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        // boxShadow: [
        //   BoxShadow(
        //     color: Colorz.primaryColor.withOpacity(0.2),
        //     blurRadius: 8,
        //     spreadRadius: 1,
        //     offset: const Offset(0, 2),
        //   ),
        // ],
      ),
      child: Column(
        children: [
          const SizedBox(height: 25),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Builder(builder: (context) {
                return IconButton(
                  onPressed: () => Scaffold.of(context).openDrawer(),
                  icon: Icon(
                    Icons.menu,
                    color: Colorz.primaryColor,
                    size: 28,
                  ),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                );
              }),
              Text(
                _getStepTitle(currentStep),
                style: TextStyle(
                  color: Colorz.primaryColor,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '${currentStep + 1}/$totalSteps',
                  style: TextStyle(
                    color: Colorz.primaryColor,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          // Fixed Progress Indicators
          Row(
            children: List.generate(
              totalSteps,
              (index) => Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      return Stack(
                        children: [
                          // Background line
                          Container(
                            height: 3,
                            width: constraints.maxWidth,
                            decoration: BoxDecoration(
                              color: Colorz.primaryColor.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(1.5),
                            ),
                          ),
                          // Progress line
                          AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            height: 3,
                            width: index <= currentStep ? constraints.maxWidth : 0,
                            decoration: BoxDecoration(
                              color: Colorz.primaryColor,
                              borderRadius: BorderRadius.circular(1.5),
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _getStepTitle(int step) {
    switch (step) {
      case 0:
        return 'Patient History';
      case 1:
        return 'Patient Complaint';
      case 2:
        return 'Diagnosis';
      case 3:
        return 'Review & Submit';
      default:
        return '';
    }
  }
}

class ModernStepHeader extends StatelessWidget {
  final int currentStep;
  final int totalSteps;
  final VoidCallback onMenuPressed;

  const ModernStepHeader({
    Key? key,
    required this.currentStep,
    required this.totalSteps,
    required this.onMenuPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StepHeader(currentStep: currentStep, totalSteps: totalSteps, onMenuPressed: onMenuPressed);
  }
}
