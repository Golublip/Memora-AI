import 'package:flutter/material.dart';
import 'space_colors.dart';

class AppTheme {
  static ThemeData getThemeData({bool isDyslexicMode = false}) {
    // Dyslexia-friendly font settings: Sans-serif with custom spacing and line height
    final double letterSpacing = isDyslexicMode ? 1.8 : 0.5;
    final double wordSpacing = isDyslexicMode ? 2.5 : 0.0;
    final double lineHeight = isDyslexicMode ? 1.6 : 1.2;

    TextStyle baseTextStyle(TextStyle original) {
      return original.copyWith(
        fontFamily: isDyslexicMode ? 'OpenDyslexic' : 'Outfit',
        letterSpacing: letterSpacing,
        wordSpacing: wordSpacing,
        height: lineHeight,
        color: SpaceColors.textPrimary,
      );
    }

    return ThemeData(
      brightness: Brightness.dark,
      primaryColor: SpaceColors.neonCyan,
      scaffoldBackgroundColor: SpaceColors.spaceBlack,
      cardColor: SpaceColors.midnightBlue,
      textTheme: TextTheme(
        displayLarge: baseTextStyle(const TextStyle(fontSize: 32, fontWeight: FontWeight.bold)),
        displayMedium: baseTextStyle(const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
        titleLarge: baseTextStyle(const TextStyle(fontSize: 20, fontWeight: FontWeight.w600)),
        bodyLarge: baseTextStyle(const TextStyle(fontSize: 16, fontWeight: FontWeight.normal)),
        bodyMedium: baseTextStyle(const TextStyle(fontSize: 14, color: SpaceColors.textSecondary)),
        labelLarge: baseTextStyle(const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: SpaceColors.midnightBlue,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: SpaceColors.glassWhite, width: 1),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: SpaceColors.glassWhite, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: SpaceColors.neonCyan, width: 2),
        ),
        hintStyle: const TextStyle(color: SpaceColors.textSecondary),
      ),
      buttonTheme: const ButtonThemeData(
        buttonColor: SpaceColors.neonCyan,
        textTheme: ButtonTextTheme.primary,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: SpaceColors.neonCyan,
          foregroundColor: SpaceColors.spaceBlack,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
