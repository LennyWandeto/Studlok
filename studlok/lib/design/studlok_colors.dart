import 'package:flutter/material.dart';

/// Studlok's color system — three-tier dark elevation, a small accent
/// system rather than one flat lime, and one semantic color for
/// warnings/errors kept deliberately distinct from the accent.
///
/// `background`, `surface`, `accent`, `white`, and `dimWhite` keep the exact
/// values they've always had — every screen built before this design pass
/// keeps looking exactly as it does today until we deliberately revisit it.
/// New work should reach for `textPrimary`/`textSecondary` over
/// `white`/`dimWhite` going forward; both pairs currently resolve to the
/// same values, so this is a naming migration, not a visual one.
class StudlokColors {
  StudlokColors._();

  // --- Surfaces: 3 elevation tiers, each a clear step lighter. Near-black,
  // never pure #000000 — pure black causes halation (glow/blur) around text.
  static const background = Color(0xFF0D0D0F); // tier 0 — base
  static const surface = Color(0xFF1A1A1D); // tier 1 — card
  static const surfaceElevated = Color(0xFF242428); // tier 2 — modal/sheet

  // --- Text
  static const white = Colors.white; // legacy name — see class doc
  static const textPrimary = Color(0xFFE5E7EB);
  static const dimWhite = Color(0xFFB3B3B3); // legacy name — see class doc
  static const textSecondary = Color(0xFF9CA3AF); // verified 7.65:1 contrast on `background`

  // --- Accent system: one brand lime, built into a small system.
  static const accent = Color(0xFFCCFF00); // primary actions — unchanged brand color
  static const accentBright = Color(0xFFE3FF61); // active/pressed tint
  // Solid, desaturated — for contexts that can't do alpha blending (e.g. the
  // Shield extension's UIColor fields). Prefer accentSubtleFill in Flutter UI.
  static const accentMuted = Color(0xFF4D5A17);

  /// Translucent lime for subtle Flutter-only backgrounds/borders.
  static Color accentSubtleFill({double opacity = 0.12}) => accent.withValues(alpha: opacity);

  // --- Semantic: deliberately red, not amber — amber sits too close to the
  // accent's own yellow-green family and risks reading as another primary
  // action rather than a warning.
  static const warning = Color(0xFFEF4444);
}
