import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';

class FormatHelper {
  static String capitalizeFirstLetter(String input) {
    if (input.isEmpty) return input;
    return input.split(' ').map((word) {
      if (word.isEmpty) return word;
      return word[0].toUpperCase() + word.substring(1).toLowerCase();
    }).join(' ');
  }

  static String formatTime(int time, bool isExpired) {
    String formattedTime = time.abs().toString().padLeft(2, '0');
    if (isExpired) {
      formattedTime = formattedTime;
    }
    return formattedTime;
  }

  static String formatNumber(String s, String locale) {
    try {
      final number = int.parse(s.replaceAll(',', ''));
      return NumberFormat.decimalPattern(locale).format(number);
    } catch (e) {
      return s;
    }
  }

  static String formatDate(context, String? dateString) {
    if (dateString == null || dateString == "null") return 'N/A';
    try {
      final DateTime date = DateTime.parse(dateString);
      return DateFormat('dd-MM-yyyy').format(date);
    } catch (e) {
      if (kDebugMode) {
        print('Error parsing date: $e');
      }
      return 'Invalid Date'; // or return 'N/A' or any other default value
    }
  }

  static String formatDateTime(String? dateString) {
    if (dateString == null || dateString == "null") return 'N/A';
    try {
      final DateTime date = DateTime.parse(dateString);
      return DateFormat('dd-MM-yyyy hh:mm a').format(date);
    } catch (e) {
      if (kDebugMode) {
        print('Error parsing date: $e');
      }
      return 'Invalid Date'; // or return 'N/A' or any other default value
    }
  }

  static String formatTimes(context, String? dateString) {
    if (dateString == null || dateString == "null") return 'N/A';

    try {
      final DateTime date = DateTime.parse(dateString);
      return DateFormat('hh:mm a').format(date);
    } catch (e) {
      if (kDebugMode) {
        print('Error parsing date: $e');
      }
      return 'Invalid Date'; // or return 'N/A' or any other default value
    }
  }

  static String formatPrice(number) {
    dynamic formattedTotal = number != null
        ? (number % 1 == 0)
            ? NumberFormat('#,##0').format(num.tryParse(number.toString()) ?? 0)
            : NumberFormat('#,##0.00')
                .format(num.tryParse(number.toString()) ?? 0)
        : '0';

    return formattedTotal;
  }

  static String formatAmount(number) {
    dynamic formattedTotal = number != null
        ? NumberFormat('#,##0.00').format(num.tryParse(number.toString()) ?? 0)
        : '0';

    return formattedTotal;
  }

  static String getFullName(context, {String? first, String? last}) {
    final cleanFirstName = first?.trim() ?? '';
    final cleanLastName = last?.trim() ?? '';

    if (cleanFirstName.isEmpty && cleanLastName.isEmpty) {
      return 'N/A';
    }
    if (cleanFirstName.isEmpty) return cleanLastName;
    if (cleanLastName.isEmpty) return cleanFirstName;

    return '$cleanFirstName $cleanLastName';
  }

  static String? formatPositiveValue(dynamic value) {
    if (value == null) return null;
    String val = value.toString().trim();
    if (val.isEmpty || val == '-' || val == 'N/A' || val == 'null') return val;

    // Remove any existing plus sign for parsing
    String cleanValue = val.startsWith('+') ? val.substring(1) : val;
    final parsed = num.tryParse(cleanValue);

    if (parsed != null) {
      final formatted = parsed.toStringAsFixed(2);
      if (parsed > 0) {
        return '+$formatted';
      }
      return formatted;
    }
    return val;
  }

  /// Which way a refraction reading points, for the +/- badge shown next to
  /// Spherical, Cylindrical and Near Vision Addition.
  ///
  /// Returns 1 for positive, -1 for negative and 0 for "do not mark": a plain 0.00
  /// is not positive, and an empty field must stay unmarked.
  static int measurementSign(dynamic value) {
    if (value == null) return 0;
    final text = value.toString().trim();
    if (text.isEmpty || text == '-' || text == 'N/A' || text == 'null') {
      return 0;
    }

    final parsed =
        num.tryParse(text.startsWith('+') ? text.substring(1) : text);
    if (parsed == null || parsed == 0) return 0;

    return parsed > 0 ? 1 : -1;
  }

  static String calculateAge(DateTime? birthDate) {
    if (birthDate == null) {
      return 'N/A';
    }
    DateTime currentDate = DateTime.now();
    int age = currentDate.year - birthDate.year;

    // Check if birthday hasn't occurred this year yet
    if (currentDate.month < birthDate.month ||
        (currentDate.month == birthDate.month &&
            currentDate.day < birthDate.day)) {
      age--;
    }

    return age.toString();
  }

  static DateTime? formatUtcTime(String? utcTimeString) {
    try {
      // Validate input format
      if (utcTimeString == null || utcTimeString.isEmpty) {
        return null;
      }

      // Replace space with 'T' and add 'Z' suffix
      final formattedTime = '${utcTimeString.replaceFirst(' ', 'T')}Z';

      // Parse and convert to local time
      return DateTime.parse(formattedTime).toLocal();
    } catch (e) {
      return null;
    }
  }
}
