import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:ocurithm/core/utils/colors.dart';

class CustomDatePicker {
  static Future<DateTime?> show({
    required BuildContext context,
    required DateTime initialDate,
    DateTime? firstDate,
    DateTime? lastDate,
  }) async {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: firstDate ?? DateTime(2000),
      lastDate: lastDate ?? DateTime(2101),
      builder: (context, child) {
        return Theme(
          data: theme.copyWith(
            colorScheme: isDark
                ? ColorScheme.dark(
                    primary: Colorz.primaryColor,
                    onPrimary: Colors.white,
                    surface: theme.cardColor,
                    onSurface: Colors.white,
                    secondary: Colorz.primaryColor,
                  )
                : ColorScheme.light(
                    primary: Colorz.primaryColor,
                    onPrimary: Colors.white,
                    surface: Colors.white,
                    onSurface: Colorz.primaryColor,
                  ),
            dialogBackgroundColor: isDark ? theme.cardColor : Colors.white,
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: Colorz.primaryColor,
              ),
            ),
          ),
          child: child!,
        );
      },
    );
  }
}

class DatePickerField extends StatelessWidget {
  final String label;
  final DateTime selectedDate;
  final VoidCallback onTap;
  final String? hintText;
  final IconData? icon;

  const DatePickerField({
    super.key,
    required this.label,
    required this.selectedDate,
    required this.onTap,
    this.hintText,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label.isNotEmpty) ...[
          Text(
            label,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14,
              color: isDark ? Colors.grey[300] : Colors.grey[700],
            ),
          ),
          const SizedBox(height: 8),
        ],
        InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: isDark ? Colors.grey[900] : Colors.grey[50],
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isDark ? Colors.grey[800]! : Colors.grey[200]!,
                width: 1.5,
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(
                      icon ?? Icons.calendar_today_outlined,
                      size: 20,
                      color: Colorz.primaryColor,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      DateFormat('MMMM dd, yyyy').format(selectedDate),
                      style: TextStyle(
                        fontSize: 16,
                        color: isDark ? Colors.white : Colors.black87,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                Icon(
                  Icons.arrow_drop_down,
                  color: isDark ? Colors.grey[600] : Colors.grey[400],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
