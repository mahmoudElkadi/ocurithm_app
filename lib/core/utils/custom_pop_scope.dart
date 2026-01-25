import 'dart:developer';
import 'dart:io';

import 'package:flutter/material.dart';

class CustomPopScope extends StatefulWidget {
  final Widget child;
  final VoidCallback? onWillPop;
  final bool enabled;
  final double dragOffset;
  final double minFlingVelocity;
  final double completionThreshold;
  final double maxSwipeAngle;

  const CustomPopScope({
    super.key,
    required this.child,
    this.onWillPop,
    this.enabled = true,
    this.dragOffset = 75.0,
    this.minFlingVelocity = 700.0,
    this.completionThreshold = 0.35,
    this.maxSwipeAngle = 50.0,
  });

  @override
  State<CustomPopScope> createState() => _CustomPopScopeState();
}

class _CustomPopScopeState extends State<CustomPopScope>
    with SingleTickerProviderStateMixin {
  bool _isDragging = false;
  double _dragStartX = 0;
  double _dragStartY = 0;
  double _dragDistance = 0;

  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    log('message34433');
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _animation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    );

    // Add listener to trigger rebuilds only when needed
    _animation.addListener(() {
      if (!_isDragging) {
        setState(() {});
      }
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _onHorizontalDragStart(DragStartDetails details) {
    if (!widget.enabled || !Platform.isIOS) return;

    final isDraggingFromLeft = details.globalPosition.dx < widget.dragOffset;

    if (isDraggingFromLeft) {
      setState(() {
        _isDragging = true;
        _dragStartX = details.globalPosition.dx;
        _dragStartY = details.globalPosition.dy;
        _dragDistance = 0;
      });
    }
  }

  void _onHorizontalDragUpdate(DragUpdateDetails details) {
    if (!_isDragging) return;

    // Calculate new distance
    final newDistance =
        (details.globalPosition.dx - _dragStartX).clamp(0.0, double.infinity);

    // Check if drag is too vertical
    final dx = details.globalPosition.dx - _dragStartX;
    final dy = details.globalPosition.dy - _dragStartY;

    if (dx > 10) {
      final angle = (dy.abs() / dx * 180 / 3.14159);
      if (angle > widget.maxSwipeAngle) {
        _cancelDrag();
        return;
      }
    }

    // Update distance without setState during drag
    _dragDistance = newDistance;

    // Force rebuild only if needed (every few pixels to reduce rebuilds)
    if ((_dragDistance - _dragStartX).abs() > 5 || _dragDistance == 0) {
      setState(() {});
    }
  }

  void _onHorizontalDragEnd(DragEndDetails details) {
    if (!_isDragging) return;

    final screenWidth = MediaQuery.of(context).size.width;
    final dragVelocity = details.velocity.pixelsPerSecond.dx;
    final dragVertical = details.globalPosition.dy - _dragStartY;

    final swipeAngle = _dragDistance > 0
        ? (dragVertical.abs() / _dragDistance * 180 / 3.14159)
        : 90.0;

    bool shouldPop = false;

    if (swipeAngle <= widget.maxSwipeAngle) {
      if (dragVelocity > widget.minFlingVelocity) {
        shouldPop = true;
      } else if (_dragDistance > screenWidth * widget.completionThreshold) {
        shouldPop = true;
      }
    }

    setState(() {
      _isDragging = false;
    });

    if (shouldPop) {
      if (widget.onWillPop != null) {
        _animateBack();
        widget.onWillPop!();
      } else {
        _animateAndPop();
      }
    } else {
      _animateBack();
    }
  }

  void _cancelDrag() {
    if (!_isDragging) return;

    setState(() {
      _isDragging = false;
      _dragDistance = 0;
    });
  }

  Future<void> _animateAndPop() async {
    log(';;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;');
    final screenWidth = MediaQuery.of(context).size.width;
    final startValue = _dragDistance / screenWidth;

    _animationController.value = startValue;
    await _animationController.forward(from: startValue);

    if (mounted) {
      if (widget.onWillPop != null) {
        widget.onWillPop!();
      } else {
        Navigator.of(context).maybePop();
      }
    }
  }

  Future<void> _animateBack() async {
    final screenWidth = MediaQuery.of(context).size.width;
    final startValue = _dragDistance / screenWidth;

    _animationController.value = startValue;
    await _animationController.reverse(from: startValue);

    if (mounted) {
      setState(() {
        _dragDistance = 0;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.enabled) {
      return widget.child;
    }

    final screenWidth = MediaQuery.of(context).size.width;
    final dragProgress = _isDragging
        ? (_dragDistance / screenWidth).clamp(0.0, 1.0)
        : _animation.value;

    final slideOffset = dragProgress * screenWidth;

    return GestureDetector(
      onHorizontalDragStart: _onHorizontalDragStart,
      onHorizontalDragUpdate: _onHorizontalDragUpdate,
      onHorizontalDragEnd: _onHorizontalDragEnd,
      behavior: HitTestBehavior.translucent,
      child: Transform.translate(
        offset: Offset(slideOffset, 0),
        child: PopScope(
          canPop: false,
          onPopInvokedWithResult: (didPop, result) async {
                  if (!didPop) {
              widget.onWillPop?.call();
            }
          },
          child: widget.child,
        ),
      ),
    );
  }
}
