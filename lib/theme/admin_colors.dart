import 'package:flutter/material.dart';
import 'app_theme.dart';

class AdminColors {
  // Brand Harmonized Palette
  static const Color primary = AppTheme.primary;
  static const Color primaryLight = AppTheme.primaryLight;
  static const Color primaryDark = AppTheme.primaryDark;

  // Modern Slate Administrative Surfaces
  static const Color background = AppTheme.backgroundLight;
  static const Color card = AppTheme.cardLight;
  static const Color surface = AppTheme.surfaceLight;

  // Executive Dark Theme Surfaces
  static const Color darkBackground = AppTheme.backgroundDark;
  static const Color darkCard = AppTheme.cardDark;
  static const Color darkSurface = AppTheme.surfaceDark;

  // Typography
  static const Color textDark = AppTheme.textDark;
  static const Color textGrey = AppTheme.textMutedLight;
  static const Color textLight = AppTheme.textLight;

  // Accents
  static const Color accentIndigo = AppTheme.accentIndigo;
  static const Color accentTeal = Color(0xFF14B8A6);
  static const Color accentRose = Color(0xFFF43F5E);
  static const Color success = AppTheme.success;

  // Dynamic Resolvers
  static Color bg(bool isDark) => AppTheme.bg(isDark);
  static Color cardBg(bool isDark) => AppTheme.card(isDark);
  static Color surfaceBg(bool isDark) => AppTheme.surface(isDark);
  static Color text(bool isDark) => AppTheme.text(isDark);
  static Color textMuted(bool isDark) => AppTheme.textMuted(isDark);
  static Color border(bool isDark) => AppTheme.border(isDark);
}
