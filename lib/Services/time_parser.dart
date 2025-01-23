import 'package:flutter/material.dart';

class TimeParser {
  static TimeOfDay? stringToTimeOfDay(String? timeStr) {
    if (timeStr == null) return null;

    try {
      final parts = timeStr.split(':');
      if (parts.length != 2) return null;

      final hour = int.tryParse(parts[0]);
      final minute = int.tryParse(parts[1]);

      if (hour == null || minute == null) return null;
      if (hour < 0 || hour > 23 || minute < 0 || minute > 59) return null;

      return TimeOfDay(hour: hour, minute: minute);
    } catch (e) {
      return null;
    }
  }

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
      return TimeOfDay(hour: hour, minute: 0);
    } catch (e) {
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

    return '$hour:$minute';
  }
}

class EgyptianDateTime {
  // Egypt uses a constant GMT+2 offset
  static const egyptHourOffset = 2;
  static const egyptTimezoneName = 'EET'; // Eastern European Time

  /// Converts any DateTime to Egypt's timezone (GMT+2)
  static DateTime convertToEgyptTime(DateTime dateTime) {
    // First convert to UTC to ensure we're working from a consistent base
    final utcDateTime = dateTime.toUtc();
    // Add 2 hours for Egypt's timezone
    return utcDateTime.add(const Duration(hours: egyptHourOffset));
  }

  /// Converts from Egypt time to UTC
  static DateTime convertToUTC(DateTime egyptDateTime) {
    // Subtract 2 hours to get to UTC
    return egyptDateTime.subtract(const Duration(hours: egyptHourOffset));
  }

  /// Formats a DateTime to string in Egypt's timezone
  static String formatToEgyptString(DateTime dateTime) {
    final egyptTime = convertToEgyptTime(dateTime);
    return egyptTime.toIso8601String();
  }

  /// Parses a string to DateTime in Egypt's timezone
  static DateTime parseFromEgyptString(String dateTimeString) {
    final dateTime = DateTime.parse(dateTimeString);
    return convertToEgyptTime(dateTime);
  }

  /// Gets the UTC offset for Egypt (always +02:00)
  static String getUTCOffset() {
    return '+${egyptHourOffset.toString().padLeft(2, '0')}:00';
  }

  /// Validates if a DateTime is in Egypt's timezone
  static bool isEgyptianTime(DateTime dateTime) {
    final offset = dateTime.timeZoneOffset.inHours;
    return offset == egyptHourOffset;
  }

  /// Format a DateTime for display in Egyptian time
  static String formatForDisplay(DateTime dateTime) {
    final egyptTime = convertToEgyptTime(dateTime);
    return '${egyptTime.toString()} EET';
  }
}

// Extension methods for easier DateTime manipulation
extension EgyptianDateTimeExtension on DateTime {
  DateTime toEgyptTime() {
    return EgyptianDateTime.convertToEgyptTime(this);
  }

  String toEgyptString() {
    return EgyptianDateTime.formatToEgyptString(this);
  }

  bool isEgyptianTime() {
    return EgyptianDateTime.isEgyptianTime(this);
  }
}
