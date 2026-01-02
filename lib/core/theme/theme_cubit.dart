import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ocurithm/core/Network/shared.dart';
import 'theme_state.dart';

class ThemeCubit extends Cubit<ThemeState> {
  ThemeCubit()
      : super(ThemeInitial(
          themeMode: _getInitialThemeMode(),
          isDarkMode: _getInitialIsDarkMode(),
        ));

  // Get initial theme mode from cache
  static ThemeMode _getInitialThemeMode() {
    final isDark = CacheHelper.getData(key: "isDarkMode") ?? false;
    return isDark ? ThemeMode.dark : ThemeMode.light;
  }

  // Get initial isDarkMode boolean from cache
  static bool _getInitialIsDarkMode() {
    return CacheHelper.getData(key: "isDarkMode") ?? false;
  }

  // Toggle between light and dark theme
  Future<void> toggleTheme() async {
    final newIsDarkMode = !state.isDarkMode;
    final newThemeMode = newIsDarkMode ? ThemeMode.dark : ThemeMode.light;

    // Save to cache
    await CacheHelper.saveBoolean(key: "isDarkMode", value: newIsDarkMode);

    // Emit new state
    emit(ThemeChanged(
      themeMode: newThemeMode,
      isDarkMode: newIsDarkMode,
    ));
  }

  // Set specific theme mode
  Future<void> setThemeMode(ThemeMode mode) async {
    final isDark = mode == ThemeMode.dark;

    // Save to cache
    await CacheHelper.saveBoolean(key: "isDarkMode", value: isDark);

    // Emit new state
    emit(ThemeChanged(
      themeMode: mode,
      isDarkMode: isDark,
    ));
  }

  // Set dark mode
  Future<void> setDarkMode(bool isDark) async {
    final mode = isDark ? ThemeMode.dark : ThemeMode.light;

    // Save to cache
    await CacheHelper.saveBoolean(key: "isDarkMode", value: isDark);

    // Emit new state
    emit(ThemeChanged(
      themeMode: mode,
      isDarkMode: isDark,
    ));
  }
}
