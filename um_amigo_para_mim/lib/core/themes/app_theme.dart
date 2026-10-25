import 'package:flutter/material.dart';

class AppTheme {
  const AppTheme._();

  static ThemeData get light {
    const primary = Color(0xFF1E6B62);
    const secondary = Color(0xFFE98A5B);
    const surface = Color(0xFFFFFBF5);

    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primary,
        primary: primary,
        secondary: secondary,
        surface: surface,
        brightness: Brightness.light,
      ),
      scaffoldBackgroundColor: surface,
      appBarTheme: const AppBarTheme(
        backgroundColor: surface,
        foregroundColor: Color(0xFF193A36),
        centerTitle: false,
        elevation: 0,
      ),
      cardTheme: CardThemeData(
        color: Colors.white,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
          side: const BorderSide(color: Color(0xFFE9E4DC)),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
      ),
      navigationBarTheme: const NavigationBarThemeData(
        backgroundColor: Colors.white,
        indicatorColor: Color(0xFFD4ECE5),
      ),
    );
  }
}
