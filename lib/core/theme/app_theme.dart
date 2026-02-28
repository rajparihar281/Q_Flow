import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  static const primary = Color(0xFF06b6d4);
  static const neon = Color(0xFF00d9ff);
  static const secondary = Color(0xFF10b981);
  static const accent = Color(0xFF8b5cf6);
  static const danger = Color(0xFFef4444);
  static const warning = Color(0xFFf59e0b);
  static const surface = Color(0xFF0a0e27);
  static const cardBg = Color(0xFF1e3a8a);
  static const textPrimary = Color(0xFFFFFFFF);
  static const textSecondary = Color(0xFFa0aec0);
  static const textHint = Color(0xFF718096);
  static const divider = Color(0xFF2d3748);
  static const inputFill = Color(0x331e3a8a); // Glass input fill

  // Transparency Layers
  static final glassEffect = cardBg.withOpacity(0.1);
  static final borderGlow = neon.withOpacity(0.3);
  static final shadowGlow = neon.withOpacity(0.6);
  static final hoverState = primary.withOpacity(0.2);

  static const gradientStart = Color(0xFF0a0e27);
  static const gradientEnd = Color(0xFF1e3a8a);

  static const Gradient primaryGradient = LinearGradient(
    colors: [gradientStart, gradientEnd],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}

class AppTextStyles {
  AppTextStyles._();

  static const displayLarge = TextStyle(
    fontSize: 34,
    fontWeight: FontWeight.bold,
    color: Colors.white,
    letterSpacing: 0.5,
  );

  static const headlineLarge = TextStyle(
    fontSize: 22,
    fontWeight: FontWeight.bold,
    color: Colors.white,
  );

  static const headlineMedium = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.bold,
    color: Colors.white,
  );

  static const headlineSmall = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: Colors.white,
  );

  static const bodyLarge = TextStyle(
    fontSize: 15,
    fontWeight: FontWeight.normal,
    color: Colors.white,
  );

  static const bodyMedium = TextStyle(
    fontSize: 13,
    fontWeight: FontWeight.normal,
    color: AppColors.textSecondary,
  );

  static const bodySmall = TextStyle(
    fontSize: 11,
    fontWeight: FontWeight.normal,
    color: AppColors.textHint,
  );

  static const labelBold = TextStyle(
    fontSize: 13,
    fontWeight: FontWeight.w600,
    color: Colors.white,
  );

  static const caption = TextStyle(
    fontSize: 12,
    color: AppColors.textSecondary,
  );
}

class AppTheme {
  AppTheme._();

  static ThemeData get theme => ThemeData(
    colorScheme: ColorScheme.fromSeed(
      seedColor: AppColors.primary,
      brightness: Brightness.dark,
    ),
    useMaterial3: true,
    fontFamily: 'Roboto',
    scaffoldBackgroundColor: AppColors.surface,
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.transparent,
      elevation: 0,
      iconTheme: IconThemeData(color: Colors.white),
      titleTextStyle: TextStyle(
        color: Colors.white,
        fontSize: 18,
        fontWeight: FontWeight.bold,
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 0,
        padding: const EdgeInsets.symmetric(vertical: 14),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.inputFill,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: AppColors.borderGlow),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: AppColors.primary.withOpacity(0.2)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.neon, width: 1.5),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    ),
    cardTheme: CardThemeData(
      color: Colors.transparent, // Let Container handle glassmorphism
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
    ),
  );
}
