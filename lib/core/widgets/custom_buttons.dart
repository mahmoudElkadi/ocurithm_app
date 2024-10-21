import 'package:flutter/material.dart';

class MyElevatedButton extends StatelessWidget {
  final BorderRadiusGeometry? borderRadius;

  final Gradient gradient;
  final VoidCallback? onPressed;
  final Widget child;
  final List<BoxShadow>? boxShadow;
  final BoxShape? shape;

  const MyElevatedButton({
    Key? key,
    required this.onPressed,
    required this.child,
    this.borderRadius,
    this.gradient = const LinearGradient(colors: [Colors.cyan, Colors.indigo]),
    this.boxShadow,
    this.shape = BoxShape.rectangle,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final borderRadius = this.borderRadius ?? BorderRadius.circular(0);
    return Container(
      decoration: BoxDecoration(gradient: gradient, borderRadius: borderRadius, boxShadow: boxShadow, shape: shape!),
      padding: EdgeInsets.all(0),
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          padding: EdgeInsets.all(0),
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(borderRadius: borderRadius),
        ),
        child: child,
      ),
    );
  }
}
