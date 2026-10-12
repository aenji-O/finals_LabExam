import 'package:flutter/material.dart';

class AppColors {
  static const ink = Color(0xFF3B2A20);
  static const brown = Color(0xFF8B5E3C);
  static const paper = Color(0xFFF7F1E8);
  static const lightBrown = Color(0xFFEFE2D2);
  static const muted = Color(0xFF88796B);
}

class AppTheme {
  static ThemeData get light => ThemeData(
        useMaterial3: true,
        fontFamily: 'sans-serif',
        scaffoldBackgroundColor: AppColors.paper,
        colorScheme: ColorScheme.fromSeed(seedColor: AppColors.brown, surface: AppColors.paper),
        appBarTheme: const AppBarTheme(
          backgroundColor: AppColors.paper,
          foregroundColor: AppColors.ink,
          elevation: 0,
          centerTitle: false,
          titleTextStyle: TextStyle(
            color: AppColors.ink,
            fontFamily: 'serif',
            fontSize: 22,
            fontWeight: FontWeight.w700,
          ),
        ),
        textTheme: const TextTheme(
          headlineMedium: TextStyle(
            color: AppColors.ink,
            fontFamily: 'serif',
            fontWeight: FontWeight.w700,
            letterSpacing: -1.1,
            height: 1.08,
          ),
          titleLarge: TextStyle(
            color: AppColors.ink,
            fontFamily: 'serif',
            fontWeight: FontWeight.w700,
          ),
          bodyLarge: TextStyle(color: AppColors.ink, height: 1.55),
          bodyMedium: TextStyle(color: AppColors.muted, height: 1.5),
        ),
        cardTheme: CardThemeData(
          color: const Color(0xFFFFFCF8),
          elevation: 1,
          shadowColor: const Color(0x1420342D),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          margin: EdgeInsets.zero,
        ),
        inputDecorationTheme: InputDecorationTheme(filled: true, fillColor: AppColors.paper, border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none), contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14)),
      );
}
