import 'package:flutter/material.dart';

/// "Earn Your Scroll" brand: near-black background, acid-green accent, bold
/// condensed-feeling type. No custom font is bundled yet — heavy weights +
/// tight letter-spacing approximate the condensed look with system fonts
/// until a real display font asset is added.
class StudlokColors {
  StudlokColors._();

  static const background = Color(0xFF0D0D0F);
  static const surface = Color(0xFF1A1A1D);
  static const accent = Color(0xFFCCFF00);
  static const white = Colors.white;
  static const dimWhite = Color(0xFFB3B3B3);
}

ThemeData buildStudlokTheme() {
  final base = ThemeData(
    brightness: Brightness.dark,
    useMaterial3: true,
    scaffoldBackgroundColor: StudlokColors.background,
    colorScheme: ColorScheme.fromSeed(
      seedColor: StudlokColors.accent,
      brightness: Brightness.dark,
    ).copyWith(
      surface: StudlokColors.background,
      primary: StudlokColors.accent,
      onPrimary: Colors.black,
    ),
  );

  return base.copyWith(
    textTheme: base.textTheme.apply(
      bodyColor: StudlokColors.white,
      displayColor: StudlokColors.white,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: StudlokColors.background,
      foregroundColor: StudlokColors.white,
      elevation: 0,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: StudlokColors.accent,
        foregroundColor: Colors.black,
        minimumSize: const Size.fromHeight(52),
        textStyle: const TextStyle(fontWeight: FontWeight.w900, letterSpacing: 1.1),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(foregroundColor: StudlokColors.accent),
    ),
  );
}
