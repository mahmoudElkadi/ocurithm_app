import 'dart:developer';

import 'package:flutter/material.dart';

class TimeParser {
  static TimeOfDay parseTimeString(String timeStr) {
    try {
      // Handle different time formats
      if (timeStr.contains(':')) {
        final parts = timeStr.split(':');
        if (parts.length == 2) {
          final hour = int.parse(parts[0]);
          final minute = int.parse(parts[1]);
          return TimeOfDay(hour: hour, minute: minute);
        }
      }

      // If the time is a simple hour format (e.g., "9")
      final hour = int.parse(timeStr);
      log('parseTimeString: $hour');
      return TimeOfDay(hour: hour, minute: 0);
    } catch (e) {
      print('Error parsing time: $timeStr');
      // Return a default time if parsing fails
      return const TimeOfDay(hour: 9, minute: 0);
    }
  }

  static DateTime timeOfDayToDateTime(TimeOfDay timeOfDay) {
    final now = DateTime.now();
    return DateTime(
      now.year,
      now.month,
      now.day,
      timeOfDay.hour,
      timeOfDay.minute,
    );
  }

  static String formatTimeOfDay(TimeOfDay time) {
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');

    log('formatTimeOfDay: $hour:$minute');
    return '$hour:$minute';
  }
}
