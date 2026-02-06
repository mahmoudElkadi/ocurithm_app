import 'package:flutter/material.dart';

import 'common_card.dart';

class BookingSlot extends StatelessWidget {
  const BookingSlot({
    Key? key,
    required this.child,
    required this.isBooked,
    required this.onTap,
    required this.isSelected,
    required this.isPauseTime,
    this.bookedSlotColor,
    this.selectedSlotColor,
    this.availableSlotColor,
    this.pauseSlotColor,
    this.hideBreakSlot,
  }) : super(key: key);

  final Widget child;
  final bool isBooked;
  final bool isPauseTime;
  final bool isSelected;
  final VoidCallback onTap;
  final Color? bookedSlotColor;
  final Color? selectedSlotColor;
  final Color? availableSlotColor;
  final Color? pauseSlotColor;
  final bool? hideBreakSlot;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    Color? cardColor;
    Color? borderColor;
    double? borderWidth;

    if (isPauseTime) {
      cardColor = pauseSlotColor ?? (isDark ? Colors.grey[800]! : Colors.grey[300]!);
    } else if (isBooked) {
      cardColor = bookedSlotColor ?? Colors.redAccent;
    } else if (isSelected) {
      cardColor = selectedSlotColor ?? Colors.orangeAccent;
    } else {
      // Available slot - Outlined style as in the image
      cardColor = isDark ? theme.cardColor : Colors.white;
      borderColor = availableSlotColor ?? theme.primaryColor;
      borderWidth = 1.0;
    }

    return (hideBreakSlot != null && hideBreakSlot == true && isPauseTime)
        ? const SizedBox()
        : GestureDetector(
            onTap: (!isPauseTime) ? onTap : null,
            child: CommonCard(
                margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
                padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 0),
                color: cardColor,
                borderColor: borderColor,
                borderWidth: borderWidth,
                child: Center(child: child)),
          );
  }
}
