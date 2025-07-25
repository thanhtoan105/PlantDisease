import 'package:flutter/material.dart';

/// App color constants matching the React Native theme
class AppColors {
  // Primary Colors
  static const Color primaryGreen = Color(0xFF088A6A);
  static const Color secondary = Color(0xFF222222);
  static const Color accentOrange = Color(0xFF3AAA49);

  // Neutral Colors
  static const Color darkNavy = Color(0xFF222831);
  static const Color mediumGray = Color(0xFFAAAAAA);
  static const Color lightGray = Color(0xFFF5F6F8);
  static const Color white = Color(0xFFFFFFFF);

  // State Colors
  static const Color errorRed = Color(0xFFE53E3E);
  static const Color successGreen = Color(0xFF3AAA49);
  static const Color warningOrange = Color(0xFFEFAC48);

  // Alias Colors for compatibility
  static const Color error = Color(0xFFE53E3E);
  static const Color success = Color(0xFF3AAA49);
  static const Color warning = Color(0xFFEFAC48);
  static const Color info = Color(0xFF2196F3);
  static const Color disabled = Color(0xFFCCCCCC);

  // Weather Theme Colors
  static const Color weatherBackground = Color(0xFFF6F6F6);
  static const Color weatherSecondary = Color(0xFFD6E3F5);
  static const Color weatherDark = Color(0xFF1A1D27);
  static const Color weatherPurple = Color(0xFF8957F2);
  static const Color weatherBlue = Color(0xFF396295);
  static const Color weatherLightBlue = Color(0xFF90AFD5);
  static const Color weatherGray = Color(0xFFA8AAAD);
  static const Color weatherOrange = Color(0xFFF1A43C);
  static const Color weatherYellow = Color(0xFFF5CA45);

  // Shadow Colors
  static const Color shadowColor = Color(0x1A000000);
  static const Color cardShadow = Color(0x0D000000);
  static const Color darkGray = Color(0xFF333333);

  // Private constructor to prevent instantiation
  AppColors._();
}
