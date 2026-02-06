import 'package:flutter/material.dart';

class CommonCard extends StatelessWidget {
  const CommonCard(
      {super.key, required this.child, this.padding, this.margin, this.color, this.borderRadius, this.boxShadow, this.borderColor, this.borderWidth});

  final Widget child;
  final EdgeInsets? padding;
  final EdgeInsets? margin;
  final BorderRadius? borderRadius;
  final BoxShadow? boxShadow;
  final Color? color;
  final Color? borderColor;
  final double? borderWidth;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    return Container(
        margin: margin,
        padding: padding ?? const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
        decoration: BoxDecoration(
          color: color ?? (isDark ? theme.cardColor : Colors.white),
          borderRadius: borderRadius ?? const BorderRadius.all(Radius.circular(15)),
          border: Border.all(
            color: borderColor ?? (isDark ? theme.dividerColor : Colors.grey.shade100),
            width: borderWidth ?? 0.5,
          ),
          boxShadow: [
            boxShadow ??
                BoxShadow(
                  blurRadius: 8.0,
                  offset: const Offset(0, 2),
                  color: (isDark ? Colors.black : const Color(0xff000000)).withValues(alpha: 0.05),
                )
          ],
        ),
        child: child);
  }
}
