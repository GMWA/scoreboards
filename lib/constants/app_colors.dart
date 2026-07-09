import 'package:flutter/material.dart';

/// Design tokens for Scoreboards Mobile v2 ("Refined Dark"),
/// synced from the Claude Design handoff bundle.
///
/// Naming keeps a couple of legacy aliases (`brand`, `darkBg`, `surface`,
/// `borderSubtle`, `textSecondary`) so existing call sites keep compiling;
/// their values have been updated to the new palette.
class AppColors {
  // Backgrounds
  static const Color bg = Color(0xFF0D0E10);
  static const Color surface = Color(0xFF17191C);
  static const Color surfaceAlt = Color(0xFF20232A);
  static const Color badgeBg = Color(0xFF2A2D33);

  // Borders / dividers
  // Single consolidated hairline token — the source design mixed three near
  // duplicates (#1e2125 / #1a1d21 / #22252a) for the same purpose; unify here.
  static const Color divider = Color(0xFF1E2125);
  static const Color border = Color(0xFF22252A);

  // Text
  static const Color textPrimary = Color(0xFFF4F5F6);
  static const Color textSecondary = Color(0xFF8B9096);

  // Brand / semantic accents
  static const Color coral = Color(0xFFFF6B66); // brand + "live/urgent"
  static const Color coralTint = Color(0x1FFF6B66); // rgba(255,107,102,.12)
  static const Color mint = Color(0xFF5FE3C4); // "positive" / win / highlight
  static const Color mintTint = Color(0x295FE3C4); // rgba(95,227,196,.16)
  static const Color yellowCard = Color(0xFFF2C94C);
  static const Color scoreDivider = Color(0xFF5A5F66);
  static const Color toggleOn = Color(0xFF2FD3B0);
  static const Color toggleOff = Color(0xFF3A3D42);

  // --- Legacy aliases (kept so existing widgets referencing AppColors.*
  // continue to compile) ---
  static const Color brand = coral;
  static const Color darkBg = bg;
  static const Color borderSubtle = border;
}

/// Font family tokens. Loaded via `google_fonts` in main.dart's ThemeData
/// so no static font assets need to be bundled.
class AppFonts {
  static const String brand = 'Space Grotesk'; // headings / wordmark
  static const String body = 'Hanken Grotesk'; // default UI text
  static const String score = 'Archivo'; // score numerals / stat numerals
}
