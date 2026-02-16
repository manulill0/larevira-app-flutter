import 'package:flutter/material.dart';

class AppColors {
  const AppColors._();

  static const primary = Color(0xFF8B1E3F);
  static const secondary = Color(0xFFC9983E);
  static const accentRose = Color(0xFFB03A5E);

  static const lightSurface = Color(0xFFFFFAF4);
  static const lightTextPrimary = Color(0xFF2D1B11);

  static const darkPrimary = Color(0xFFE0B15A);
  static const darkSurface = Color(0xFF1E1614);
  static const darkCard = Color(0xFF2A211E);
  static const darkTextPrimary = Color(0xFFF0E6DA);

  static const backgroundLightTop = Color(0xFFF7F0E8);
  static const backgroundLightBottom = Color(0xFFF3E3CC);
  static const backgroundDarkTop = Color(0xFF1A1513);
  static const backgroundDarkBottom = Color(0xFF241B19);

  static const error = Color(0xFFA02943);

  static List<Color> scaffoldGradient({required bool isDark}) {
    return isDark
        ? const [backgroundDarkTop, backgroundDarkBottom]
        : const [backgroundLightTop, backgroundLightBottom];
  }

  static Color splashIcon({required bool isDark}) {
    return isDark ? darkPrimary : primary;
  }

  static Color splashTitle({required bool isDark}) {
    return isDark ? darkTextPrimary : lightTextPrimary;
  }
}
