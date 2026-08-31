import 'package:flutter/material.dart';

import '../design/studlok_colors.dart';
import '../design/studlok_radius.dart';

// Re-exported so every existing `import '../theme/studlok_theme.dart'` and
// `StudlokColors.xxx` call site keeps resolving unchanged — the color
// system's real home is now lib/design/, this file just assembles ThemeData
// from it. See lib/design/ for the rest of the token system (typography,
// spacing, radius) and lib/design/components/ for the shared widgets.
export '../design/studlok_colors.dart';

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
      error: StudlokColors.warning,
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
        shape: RoundedRectangleBorder(borderRadius: StudlokRadius.buttonRadius),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(foregroundColor: StudlokColors.accent),
    ),
    bottomSheetTheme: const BottomSheetThemeData(
      backgroundColor: StudlokColors.surfaceElevated,
      shape: RoundedRectangleBorder(borderRadius: StudlokRadius.sheetRadius),
    ),
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: StudlokColors.surface,
      indicatorColor: StudlokColors.accent.withValues(alpha: 0.18),
      iconTheme: WidgetStateProperty.resolveWith(
        (states) => IconThemeData(
          color: states.contains(WidgetState.selected) ? StudlokColors.accent : StudlokColors.textSecondary,
        ),
      ),
      labelTextStyle: WidgetStateProperty.resolveWith(
        (states) => TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w700,
          color: states.contains(WidgetState.selected) ? StudlokColors.accent : StudlokColors.textSecondary,
        ),
      ),
    ),
  );
}
