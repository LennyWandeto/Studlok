import 'package:flutter/material.dart';

const _clashDisplay = 'ClashDisplay';

/// Type scale. Body/UI text stays on the system font (SF Pro on iOS) by
/// leaving `fontFamily` unset — never give body text a custom font family.
/// Display styles use Clash Display, with its heaviest weight reserved for
/// the tier that should feel like a gut-punch (hero numerals, the
/// session/quiz-completion moment) rather than spent on every headline.
///
/// Color is intentionally not baked into these styles — compose with
/// StudlokColors at the call site, same as the rest of the app already does.
class StudlokTypography {
  StudlokTypography._();

  // --- Body / UI (SF Pro via system default) ---
  static const caption = TextStyle(fontSize: 13, fontWeight: FontWeight.w500, letterSpacing: 0.1);
  static const body = TextStyle(fontSize: 16, fontWeight: FontWeight.w400, height: 1.4);
  static const bodyEmphasis = TextStyle(fontSize: 16, fontWeight: FontWeight.w700);

  // --- Display / headline (Clash Display) ---

  /// Section headers, screen titles — the restrained end of the range.
  static const subhead = TextStyle(
    fontFamily: _clashDisplay,
    fontSize: 22,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.2,
  );

  /// Screen-level headline moments — onboarding statements, success copy.
  static const headline = TextStyle(
    fontFamily: _clashDisplay,
    fontSize: 32,
    fontWeight: FontWeight.w600,
    letterSpacing: -0.2,
    height: 1.1,
  );

  /// The gut-punch tier — hero numerals (Streak, Scroll Bank) and the one
  /// signature completion moment. Heaviest weight, tightest tracking.
  static const display = TextStyle(
    fontFamily: _clashDisplay,
    fontSize: 48,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.5,
    height: 1.0,
  );
}
