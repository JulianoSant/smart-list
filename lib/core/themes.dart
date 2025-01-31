import 'package:flutter/material.dart';

class AppThemes {
  static final ThemeData lightTheme = ThemeData(
    primaryColor: const Color(0xFF2A4B7C),
    colorScheme: const ColorScheme.light(
      primary: Color(0xFF2A4B7C),
      secondary: Color(0xFF3A9AA8),
      surface: Color(0xFFF5F7FA),
      background: Color(0xFFFFFFFF),
      error: Color(0xFFF44336),
    ),
    textTheme: const TextTheme(
      headlineLarge: TextStyle(color: Color(0xFF1A1F26), fontWeight: FontWeight.bold),
      bodyMedium: TextStyle(color: Color(0xFF6B778C)),
    ),
  );

  static final ThemeData darkTheme = ThemeData(
    primaryColor: const Color(0xFF1E3259),
    colorScheme: const ColorScheme.dark(
      primary: Color(0xFF1E3259),
      secondary: Color(0xFF3A9AA8),
      surface: Color(0xFF121212),
      background: Color(0xFF000000),
      error: Color(0xFFFF5252),
    ),
    textTheme: const TextTheme(
      headlineLarge: TextStyle(color: Color(0xFFE0E0E0), fontWeight: FontWeight.bold),
      bodyMedium: TextStyle(color: Color(0xFF9E9E9E)),
    ),
  );
}
