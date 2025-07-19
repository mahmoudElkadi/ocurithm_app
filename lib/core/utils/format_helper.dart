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
      print('Error parsing date: $e');
      return 'Invalid Date'; // or return 'N/A' or any other default value
    }
  }

  static String formatTimes(context, String? dateString) {
    if (dateString == null || dateString == "null") return 'N/A';

    try {
      final DateTime date = DateTime.parse(dateString);
      return DateFormat('HH:mm a').format(date);
    } catch (e) {
      print('Error parsing date: $e');
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
}
