import 'package:flutter/material.dart';

abstract class ThemeState {
  final ThemeMode themeMode;
  final bool isDarkMode;

  const ThemeState({
    required this.themeMode,
    required this.isDarkMode,
  });
}

class ThemeInitial extends ThemeState {
  const ThemeInitial({
    required super.themeMode,
    required super.isDarkMode,
  });
}

class ThemeChanged extends ThemeState {
  const ThemeChanged({
    required super.themeMode,
    required super.isDarkMode,
  });
}
