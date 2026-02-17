import 'package:flutter/material.dart';

class AppTheme {
  // Seed colors for light and dark themes
  static const Color _lightSeedColor = Colors.lightGreen;
  static const Color _darkSeedColor = Colors.green;

  // Create light theme
  static ThemeData get lightTheme {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: _lightSeedColor,
      brightness: Brightness.light,
      error: Colors.red,
    );

    return ThemeData.from(colorScheme: colorScheme).copyWith(
      appBarTheme: AppBarTheme(
        backgroundColor: colorScheme.primaryContainer,
        foregroundColor: colorScheme.onPrimaryContainer,
      ),
    );
  }

  // Create dark theme
  static ThemeData get darkTheme {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: _darkSeedColor,
      brightness: Brightness.dark,
      error: Colors.red,
    );

    return ThemeData.from(colorScheme: colorScheme).copyWith(
      appBarTheme: AppBarTheme(
        backgroundColor: colorScheme.primaryContainer,
        foregroundColor: colorScheme.onPrimaryContainer,
      ),
    );
  }

  // Convert string to ThemeMode
  static ThemeMode themeModeFromString(String theme) {
    switch (theme) {
      case 'light':
        return ThemeMode.light;
      case 'dark':
        return ThemeMode.dark;
      case 'system':
      default:
        return ThemeMode.system;
    }
  }
}
