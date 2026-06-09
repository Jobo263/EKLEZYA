import 'package:flutter/material.dart';
import 'app_colors.dart';

/// EKLEZYA Typography
/// Serif   → CrimsonText  (headings, verse text, devotional content)
/// Sans    → Lato          (UI labels, captions, navigation)
class AppTextStyles {
  AppTextStyles._();

  // ── CrimsonText — Serif ───────────────────────────────────────────────────

  static const TextStyle displayLarge = TextStyle(
    fontFamily: 'CrimsonText',
    fontSize: 48,
    fontWeight: FontWeight.w700,
    height: 1.2,
    letterSpacing: -0.5,
    color: AppColors.primary,
  );

  static const TextStyle displayMedium = TextStyle(
    fontFamily: 'CrimsonText',
    fontSize: 36,
    fontWeight: FontWeight.w700,
    height: 1.25,
    letterSpacing: -0.3,
    color: AppColors.primary,
  );

  static const TextStyle displaySmall = TextStyle(
    fontFamily: 'CrimsonText',
    fontSize: 28,
    fontWeight: FontWeight.w700,
    height: 1.3,
    color: AppColors.primary,
  );

  static const TextStyle headlineLarge = TextStyle(
    fontFamily: 'CrimsonText',
    fontSize: 24,
    fontWeight: FontWeight.w700,
    height: 1.35,
    color: AppColors.primary,
  );

  static const TextStyle headlineMedium = TextStyle(
    fontFamily: 'CrimsonText',
    fontSize: 20,
    fontWeight: FontWeight.w700,
    height: 1.4,
    color: AppColors.primary,
  );

  static const TextStyle headlineSmall = TextStyle(
    fontFamily: 'CrimsonText',
    fontSize: 18,
    fontWeight: FontWeight.w700,
    height: 1.4,
    color: AppColors.primary,
  );

  /// Verse text — large, elegant, readable
  static const TextStyle verseText = TextStyle(
    fontFamily: 'CrimsonText',
    fontSize: 22,
    fontWeight: FontWeight.w400,
    fontStyle: FontStyle.italic,
    height: 1.7,
    color: AppColors.primary,
  );

  /// Verse reference — small, accent color
  static const TextStyle verseReference = TextStyle(
    fontFamily: 'CrimsonText',
    fontSize: 14,
    fontWeight: FontWeight.w700,
    letterSpacing: 0.5,
    color: AppColors.accent,
  );

  /// Prayer text — readable serif body
  static const TextStyle prayerText = TextStyle(
    fontFamily: 'CrimsonText',
    fontSize: 19,
    fontWeight: FontWeight.w400,
    height: 1.8,
    color: AppColors.darkGray,
  );

  /// Liturgical label — small caps feel
  static const TextStyle liturgicalLabel = TextStyle(
    fontFamily: 'CrimsonText',
    fontSize: 13,
    fontWeight: FontWeight.w700,
    letterSpacing: 1.5,
    color: AppColors.accent,
  );

  // ── Lato — Sans-serif ────────────────────────────────────────────────────

  static const TextStyle titleLarge = TextStyle(
    fontFamily: 'Lato',
    fontSize: 20,
    fontWeight: FontWeight.w700,
    height: 1.3,
    color: AppColors.primary,
  );

  static const TextStyle titleMedium = TextStyle(
    fontFamily: 'Lato',
    fontSize: 16,
    fontWeight: FontWeight.w700,
    height: 1.4,
    color: AppColors.primary,
  );

  static const TextStyle titleSmall = TextStyle(
    fontFamily: 'Lato',
    fontSize: 14,
    fontWeight: FontWeight.w700,
    height: 1.4,
    letterSpacing: 0.1,
    color: AppColors.primary,
  );

  static const TextStyle bodyLarge = TextStyle(
    fontFamily: 'Lato',
    fontSize: 16,
    fontWeight: FontWeight.w400,
    height: 1.6,
    color: AppColors.darkGray,
  );

  static const TextStyle bodyMedium = TextStyle(
    fontFamily: 'Lato',
    fontSize: 14,
    fontWeight: FontWeight.w400,
    height: 1.6,
    color: AppColors.darkGray,
  );

  static const TextStyle bodySmall = TextStyle(
    fontFamily: 'Lato',
    fontSize: 12,
    fontWeight: FontWeight.w400,
    height: 1.5,
    color: AppColors.mediumGray,
  );

  static const TextStyle labelLarge = TextStyle(
    fontFamily: 'Lato',
    fontSize: 14,
    fontWeight: FontWeight.w700,
    letterSpacing: 0.5,
    color: AppColors.primary,
  );

  static const TextStyle labelMedium = TextStyle(
    fontFamily: 'Lato',
    fontSize: 12,
    fontWeight: FontWeight.w700,
    letterSpacing: 0.5,
    color: AppColors.primary,
  );

  static const TextStyle labelSmall = TextStyle(
    fontFamily: 'Lato',
    fontSize: 10,
    fontWeight: FontWeight.w700,
    letterSpacing: 0.8,
    color: AppColors.mediumGray,
  );

  static const TextStyle caption = TextStyle(
    fontFamily: 'Lato',
    fontSize: 11,
    fontWeight: FontWeight.w300,
    letterSpacing: 0.3,
    color: AppColors.mediumGray,
  );

  static const TextStyle button = TextStyle(
    fontFamily: 'Lato',
    fontSize: 15,
    fontWeight: FontWeight.w700,
    letterSpacing: 0.8,
    color: AppColors.white,
  );

  static const TextStyle navLabel = TextStyle(
    fontFamily: 'Lato',
    fontSize: 10,
    fontWeight: FontWeight.w700,
    letterSpacing: 0.5,
  );

  // ── Chat / AI ────────────────────────────────────────────────────────────
  static const TextStyle aiMessage = TextStyle(
    fontFamily: 'Lato',
    fontSize: 15,
    fontWeight: FontWeight.w400,
    height: 1.6,
    color: AppColors.darkGray,
  );

  static const TextStyle userMessage = TextStyle(
    fontFamily: 'Lato',
    fontSize: 15,
    fontWeight: FontWeight.w400,
    height: 1.6,
    color: AppColors.white,
  );

  // ── Dark mode variants ───────────────────────────────────────────────────
  static TextStyle verseTextDark = verseText.copyWith(color: AppColors.offWhite);
  static TextStyle prayerTextDark = prayerText.copyWith(color: AppColors.lightGray);
  static TextStyle bodyLargeDark = bodyLarge.copyWith(color: AppColors.lightGray);
  static TextStyle bodyMediumDark = bodyMedium.copyWith(color: AppColors.lightGray);
}
