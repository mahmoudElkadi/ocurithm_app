import 'package:flutter/material.dart';

/// A service class to show consistent snackbars throughout the app
class SnackbarService {
  /// Shows a success snackbar with a green background
  static void showSuccess(
    BuildContext context, {
    required String message,
    Duration duration = const Duration(seconds: 3),
    SnackBarAction? action,
  }) {
    _showSnackbar(
      context,
      message: message,
      backgroundColor: Colors.green,
      icon: Icons.check_circle,
      duration: duration,
      action: action,
    );
  }

  /// Shows an error snackbar with a red background
  static void showError(
    BuildContext context, {
    required String message,
    Duration duration = const Duration(seconds: 4),
    SnackBarAction? action,
  }) {
    _showSnackbar(
      context,
      message: message,
      backgroundColor: Colors.red,
      icon: Icons.error,
      duration: duration,
      action: action,
    );
  }

  /// Shows an info snackbar with a blue background
  static void showInfo(
    BuildContext context, {
    required String message,
    Duration duration = const Duration(seconds: 3),
    SnackBarAction? action,
  }) {
    _showSnackbar(
      context,
      message: message,
      backgroundColor: Colors.blue,
      icon: Icons.info,
      duration: duration,
      action: action,
    );
  }

  /// Shows a warning snackbar with an orange background
  static void showWarning(
    BuildContext context, {
    required String message,
    Duration duration = const Duration(seconds: 3),
    SnackBarAction? action,
  }) {
    _showSnackbar(
      context,
      message: message,
      backgroundColor: Colors.orange,
      icon: Icons.warning,
      duration: duration,
      action: action,
    );
  }

  /// Shows a custom snackbar
  static void showCustom(
    BuildContext context, {
    required String message,
    required Color backgroundColor,
    IconData? icon,
    Duration duration = const Duration(seconds: 3),
    SnackBarAction? action,
  }) {
    _showSnackbar(
      context,
      message: message,
      backgroundColor: backgroundColor,
      icon: icon,
      duration: duration,
      action: action,
    );
  }

  /// Internal method to show the snackbar
  static void _showSnackbar(
    BuildContext context, {
    required String message,
    required Color backgroundColor,
    IconData? icon,
    required Duration duration,
    SnackBarAction? action,
  }) {
    // Clear any existing snackbars
    ScaffoldMessenger.of(context).clearSnackBars();

    // Show the new snackbar
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            if (icon != null) ...[
              Icon(
                icon,
                color: Colors.white,
                size: 24,
              ),
              const SizedBox(width: 12),
            ],
            Expanded(
              child: Text(
                message,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: backgroundColor,
        duration: duration,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        margin: const EdgeInsets.all(16),
        action: action,
      ),
    );
  }
}
