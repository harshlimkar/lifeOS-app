import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Core Colors
  static const Color background = Color(0xFF050A0F);
  static const Color surface = Color(0xFF0D1520);
  static const Color surfaceLight = Color(0xFF162030);
  static const Color card = Color(0xFF111B28);

  static const Color neonGreen = Color(0xFF00FF88);
  static const Color neonGreenDim = Color(0xFF00CC6A);
  static const Color neonGreenGlow = Color(0x3300FF88);
  static const Color neonBlue = Color(0xFF00D4FF);
  static const Color neonPurple = Color(0xFF8B5CF6);

  static const Color textPrimary = Color(0xFFE8F4FF);
  static const Color textSecondary = Color(0xFF7A9DB8);
  static const Color textMuted = Color(0xFF4A6580);

  static const Color glassWhite = Color(0x0FFFFFFF);
  static const Color glassBorder = Color(0x1AFFFFFF);
  static const Color glassGreen = Color(0x1500FF88);

  static const Color errorColor = Color(0xFFFF4757);
  static const Color warningColor = Color(0xFFFFD700);
  static const Color successColor = Color(0xFF00FF88);

  // Gradients
  static const LinearGradient backgroundGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF050A0F), Color(0xFF0A1525), Color(0xFF050A0F)],
  );

  static const LinearGradient neonGreenGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF00FF88), Color(0xFF00CC6A)],
  );

  static const LinearGradient cardGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF162030), Color(0xFF111B28)],
  );

  static const LinearGradient glassGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0x1AFFFFFF), Color(0x05FFFFFF)],
  );

  // Shadows & Glows
  static List<BoxShadow> neonGlow = [
    BoxShadow(color: neonGreenGlow, blurRadius: 20, spreadRadius: 2),
    BoxShadow(color: neonGreenGlow.withOpacity(0.2), blurRadius: 40, spreadRadius: 4),
  ];

  static List<BoxShadow> cardShadow = [
    BoxShadow(color: Colors.black.withOpacity(0.4), blurRadius: 20, offset: const Offset(0, 8)),
    BoxShadow(color: neonGreen.withOpacity(0.03), blurRadius: 30, spreadRadius: 1),
  ];

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: background,
      colorScheme: const ColorScheme.dark(
        primary: neonGreen,
        secondary: neonBlue,
        surface: surface,
        error: errorColor,
      ),
      textTheme: GoogleFonts.outfitTextTheme(
        const TextTheme(
          displayLarge: TextStyle(color: textPrimary, fontWeight: FontWeight.w700),
          displayMedium: TextStyle(color: textPrimary, fontWeight: FontWeight.w600),
          displaySmall: TextStyle(color: textPrimary, fontWeight: FontWeight.w600),
          headlineLarge: TextStyle(color: textPrimary, fontWeight: FontWeight.w700),
          headlineMedium: TextStyle(color: textPrimary, fontWeight: FontWeight.w600),
          headlineSmall: TextStyle(color: textPrimary, fontWeight: FontWeight.w600),
          titleLarge: TextStyle(color: textPrimary, fontWeight: FontWeight.w600),
          titleMedium: TextStyle(color: textPrimary, fontWeight: FontWeight.w500),
          titleSmall: TextStyle(color: textSecondary, fontWeight: FontWeight.w500),
          bodyLarge: TextStyle(color: textPrimary),
          bodyMedium: TextStyle(color: textSecondary),
          bodySmall: TextStyle(color: textMuted),
          labelLarge: TextStyle(color: textPrimary, fontWeight: FontWeight.w600),
        ),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        iconTheme: IconThemeData(color: textPrimary),
        titleTextStyle: TextStyle(
          color: textPrimary,
          fontSize: 18,
          fontWeight: FontWeight.w600,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: neonGreen,
          foregroundColor: background,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          textStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
          elevation: 0,
        ),
      ),
    );
  }
}
