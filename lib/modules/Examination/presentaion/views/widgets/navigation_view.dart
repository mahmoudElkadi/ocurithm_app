import 'package:flutter/material.dart';

import '../../../../../core/utils/colors.dart';

class StepNavigation extends StatelessWidget {
  final VoidCallback? onPrevious;
  final VoidCallback? onNext;
  final VoidCallback? onConfirm;
  final bool canGoBack;
  final bool canContinue;
  final bool isLastStep;

  const StepNavigation({
    Key? key,
    this.onPrevious,
    this.onNext,
    this.onConfirm,
    required this.canGoBack,
    required this.canContinue,
    required this.isLastStep,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 70,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Row(
          children: [
            if (canGoBack) ...[
              _buildBackButton(context),
              const SizedBox(width: 12),
            ],
            Expanded(
              child: _buildNextButton(context),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBackButton(BuildContext context) {
    return Container(
      height: 56,
      width: 56,
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(8),
      ),
      child: IconButton(
        icon: Icon(
          Icons.arrow_back_rounded,
          color: Colors.grey[800],
        ),
        onPressed: onPrevious,
      ),
    );
  }

  Widget _buildNextButton(BuildContext context) {
    final bool isEnabled = canContinue;

    return Container(
      height: 56,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        gradient: isEnabled || isLastStep
            ? LinearGradient(
                colors: [
                  Colorz.primaryColor,
                  Color.lerp(Colorz.primaryColor, Colors.black, 0.2)!,
                  Color.lerp(Colorz.primaryColor, Colors.black, 0.3)!,
                  Color.lerp(Colorz.primaryColor, Colors.black, 0.4)!,
                ],
              )
            : null,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: isEnabled
              ? onNext
              : isLastStep
                  ? onConfirm
                  : null,
          borderRadius: BorderRadius.circular(8),
          child: Center(
            child: Text(
              isLastStep ? 'Complete' : 'Continue',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.5,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
