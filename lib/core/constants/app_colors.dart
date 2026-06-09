import 'package:flutter/material.dart';

/// EKLEZYA App Color Constants
/// Primary: #1B2A4A (Deep Blue)
/// Accent:  #C9A84C (Gold)
class AppColors {
  AppColors._();

  // ── Brand ────────────────────────────────────────────────────────────────
  static const Color primary = Color(0xFF1B2A4A);
  static const Color primaryLight = Color(0xFF2E4070);
  static const Color primaryDark = Color(0xFF0F1A30);
  static const Color accent = Color(0xFFC9A84C);
  static const Color accentLight = Color(0xFFE0C070);
  static const Color accentDark = Color(0xFFA08030);

  // ── Neutrals ─────────────────────────────────────────────────────────────
  static const Color white = Color(0xFFFFFFFF);
  static const Color offWhite = Color(0xFFF8F5EE);
  static const Color cream = Color(0xFFF2EDD7);
  static const Color lightGray = Color(0xFFE8E0D0);
  static const Color mediumGray = Color(0xFF9E9484);
  static const Color darkGray = Color(0xFF4A4035);
  static const Color black = Color(0xFF1A1510);

  // ── Semantic ──────────────────────────────────────────────────────────────
  static const Color success = Color(0xFF2E7D32);
  static const Color warning = Color(0xFFF57F17);
  static const Color error = Color(0xFFC62828);
  static const Color info = Color(0xFF1565C0);

  // ── Dark Theme Surfaces ───────────────────────────────────────────────────
  static const Color darkBackground = Color(0xFF0D1520);
  static const Color darkSurface = Color(0xFF1A2535);
  static const Color darkCard = Color(0xFF1F2E42);
  static const Color darkDivider = Color(0xFF2A3A50);

  // ── Light Theme Surfaces ──────────────────────────────────────────────────
  static const Color lightBackground = Color(0xFFF8F5EE);
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightCard = Color(0xFFFAF7F0);
  static const Color lightDivider = Color(0xFFE0D8C8);

  // ── Liturgical Colors ─────────────────────────────────────────────────────
  /// Ordinary Time: green
  static const Color liturgicalGreen = Color(0xFF2E7D32);
  static const Color liturgicalGreenLight = Color(0xFFE8F5E9);

  /// Advent & Lent: purple/violet
  static const Color liturgicalPurple = Color(0xFF6A1B9A);
  static const Color liturgicalPurpleLight = Color(0xFFF3E5F5);

  /// Christmas & Easter: white/gold
  static const Color liturgicalWhite = Color(0xFFF5F0E0);
  static const Color liturgicalGold = Color(0xFFC9A84C);
  static const Color liturgicalGoldLight = Color(0xFFFFF8E1);

  /// Martyrs & Special: red
  static const Color liturgicalRed = Color(0xFFC62828);
  static const Color liturgicalRedLight = Color(0xFFFFEBEE);

  /// Gaudete / Laetare: rose/pink
  static const Color liturgicalRose = Color(0xFFE91E8C);
  static const Color liturgicalRoseLight = Color(0xFFFCE4EC);

  /// Requiem: black
  static const Color liturgicalBlack = Color(0xFF212121);
  static const Color liturgicalBlackLight = Color(0xFFF5F5F5);

  // ── Gradients ─────────────────────────────────────────────────────────────
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [primaryLight, primary, primaryDark],
  );

  static const LinearGradient accentGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [accentLight, accent, accentDark],
  );

  static const LinearGradient goldenHourGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFF1B2A4A), Color(0xFF2E4070), Color(0xFF4A5A80)],
  );

  static const LinearGradient parchmentGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [offWhite, cream, lightGray],
  );

  // ── Helper: liturgical color from season name ──────────────────────────
  static Color liturgicalColorFromSeason(String season) {
    switch (season.toLowerCase()) {
      case 'advent':
        return liturgicalPurple;
      case 'christmas':
        return liturgicalGold;
      case 'lent':
        return liturgicalPurple;
      case 'holy_week':
        return liturgicalRed;
      case 'easter':
        return liturgicalWhite;
      case 'ordinary_time':
        return liturgicalGreen;
      case 'gaudete':
      case 'laetare':
        return liturgicalRose;
      case 'martyrs':
        return liturgicalRed;
      case 'requiem':
        return liturgicalBlack;
      default:
        return liturgicalGreen;
    }
  }

  static Color liturgicalColorBgFromSeason(String season) {
    switch (season.toLowerCase()) {
      case 'advent':
        return liturgicalPurpleLight;
      case 'christmas':
        return liturgicalGoldLight;
      case 'lent':
        return liturgicalPurpleLight;
      case 'holy_week':
        return liturgicalRedLight;
      case 'easter':
        return liturgicalGoldLight;
      case 'ordinary_time':
        return liturgicalGreenLight;
      case 'gaudete':
      case 'laetare':
        return liturgicalRoseLight;
      case 'martyrs':
        return liturgicalRedLight;
      case 'requiem':
        return liturgicalBlackLight;
      default:
        return liturgicalGreenLight;
    }
  }
}
