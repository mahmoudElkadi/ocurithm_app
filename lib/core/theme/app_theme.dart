import 'package:flutter/material.dart';
import 'package:ocurithm/core/utils/colors.dart';

class AppTheme {
  // Light Theme
  static ThemeData lightTheme = ThemeData(
    brightness: Brightness.light,
    primaryColor: Colorz.primaryColor,
    scaffoldBackgroundColor: Colors.white,
    appBarTheme: const AppBarTheme(
      elevation: 0,
      backgroundColor: Colors.white,
      iconTheme: IconThemeData(color: Colors.black),
      titleTextStyle: TextStyle(
        color: Colors.black,
        fontSize: 20,
        fontWeight: FontWeight.w600,
      ),
    ),
    drawerTheme: const DrawerThemeData(
      backgroundColor: Colors.white,
    ),
    cardColor: Colors.white,
    dividerColor: Colors.grey,
    iconTheme: const IconThemeData(color: Colors.black),
    textTheme: const TextTheme(
      bodyLarge: TextStyle(color: Colors.black),
      bodyMedium: TextStyle(color: Colors.black),
      bodySmall: TextStyle(color: Colors.black87),
    ),
    useMaterial3: false,
  );

  // Dark Theme
  static ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,
    primaryColor: Colorz.primaryColor,
    scaffoldBackgroundColor: const Color(0xFF121212),
    appBarTheme: const AppBarTheme(
      elevation: 0,
      backgroundColor: Color(0xFF1E1E1E),
      iconTheme: IconThemeData(color: Colors.white),
      titleTextStyle: TextStyle(
        color: Colors.white,
        fontSize: 20,
        fontWeight: FontWeight.w600,
      ),
    ),
    drawerTheme: const DrawerThemeData(
      backgroundColor: Color(0xFF1E1E1E),
    ),
    cardColor: const Color(0xFF2C2C2C), // Better contrast for cards
    shadowColor: Colors.black54, // Better shadows in dark mode
    dividerColor: Colors.grey.shade700,
    iconTheme: const IconThemeData(color: Colors.white),
    textTheme: const TextTheme(
      bodyLarge: TextStyle(color: Colors.white),
      bodyMedium: TextStyle(color: Colors.white),
      bodySmall: TextStyle(color: Colors.white70),
    ),
    useMaterial3: false,
  );
}
