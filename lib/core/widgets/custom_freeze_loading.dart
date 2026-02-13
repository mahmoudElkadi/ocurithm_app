import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:ocurithm/core/utils/colors.dart';

import '../utils/app_style.dart';

customLoading(context, String text) {
  showDialog(
    barrierDismissible: false,
    context: context,
    builder: (context) {
      return PopScope(
          child: Scaffold(
            backgroundColor: Colors.transparent,
            body: Container(
              width: MediaQuery.sizeOf(context).width,
              color: Colors.transparent,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const LoaderStyle(
                    size: 70,
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  Text(
                    text,
                    maxLines: 1,
                    overflow: TextOverflow.fade,
                    style: appStyle(context, 20, Colors.white, FontWeight.w700),
                  ),
                ],
              ),
            ),
          ),
          onPopInvoked: (h) async => false);
    },
  );
}

class LoaderStyle extends StatefulWidget {
  final double size;

  const LoaderStyle({
    super.key,
    this.size = 100,
  });

  @override
  State<LoaderStyle> createState() => _LoaderStyleState();
}

class _LoaderStyleState extends State<LoaderStyle>
    with TickerProviderStateMixin {
  late AnimationController _rotationController;
  late AnimationController _convergenceController;
  late Animation<double> _rotationAnimation;
  late Animation<double> _convergenceAnimation;

  @override
  void initState() {
    super.initState();

// Separate controllers for smooth independent animations
    _rotationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 750),
    );

    _convergenceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

// Rotation animation for the overall movement
    _rotationAnimation = Tween<double>(
      begin: 0,
      end: 2 * pi,
    ).animate(CurvedAnimation(
      parent: _rotationController,
      curve: Curves.linear,
    ));

// Convergence animation with smooth sine wave
    _convergenceAnimation = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(
      parent: _convergenceController,
      curve: Curves.easeInOut,
    ));

    _rotationController.repeat();
    _convergenceController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _rotationController.dispose();
    _convergenceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.size,
      height: widget.size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          AnimatedBuilder(
            animation:
                Listenable.merge([_rotationController, _convergenceController]),
            builder: (context, child) {
              return Transform.rotate(
                angle: _rotationAnimation.value,
                child: CustomPaint(
                  size: Size(widget.size, widget.size),
                  painter: ThreePieceArcPainter(
                    convergenceProgress: _convergenceAnimation.value,
                    color: Colorz.secondaryColor,
                  ),
                ),
              );
            },
          ),
// Center logo
          Container(
            width: widget.size * 0.8,
            height: widget.size * 0.8,
            decoration: const BoxDecoration(),
            child: SvgPicture.asset(
              'assets/icons/logos.svg',
              width: 60,
              height: 60,
            ),
          ),
        ],
      ),
    );
  }
}

class ThreePieceArcPainter extends CustomPainter {
  final double convergenceProgress;
  final Color color;

  ThreePieceArcPainter({
    required this.convergenceProgress,
    this.color = Colors.green,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final strokeWidth = 5.0;
    final radius = (size.width - strokeWidth) / 2;
    final rect = Rect.fromCircle(
      center: size.center(Offset.zero),
      radius: radius,
    );

    final paint1 = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final paint2 = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final paint3 = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

// Base arc length
    double baseArcLength = pi / 3; // 60 degrees each

// Calculate smooth convergence factor (0 = spread out, 1 = close together)
    double convergenceFactor = convergenceProgress;

// Base angular separation between arcs (120 degrees apart when spread)
    double baseAngularSeparation = 2 * pi / 3; // 120 degrees

// Minimum separation when converged (still some gap for visibility)
    double minSeparation = pi / 6; // 30 degrees

// Current separation based on convergence
    double currentSeparation = minSeparation +
        (baseAngularSeparation - minSeparation) * (1 - convergenceFactor);

// Starting positions for the three arcs
    double startAngle1 = 0;
    double startAngle2 = currentSeparation;
    double startAngle3 = currentSeparation * 2;

// Adjust arc length based on convergence for smoother effect
    double currentArcLength = baseArcLength * (0.8 + 0.2 * convergenceFactor);

// Draw the three arcs with different colors
    canvas.drawArc(rect, startAngle1, currentArcLength, false, paint1);
    canvas.drawArc(rect, startAngle2, currentArcLength, false, paint2);
    canvas.drawArc(rect, startAngle3, currentArcLength, false, paint3);
  }

  @override
  bool shouldRepaint(covariant ThreePieceArcPainter oldDelegate) {
    return oldDelegate.convergenceProgress != convergenceProgress ||
        oldDelegate.color != color ||
        oldDelegate.color != color ||
        oldDelegate.color != color;
  }
}
