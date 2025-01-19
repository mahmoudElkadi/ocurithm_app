import 'package:flutter/material.dart';

import '../utils/colors.dart';

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

class CoolDownButton extends StatefulWidget {
  final Function() onTap;
  final String text;
  final Duration cooldownDuration;
  final double? width;

  const CoolDownButton({
    Key? key,
    required this.onTap,
    required this.text,
    this.width,
    this.cooldownDuration = const Duration(seconds: 2),
  }) : super(key: key);

  @override
  State<CoolDownButton> createState() => _CoolDownButtonState();
}

class _CoolDownButtonState extends State<CoolDownButton> {
  bool _isInCooldown = false;

  void _handleTap() {
    if (_isInCooldown) return;

    setState(() {
      _isInCooldown = true;
    });

    widget.onTap();

    Future.delayed(widget.cooldownDuration, () {
      if (mounted) {
        setState(() {
          _isInCooldown = false;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 40,
      width: widget.width,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        gradient: LinearGradient(
          colors: [
            _isInCooldown ? Colorz.primaryColor.withOpacity(0.5) : Colorz.primaryColor,
            Color.lerp(_isInCooldown ? Colorz.primaryColor.withOpacity(0.5) : Colorz.primaryColor, Colors.black, 0.2)!,
            Color.lerp(_isInCooldown ? Colorz.primaryColor.withOpacity(0.5) : Colorz.primaryColor, Colors.black, 0.3)!,
            Color.lerp(_isInCooldown ? Colorz.primaryColor.withOpacity(0.5) : Colorz.primaryColor, Colors.black, 0.4)!,
          ],
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: _isInCooldown ? null : _handleTap,
          borderRadius: BorderRadius.circular(8),
          child: Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14.0),
              child: Text(
                widget.text,
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
      ),
    );
  }
}
