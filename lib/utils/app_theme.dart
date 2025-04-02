import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static const primary = Color(0xFF6366f1);
  static const primaryDark = Color(0xFF4f46e5);
  static const secondary = Color(0xFF0ea5e9);
  static const success = Color(0xFF22c55e);
  static const error = Color(0xFFef4444);
  static const warning = Color(0xFFf59e0b);
  static const textColor = Color(0xFF1e293b);
  static const textLight = Color(0xFF64748b);
  static const background = Color(0xFFf8fafc);
  static const cardBackground = Color(0xFFffffff);
  static const cardBorder = Color(0xFFe2e8f0);

  static ThemeData lightTheme() {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.light(
        primary: primary,
        secondary: secondary,
        error: error,
        background: background,
        surface: cardBackground,
      ),
      textTheme: GoogleFonts.poppinsTextTheme(),
      cardTheme: CardTheme(
        color: cardBackground,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
          side: BorderSide(color: cardBorder),
        ),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: background,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: GoogleFonts.poppins(
          fontSize: 24,
          fontWeight: FontWeight.w600,
          color: textColor,
        ),
      ),
    );
  }

  static ThemeData darkTheme() {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.dark(
        primary: primary,
        secondary: secondary,
        error: error,
        background: Color(0xFF1a1a1a),
        surface: Color(0xFF2d2d2d),
      ),
      textTheme: GoogleFonts.poppinsTextTheme(ThemeData.dark().textTheme),
      cardTheme: CardTheme(
        color: Color(0xFF2d2d2d),
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
          side: BorderSide(color: Color(0xFF3d3d3d)),
        ),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: Color(0xFF1a1a1a),
        elevation: 0,
        centerTitle: true,
        titleTextStyle: GoogleFonts.poppins(
          fontSize: 24,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
      ),
    );
  }
}
