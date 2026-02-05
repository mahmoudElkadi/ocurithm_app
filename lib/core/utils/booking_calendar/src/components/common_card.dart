import 'package:flutter/material.dart';

class CommonCard extends StatelessWidget {
  const CommonCard(
      {Key? key, required this.child, this.padding, this.margin, this.color, this.borderRadius, this.boxShadow})
      : super(key: key);

  final Widget child;
  final EdgeInsets? padding;
  final EdgeInsets? margin;
  final BorderRadius? borderRadius;
  final BoxShadow? boxShadow;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
        //margin: margin,
        padding:  const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
        decoration: BoxDecoration(
          color: isDark ? Colors.grey[850] : Colors.white,
          borderRadius: borderRadius ?? const BorderRadius.all(Radius.circular(16)), 
          border: Border.all(color: color ?? (isDark ? Colors.grey[700]! : Colors.white), width: 1.0),
          boxShadow: [
            boxShadow ??
                BoxShadow(blurRadius: 10.0, offset: const Offset(0, 5), color: (isDark ? Colors.black : const Color(0xff666666)).withValues(alpha:0.2))
          ],
        ),
        child: child);
  }
}
