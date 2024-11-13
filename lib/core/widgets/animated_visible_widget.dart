import 'package:flutter/material.dart';

class AnimatedVisibleWidget extends StatefulWidget {
  final bool isVisible;
  final Widget child;
  final Duration duration;
  final Curve curve;

  const AnimatedVisibleWidget({
    super.key,
    required this.isVisible,
    required this.child,
    this.duration = const Duration(milliseconds: 300),
    this.curve = Curves.easeInOut,
  });

  @override
  State<AnimatedVisibleWidget> createState() => _AnimatedVisibleWidgetState();
}

class _AnimatedVisibleWidgetState extends State<AnimatedVisibleWidget> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    );
    _animation = CurvedAnimation(
      parent: _controller,
      curve: widget.curve,
    );

    if (widget.isVisible) {
      _controller.forward();
    }
  }

  @override
  void didUpdateWidget(AnimatedVisibleWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isVisible != oldWidget.isVisible) {
      if (widget.isVisible) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Visibility(
          visible: _animation.value != 0,
          child: Opacity(
            opacity: _animation.value,
            child: Align(
              alignment: Alignment.topCenter,
              heightFactor: _animation.value,
              child: child,
            ),
          ),
        );
      },
      child: widget.child,
    );
  }
}
